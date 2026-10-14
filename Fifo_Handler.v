`timescale 1ns / 1ps
`default_nettype none
module Fifo_Handler (
    input  wire Clk,
    input  wire Rst,
    input  wire [47:0] Cache_Data,
    input  wire Tx_Fifo_Empty,
    output wire Tx_Rd_En,
    output wire [31:0] Fifo_Wr_Data,
    output wire Rx_Wr_En,
    input  wire Rx_Fifo_Full,
    output wire Wr_En,
    output wire Rd_En,
    output wire [31:0] Wr_Data,
    output wire [13:0] Addr,
    input  wire [31:0] Mem_Rd_Data
);
wire Write_En = Cache_Data[46];
wire Read_En  = Cache_Data[47];
wire [31:0] Mem_Data = Cache_Data[45:14];
wire [13:0] Mem_Addr = Cache_Data[13:0];

localparam  Idle= 2'd0;
localparam  Get= 2'd1;
localparam  Read= 2'd2;

reg [1:0] Current, Next_State;
reg [1:0] Count;
reg [13:0] Base_Addr;

wire [14:0] Add_Address;
assign Add_Address = (Base_Addr + {12'd0,Count});

wire beat_now = ((Current == Get) && Read_En) || (Current == Read);

assign Tx_Rd_En = (Current == Idle) && !Tx_Fifo_Empty;
assign Wr_En = (Current == Get) && Write_En;
assign Rd_En = beat_now;
assign Wr_Data= Mem_Data;
assign Addr = (Current == Read) ?  Add_Address[13:0] : Mem_Addr;
assign Fifo_Wr_Data = Mem_Rd_Data;
assign Rx_Wr_En     = beat_now && !Rx_Fifo_Full;

wire Read_Done = (Current == Read) && Rx_Wr_En && (Count == 2'd3);

always @(posedge Clk or negedge Rst) begin
    if (!Rst) Current <= Idle;
    else      Current <= Next_State;
end
always@(*) begin
    Next_State = Current;
    case (Current)
        Idle: if (!Tx_Fifo_Empty) Next_State = Get;
        Get:  if (Write_En) Next_State = Idle;
              else if (Read_En) Next_State = Read;
              else Next_State = Idle;
        Read: if (Read_Done) Next_State = Idle;
        default: Next_State = Idle;
    endcase
end
always @(posedge Clk or negedge Rst) begin
    if (!Rst) begin
        Base_Addr <= 14'd0;
        Count     <= 2'd0;
    end else begin
        case (Current)
            Get: begin
                Base_Addr <= Mem_Addr;
                Count <= (Read_En && !Rx_Fifo_Full) ? 2'd1 : 2'd0;
            end
            Read: if (Rx_Wr_En) Count <= Count + 2'd1;
            default:Count <= 2'd0;
        endcase
    end
end
endmodule
