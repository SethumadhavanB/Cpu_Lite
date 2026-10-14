`timescale 1ns / 1ps
`default_nettype none

module Pipe_IF_ID (
    input wire Clk,
    input wire Rst,
    input wire Stall,
    input wire Flush,
    input wire [31:0]Instruction,
    input wire [11:0]Pc_Plus1,
    
    output reg [31:0]Pipe_Instruction,
    output reg [11:0]Pipe_Pc_Plus1
);

always @(posedge Clk or negedge Rst) 
begin
    if(!Rst)
    begin
        Pipe_Instruction <= 32'd0;
        Pipe_Pc_Plus1 <= 12'd0;
    end
    else
    begin
        if(Flush) 
        begin
            Pipe_Instruction <= 32'd0;
            Pipe_Pc_Plus1 <= 12'd0;
        end
        else if(!Stall)
        begin
            Pipe_Instruction <= Instruction;
            Pipe_Pc_Plus1    <= Pc_Plus1;
        end
    end
    
end    
endmodule