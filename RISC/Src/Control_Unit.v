`timescale 1ns / 1ps
`default_nettype none

`define NOP       8'h00
`define LOAD      8'h01
`define LOAD_IND  8'h02
`define LOAD_IMM  8'h03
`define STORE     8'h04
`define STORE_IND 8'h05
`define ADD       8'h06
`define SUB       8'h07
`define MUL       8'h08
`define AND       8'h09
`define OR        8'h0A
`define NOT       8'h0B
`define CMP       8'h0C
`define EQ        8'h0D
`define JMP       8'h0E
`define JMP_IF    8'h0F
`define XOR       8'h10
`define SHL       8'h11
`define SHR       8'h12
`define SAR       8'h13
`define ROL       8'h14
`define ROR       8'h15
`define ADDI      8'h16
`define SUBI      8'h17
`define ANDI      8'h18
`define ORI       8'h19
`define XORI      8'h1A
`define MOV       8'h1B
`define SLT       8'h1C
`define SLTU      8'h1D
`define LUI       8'h1E
`define BEQ       8'h20
`define BNE       8'h21
`define BLT       8'h22
`define BGE       8'h23
`define BLTU      8'h24
`define BGEU      8'h25
`define JMP_REG   8'h26
`define CALL      8'h27
`define RET       8'h28
`define HALT      8'hFF

module Control_Unit (
    input wire [7:0] Opcode,

    output reg [4:0] Alu_Op,
    output reg isImm,
    output reg Imm_pad,
    output reg Wb_En,
    output reg Wb_Sel,

    output reg Mem_Read,
    output reg Mem_Write,

    output reg [1:0] Mem_Addr,  // Select Address - 0->Addr , 1->Rs1 ,2->Rs2 
    output reg isRd_Need,
    output reg [3:0]Flag_Store,
    output reg Jump,Jump_Reg,Jump_if,
    output reg Branch,
    output reg [2:0] Br_Cond,
    output reg Halt,
    output reg isCall,
    output reg isRet,
    output reg Use_Rs1,
    output reg Use_Rs2
    
);

always @(*)
begin
    isImm = 1'b0;
    Imm_pad =1'b0;
    Wb_En = 1'b0;
    Wb_Sel = 1'b0;
    Mem_Read = 1'b0;
    Mem_Write = 1'b0;
    Alu_Op = 5'd0;
    Mem_Addr = 2'd0;
    isRd_Need =1'b0;
    Flag_Store = 4'b0000;
    Jump = 1'b0;
    Jump_if = 1'b0;
    Jump_Reg = 1'b0;
    Branch = 1'b0;
    Br_Cond = 3'd0;
    Halt = 1'b0;
    isCall = 1'b0;
    isRet = 1'b0;
    Use_Rs1 = 1'b0;
    Use_Rs2 = 1'b0;


    case (Opcode)

        `NOP: begin
        end

        `LOAD: begin
            Wb_En = 1'b1;
            Wb_Sel = 1'b1;
            Mem_Read = 1'b1;
            Mem_Addr = 2'd0;
        end

        `LOAD_IND: begin
            Wb_En = 1'b1;
            Wb_Sel = 1'b1;
            Mem_Read = 1'b1;
            Mem_Addr = 2'd1;
            Use_Rs1 = 1;
        end

        `LOAD_IMM: begin
            Alu_Op = 5'd17;
            isImm = 1;
            Wb_En = 1'b1;

        end

        `STORE: begin
            Mem_Write = 1'b1;
            Mem_Addr = 2'd0;
            isRd_Need =1'b1;
        end

        `STORE_IND: begin
            Mem_Write = 1'b1;
            Mem_Addr = 2'd2;
            isRd_Need = 1'b1;
            Use_Rs2 = 1;
        end

        `ADD: begin
            Alu_Op = 5'd0;
            Wb_En = 1'b1;
            Flag_Store = 4'b1111;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `SUB: begin
            Alu_Op = 5'd1;
            Wb_En = 1'b1;
            Flag_Store = 4'b1111;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `MUL: begin
            Alu_Op = 5'd2;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `AND: begin
            Alu_Op = 5'd3;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `OR: begin
            Alu_Op = 5'd4;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;

        end

        `NOT: begin
            Alu_Op = 5'd5;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
        end

        `CMP: begin
            Alu_Op = 5'd1;
            Flag_Store = 4'b1111;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `EQ: begin
            Alu_Op = 5'd7;
            Wb_En = 1'b1;
            Flag_Store = 4'b0001;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `JMP: begin
            Jump = 1'b1;
        end

        `JMP_IF: begin
            Jump_if = 1'b1;
            Use_Rs1 = 1;
        end

        `XOR: begin
            Alu_Op = 5'd6;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `SHL: begin
            Alu_Op = 5'd10;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `SHR: begin
            Alu_Op = 5'd11;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `SAR: begin
            Alu_Op = 5'd12;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `ROL: begin
            Alu_Op = 5'd13;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `ROR: begin
            Alu_Op = 5'd14;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `ADDI: begin
            Alu_Op = 5'd0;
            isImm = 1;
            Imm_pad = 1;
            Wb_En = 1'b1;
            Flag_Store = 4'b1111;
            Use_Rs1 = 1;
        end

        `SUBI: begin
            Alu_Op = 5'd1;
            isImm = 1;
            Imm_pad = 1;
            Wb_En = 1'b1;
            Flag_Store = 4'b1111;
            Use_Rs1 = 1;
        end

        `ANDI: begin
            Alu_Op = 5'd3;
            isImm = 1;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
        
        end

        `ORI: begin
            Alu_Op = 5'd4;
            isImm = 1;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
            
        end

        `XORI: begin
            Alu_Op = 5'd6;
            isImm = 1;
            Wb_En = 1'b1;
            Flag_Store = 4'b0011;
            Use_Rs1 = 1;
        end

        `MOV: begin
            Alu_Op = 5'd15;
            Wb_En = 1'b1;
            Use_Rs1 = 1;
        end

        `SLT: begin
            Alu_Op = 5'd8;
            Wb_En = 1'b1;
            Flag_Store = 4'b0001;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `SLTU: begin
            Alu_Op = 5'd9;
            Wb_En = 1'b1;
            Flag_Store = 4'b0001;
            Use_Rs1 = 1;
            Use_Rs2 = 1;
        end

        `LUI: begin
            Alu_Op = 5'd16;
            isImm = 1;
            Wb_En = 1'b1;
        end

        `BEQ: begin
            Branch = 1'b1;
            Br_Cond = 3'd0;
        end

        `BNE: begin
            Branch = 1'b1;
            Br_Cond = 3'd1;
        end

        `BLT: begin
            Branch = 1'b1;
            Br_Cond = 3'd2;
        end

        `BGE: begin
            Branch = 1'b1;
            Br_Cond = 3'd3;
        end

        `BLTU: begin
            Branch = 1'b1;
            Br_Cond = 3'd4;
        end

        `BGEU: begin
            Branch = 1'b1;
            Br_Cond = 3'd5;
        end

        `JMP_REG: begin
            Jump_Reg = 1'b1;
            Use_Rs1 = 1;
        end

        `CALL: begin
            isCall = 1'b1;
        end

        `RET: begin
            isRet = 1'b1;
        end

        `HALT: begin
            Halt = 1'b1;
        end

        default: begin
        end

    endcase
end
    
endmodule