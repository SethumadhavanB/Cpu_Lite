`timescale 1ns / 1ps
`default_nettype none
module Imm_padding (
    input wire [11:0] Imm_Old,
    input wire Imm_Pad,
    output wire [31:0]Imm
);
assign Imm = (Imm_Pad) ? {{20{Imm_Old[11]}}, Imm_Old} : {20'd0,Imm_Old};
endmodule