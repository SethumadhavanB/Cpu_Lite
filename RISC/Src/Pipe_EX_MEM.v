`timescale 1ns / 1ps
`default_nettype none

module Pipe_EX_MEM (
    input  wire Clk,
    input  wire Rst,
    input  wire Stall,

    input  wire [31:0] Alu_Result,
    input  wire [31:0] Store_Data,
    input  wire [13:0] Mem_Address,
    input  wire [3:0]  Rd,
    input  wire  Mem_Rd,
    input  wire  Mem_Wr,
    input  wire  Reg_Wr,
    input  wire  Wb_Sel,

    output reg  [31:0] Pipe_Alu_Result,
    output reg  [31:0] Pipe_Store_Data,
    output reg  [13:0] Pipe_Mem_Address,
    output reg  [3:0]  Pipe_Rd,
    output reg  Pipe_Mem_Rd,
    output reg  Pipe_Mem_Wr,
    output reg  Pipe_Reg_Wr,
    output reg  Pipe_Wb_Sel
);

always @(posedge Clk or negedge Rst)
begin
    if (!Rst)
    begin
        Pipe_Alu_Result  <= 32'd0;
        Pipe_Store_Data  <= 32'd0;
        Pipe_Mem_Address <= 14'd0;
        Pipe_Rd          <= 4'd0;
        Pipe_Mem_Rd      <= 1'b0;
        Pipe_Mem_Wr      <= 1'b0;
        Pipe_Reg_Wr      <= 1'b0;
        Pipe_Wb_Sel      <= 1'b0;
    end
    else
    begin
        if (Stall)
        begin
            // Hold current values
        end
        else
        begin
            Pipe_Alu_Result  <= Alu_Result;
            Pipe_Store_Data  <= Store_Data;
            Pipe_Mem_Address <= Mem_Address;
            Pipe_Rd          <= Rd;
            Pipe_Mem_Rd      <= Mem_Rd;
            Pipe_Mem_Wr      <= Mem_Wr;
            Pipe_Reg_Wr      <= Reg_Wr;
            Pipe_Wb_Sel      <= Wb_Sel;
        end
    end
end

endmodule