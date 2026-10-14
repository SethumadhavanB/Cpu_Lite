`timescale 1ns / 1ps
`default_nettype none
module Pipe_MEM_WB (
    input  wire        Clk,
    input  wire        Rst,
    input  wire        Stall,

    input  wire [31:0] Alu_Result,
    input  wire [31:0] Rd_Data,
    input  wire        Wb_Sel,
    input  wire [3:0]  Rd,
    input  wire        Reg_Wr,

    output reg  [31:0] Pipe_Alu_Result,
    output reg  [31:0] Pipe_Rd_Data,
    output reg         Pipe_Wb_Sel,
    output reg  [3:0]  Pipe_Rd,
    output reg         Pipe_Reg_Wr
);
always @(posedge Clk or negedge Rst) begin
    if (!Rst) begin
        Pipe_Alu_Result <= 32'd0;
        Pipe_Rd_Data    <= 32'd0;
        Pipe_Wb_Sel     <= 1'b0;
        Pipe_Rd         <= 4'd0;
        Pipe_Reg_Wr     <= 1'b0;
    end else if (!Stall) begin
        Pipe_Alu_Result <= Alu_Result;
        Pipe_Rd_Data    <= Rd_Data;
        Pipe_Wb_Sel     <= Wb_Sel;
        Pipe_Rd         <= Rd;
        Pipe_Reg_Wr     <= Reg_Wr;
    end
end
endmodule