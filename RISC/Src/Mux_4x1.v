`timescale 1ns / 1ps
`default_nettype none
module Mux_4X1 #(
    parameter Width=4
) (
    input wire S0,
    input wire S1,
    input wire [Width-1:0] I0,
    input wire [Width-1:0] I1,
    input wire [Width-1:0] I2,
    input wire [Width-1:0] I3,
    
    output wire [Width-1:0] Y 
);
assign Y = (S1) ? ((S0) ? I3:I2) : ((S0) ? I1:I0);
endmodule