`timescale 1ns / 1ps
`default_nettype none
module Mux_2x1 #(parameter Width = 4) 
(
    input wire S,
    input wire [Width-1:0] I0,
    input wire [Width-1:0] I1,
    output wire [Width-1:0] Y
);
assign Y = (S)?I1:I0;
endmodule