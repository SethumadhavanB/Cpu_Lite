`timescale 1ns / 1ps
`default_nettype none

`define Alu_ADD       0
`define Alu_SUB       1
`define Alu_MUL       2
`define Alu_AND       3
`define Alu_OR        4
`define Alu_NOT       5
`define Alu_XOR       6
`define Alu_EQ        7
`define Alu_SLT       8
`define Alu_SLTU      9 
`define Alu_SHL       10
`define Alu_SHR       11
`define Alu_SAR       12
`define Alu_ROL       13
`define Alu_ROR       14
`define Alu_MOV       15
`define Alu_LUI       16 
`define Alu_LOAD_IMM  17

module Alu_Unit (
    input wire [31:0] Op1,
    input wire [31:0] Op2,
    input wire  [4:0] Alu_Op,
    output wire [3:0] PSR,
    output reg [31:0] Alu_Result
);

reg C,Z,V,N;
reg [63:0] Temp;

always @(*) 
begin
    Alu_Result = 32'd0;
    Temp = 64'd0;
    {V,C,N,Z} = 4'b0000;

    case (Alu_Op)
        `Alu_ADD:begin
            Temp = {32'd0,Op1} + {32'd0,Op2};
            Alu_Result = Temp[31:0];
            C = Temp[32];
            Z = (Temp[31:0] == 32'd0);
            N = Alu_Result[31]; 
            V = (~Op1[31] & ~Op2[31] & Alu_Result[31]) | ( Op1[31] &  Op2[31] & ~Alu_Result[31]); 
        end

        `Alu_SUB:begin 
            Temp = {32'd0,Op1} - {32'd0,Op2};
            Alu_Result = Temp[31:0];

            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
            C = (Op1 >= Op2);
            V = (Op1[31] & ~Op2[31] & ~Alu_Result[31]) | (~Op1[31] &  Op2[31] &  Alu_Result[31]);

        end

        `Alu_MUL:begin
            Temp = Op1 * Op2;
            Alu_Result = Temp[31:0];

            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_AND:begin
            Alu_Result = Op1 & Op2;

            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_OR:begin
            Alu_Result = Op1 | Op2;

            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_NOT: begin
            Alu_Result = ~Op1;
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_XOR:begin
            Alu_Result = Op1 ^ Op2;
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_EQ:  begin
            Alu_Result = {31'd0,(Op1 == Op2)};
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_SLT:begin
            Alu_Result = {31'd0, ($signed(Op1) < $signed(Op2))};
            Z = (Alu_Result == 32'd0);
            N = 1'b0;
        end

        `Alu_SLTU:begin
            Alu_Result = {31'd0, (Op1 < Op2)};
            Z = (Alu_Result == 32'd0);
            N = 1'b0;
        end

        `Alu_SHL: begin
            Alu_Result = Op1 <<  Op2[4:0];
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_SHR: begin
            Alu_Result = Op1 >>  Op2[4:0];
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_SAR:begin
            Alu_Result = $signed(Op1) >>> Op2[4:0];
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_ROL:begin
            if (Op2[4:0] == 5'd0)
                Alu_Result = Op1;
            else
                Alu_Result = (Op1 << Op2[4:0]) |
                             (Op1 >> (32 - Op2[4:0]));
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_ROR:begin
            if (Op2[4:0] == 5'd0)
                Alu_Result = Op1;
            else
                Alu_Result = (Op1 >> Op2[4:0]) |
                             (Op1 << (32 - Op2[4:0]));
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_MOV:begin
            Alu_Result = Op1;
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_LUI:begin
            Alu_Result = {Op2[11:0],20'd0};
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        `Alu_LOAD_IMM:begin
            Alu_Result = Op2;
            Z = (Alu_Result == 32'd0);
            N = Alu_Result[31];
        end

        default:begin
            Alu_Result = 32'd0;
            {V,C,N,Z} = 4'b0000;
        end
    endcase
end

assign PSR = {V,C,N,Z};

endmodule