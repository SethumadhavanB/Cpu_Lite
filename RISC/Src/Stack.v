`timescale 1ns / 1ps
`default_nettype none
module Stack (
    input wire Clk,
    input wire Rst,
    input wire Push,
    input wire Pop,
    input wire [11:0]Din,
    output wire [11:0]Top
);
reg [11:0] Stack_Mem [7:0];
reg [3:0] Stack_Ptr;
integer i;
wire Full,Empty;
always@(posedge Clk or negedge Rst)
begin
    if(!Rst) 
    begin
        Stack_Ptr <= 4'd0;
        for(i=0;i<8;i=i+1) Stack_Mem[i] <= 12'd0;
    end
    else
    begin
        if(Push && !Full)
        begin
            Stack_Mem[Stack_Ptr[2:0]] <= Din;
            Stack_Ptr <= Stack_Ptr + 1;
        end
        else if(Pop && !Empty)
        begin
            Stack_Ptr <= Stack_Ptr - 1;
        end
    end
end

assign Full =  (Stack_Ptr == 4'd8);
assign Empty = (Stack_Ptr == 4'd0);

wire [2:0] Top_Idx = Stack_Ptr - 4'd1;
assign Top = Empty ? 12'd0 : Stack_Mem[Top_Idx[2:0]];
endmodule