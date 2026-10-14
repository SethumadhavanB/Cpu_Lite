`timescale 1ns / 1ps
`default_nettype none

module Pc_Unit (
    input  wire Clk,
    input  wire Rst,            
    input  wire Mem_Stall,      
    input  wire Hazard_Stall,   
    input  wire Halt,           
    input  wire isBranchTaken, 
    input  wire [11:0] Target,
    output reg  [11:0] Pc,
    output reg  Halted,
    output wire [11:0] Pc_Plus1
);

    assign Pc_Plus1 = Pc + 12'd1;
    wire Stop = Halt || Halted;
    wire Pc_En = !Mem_Stall && !Stop && (!Hazard_Stall || isBranchTaken);

    always @(posedge Clk or negedge Rst) begin
        if (!Rst)       Halted <= 1'b0;
        else begin 
            if (Halt)  Halted <= 1'b1;
        end
    end

    always @(posedge Clk or negedge Rst) begin
        if (!Rst)        Pc <= 12'd0;
        else if (Pc_En)  Pc <= isBranchTaken ? Target : Pc_Plus1;
    end

endmodule