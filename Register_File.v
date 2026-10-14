`timescale 1ns / 1ps
`default_nettype none

module Register_File (
    input wire Clk,
    input wire Rst,

    input wire [3:0] RegAddr1,
    input wire [3:0] RegAddr2,
    
    input wire [3:0] Wr_Addr,
    input wire [31:0] Wr_Data,
    input wire Wr_en,

    output wire [31:0] Op1,
    output wire [31:0] Op2
);

reg [31:0] Register_Mem[0:15];
integer i;

assign Op1 = Register_Mem[RegAddr1];
assign Op2 = Register_Mem[RegAddr2];

always@(posedge Clk or negedge Rst)
begin
    if(!Rst)
    begin
        for(i=0;i<16;i=i+1)
        begin
            Register_Mem[i] <= 32'd0;
        end
    end
    else
    begin
        if(Wr_en)
        begin
            Register_Mem[Wr_Addr] <= Wr_Data;
        end
    end
end
endmodule