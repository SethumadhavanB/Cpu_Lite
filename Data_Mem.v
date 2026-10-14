`timescale 1ns / 1ps
`default_nettype none
module Data_Mem (
    input  wire        Clk,
    input  wire        Rst,          
    input  wire        Wr_En,
    input  wire        Rd_En,    
    input  wire [13:0] Addr,
    input  wire [31:0] Wr_Data,
    output wire [31:0] Rd_Data
);
    reg [31:0] Data_Array [0:16383];

    assign Rd_Data = (!Rst) ? 32'd0: ((Rd_En)?Data_Array[Addr]:32'd0) ;

    always @(posedge Clk) begin
        if (Wr_En) Data_Array[Addr] <= Wr_Data;
    end
endmodule