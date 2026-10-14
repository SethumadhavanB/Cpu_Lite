`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.08.2026 14:14:00
// Design Name: 
// Module Name: rd_ptr_handler
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`default_nettype none

module rd_ptr_handler #(parameter DEPTH = 8)(
    input  wire rd_clk,
    input  wire rd_rst,
    input  wire rd_en,
    input  wire [$clog2(DEPTH):0]wr_ptr_gray,
    output wire  Empty,
    output reg  [$clog2(DEPTH):0]rd_ptr,
    output reg [$clog2(DEPTH):0]rd_ptr_gray
);

wire [$clog2(DEPTH):0] wr_ptr;
wire [$clog2(DEPTH):0] rd_ptr_gray_un;

genvar i;
generate
    assign wr_ptr[$clog2(DEPTH)] = wr_ptr_gray[$clog2(DEPTH)];
    //  Gray -> binary, MSB downward.  Counting UP keeps the genvar
    //  non-negative: a descending loop ends with i = -1, which is legal
    //  from Verilog-2005 on but illegal in Verilog-2001 and flagged by
    //  lint.  The generated assignments are identical either way.
    for (i = 0; i < $clog2(DEPTH); i = i + 1)
    begin : GRAY2BIN
        assign wr_ptr[$clog2(DEPTH)-1-i] =
                   wr_ptr[$clog2(DEPTH)-i] ^ wr_ptr_gray[$clog2(DEPTH)-1-i];
    end
endgenerate

assign rd_ptr_gray_un = (rd_ptr >> 1) ^ rd_ptr;
always@(posedge rd_clk or negedge rd_rst)
begin
    if(!rd_rst)
          rd_ptr_gray <= 0;
    else
        rd_ptr_gray <= rd_ptr_gray_un;
end

always @(posedge rd_clk or negedge rd_rst)
begin
    if(!rd_rst)
    begin
        rd_ptr <= 'd0;
    end
    else
    begin

        if(rd_en)
        begin
            if(!Empty)
                rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

assign Empty = (wr_ptr == rd_ptr);
endmodule