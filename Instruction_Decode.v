`timescale 1ns / 1ps
`default_nettype none
module Instruction_Decode (
    input wire [31:0] Instruction,

    output wire [7:0] Opcode,
    output wire [3:0] Rd,
    output wire [3:0] RegAddr1,
    output wire [3:0] RegAddr2,
    output wire [11:0] Imm
);

assign Opcode = Instruction[31:24];
assign Rd     = Instruction[23:20];
assign RegAddr1 = Instruction[19:16];
assign RegAddr2 = Instruction[15:12];
assign Imm = Instruction[11:0]; 
    
endmodule