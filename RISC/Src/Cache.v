`timescale 1ns / 1ps
`default_nettype none
module Cache #(
    parameter LINES = 64
)(
    input wire Clk,
    input wire Rst,

    input wire Read_En,
    input wire Write_En,

    input wire [13:0] Addr,
    input wire [31:0] Wr_Data,
    output reg [31:0] Rd_Data,

    output wire Tx_Wr_En,
    output wire [47:0] Tx_Fifo_Data,
    input wire Tx_Fifo_Full,

    input wire Rx_Fifo_Empty,
    input wire [31:0] Rx_Fifo_Data,
    output reg Rx_Rd_En,

    output reg Done
);

localparam IDX_W = $clog2(LINES);
localparam TAG_W = 14 - IDX_W - 2;

reg [1:0] Current, Next_State;

localparam Check = 2'd0;
localparam Read  = 2'd1;
localparam Write = 2'd2;
localparam Fill  = 2'd3;

wire [TAG_W-1:0] Tag;
wire [IDX_W-1:0] Line;
wire [1:0] Offset;
wire Hit;

reg rx_dv;
reg Tx_Req;
reg [1:0] Count;
reg [31:0] ret_data;

assign Tag    = Addr[13:IDX_W+2];
assign Line   = Addr[IDX_W+1:2];
assign Offset = Addr[1:0];

reg Valid_Array [0:LINES-1];
reg [TAG_W-1:0] Tag_Array [0:LINES-1];
reg [127:0] Data_Array [0:LINES-1];

assign Hit = Valid_Array[Line] && (Tag_Array[Line] == Tag);

assign Tx_Fifo_Data = {
    Read_En,
    Write_En,
    Wr_Data,
    Write_En ? Addr : {Tag, Line, 2'b00}
};

assign Tx_Wr_En = Tx_Req && !Tx_Fifo_Full;

wire fill_done;
assign fill_done = rx_dv && (Count == 2'd3);

integer i;

always @(posedge Clk or negedge Rst) begin
    if (!Rst)
        Current <= Check;
    else
        Current <= Next_State;
end

always @(*) begin
    Next_State = Check;

    case (Current)
        Check: begin
            if (!Done) begin
                if (Read_En) begin
                    if (Hit)
                        Next_State = Check;
                    else
                        Next_State = Read;
                end
                else if (Write_En)
                    Next_State = Write;
                else
                    Next_State = Check;
            end
            else
                Next_State = Check;
        end

        Read: begin
            if (Tx_Wr_En)
                Next_State = Fill;
            else
                Next_State = Read;
        end

        Fill: begin
            if (fill_done)
                Next_State = Check;
            else
                Next_State = Fill;
        end

        Write: begin
            if (Tx_Wr_En)
                Next_State = Check;
            else
                Next_State = Write;
        end

        default: Next_State = Check;
    endcase
end
wire Found,End;
assign Found = (Count == Offset);
assign  End = (Count == 2'd3);

always @(posedge Clk or negedge Rst) begin
    if (!Rst) begin
        for (i = 0; i < LINES; i = i + 1) begin
            Valid_Array[i] <= 1'b0;
            Data_Array[i] <= 128'd0;
            Tag_Array[i]   <= {TAG_W{1'b0}};
        end
        Rd_Data  <= 32'd0;
        Done     <= 1'b0;
        Rx_Rd_En <= 1'b0;
        rx_dv    <= 1'b0;
        Tx_Req   <= 1'b0;
        Count    <= 2'd0;
        ret_data <= 32'd0;
    end
    else begin
        rx_dv <= Rx_Rd_En;
        Rx_Rd_En <= 1'b0;
        Done <= 1'b0;

        case (Current)
            Check: begin
                if (!Done && ((Read_En && !Hit) || Write_En))
                    Tx_Req <= 1'b1;

                if (Hit && !Done) begin
                    if (Read_En) begin
                        case (Offset)
                            0: Rd_Data <= Data_Array[Line][31:0];
                            1: Rd_Data <= Data_Array[Line][63:32];
                            2: Rd_Data <= Data_Array[Line][95:64];
                            3: Rd_Data <= Data_Array[Line][127:96];
                            default: Rd_Data <= 32'd0;
                        endcase

                        Done <= 1'b1;
                    end
                    else if (Write_En) begin
                        case (Offset)
                            0: Data_Array[Line][31:0]   <= Wr_Data;
                            1: Data_Array[Line][63:32]  <= Wr_Data;
                            2: Data_Array[Line][95:64]  <= Wr_Data;
                            3: Data_Array[Line][127:96] <= Wr_Data;
                            default: Data_Array[Line] <= 128'd0;
                        endcase
                    end
                end
            end

            Read: begin
                Count <= 2'd0;

                if (Tx_Wr_En)
                    Tx_Req <= 1'b0;
            end

            Fill: begin
                if (!Rx_Fifo_Empty && !Rx_Rd_En && !rx_dv && (Count < 4))
                    Rx_Rd_En <= 1'b1;

                if (rx_dv) begin
                    case (Count)
                        0: Data_Array[Line][31:0]   <= Rx_Fifo_Data;
                        1: Data_Array[Line][63:32]  <= Rx_Fifo_Data;
                        2: Data_Array[Line][95:64]  <= Rx_Fifo_Data;
                        3: Data_Array[Line][127:96] <= Rx_Fifo_Data;
                        default:Data_Array[Line] <= 128'd0;
                    endcase

                    if (Found)
                        ret_data <= Rx_Fifo_Data;

                    Count <= Count + 1;

                    if (End) begin
                        Tag_Array[Line] <= Tag;
                        Valid_Array[Line] <= 1'b1;
                        Rd_Data <= (Found) ? Rx_Fifo_Data : ret_data;
                        Done <= 1'b1;
                    end
                end
            end

            Write: begin
                if (Tx_Wr_En) begin
                    Tx_Req <= 1'b0;
                    Done <= 1'b1;
                end
            end

            default: begin
                rx_dv <= Rx_Rd_En;
                Rx_Rd_En <= 1'b0;
                Done <= 1'b0;
            end

        endcase
    end
end

endmodule