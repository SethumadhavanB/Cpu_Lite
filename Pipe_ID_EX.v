`timescale 1ns / 1ps
`default_nettype none

module Pipe_ID_EX (
    input  wire Clk,
    input  wire Rst,
    input  wire Stall,
    input  wire Flush,

    input  wire [31:0] Op1,
    input  wire [31:0] Op2,
    input  wire [31:0] Imm_Ext,

    input  wire [3:0]  Rd,
    input  wire [1:0]  Mem_Addr,
    input  wire [11:0] Addr12,
    input  wire [11:0] Pc_Plus1,
    input  wire [4:0] Alu_Op,
    input  wire Alu_Src,
    input  wire [3:0] Flag_Store,
    input  wire Branch,
    input  wire [2:0] Br_Cond,
    input  wire Jump,
    input  wire Jump_Reg,
    input  wire Jump_If,
    input  wire Is_Call,
    input  wire Is_Ret,
    input  wire Halt,
    input  wire Mem_Rd,
    input  wire Mem_Wr,
    input  wire Reg_Wr,
    input  wire Wb_Sel,

    output reg [31:0] Pipe_Op1,
    output reg [31:0] Pipe_Op2,
    output reg [31:0] Pipe_Imm_Ext,
    output reg [3:0]  Pipe_Rd,
    output reg [1:0]  Pipe_Mem_Addr,
    output reg [11:0] Pipe_Addr12,
    output reg [11:0] Pipe_Pc_Plus1,
    output reg [4:0]  Pipe_Alu_Op,
    output reg Pipe_Alu_Src,
    output reg [3:0]  Pipe_Flag_Store,
    output reg Pipe_Branch,
    output reg [2:0]  Pipe_Br_Cond,
    output reg Pipe_Jump,
    output reg Pipe_Jump_Reg,
    output reg Pipe_Jump_If,
    output reg Pipe_Is_Call,
    output reg Pipe_Is_Ret,
    output reg Pipe_Halt,
    output reg Pipe_Mem_Rd,
    output reg Pipe_Mem_Wr,
    output reg Pipe_Reg_Wr,
    output reg Pipe_Wb_Sel
);

always @(posedge Clk or negedge Rst)
begin
    if (!Rst)
    begin
        Pipe_Op1       <= 32'd0;
        Pipe_Op2       <= 32'd0;
        Pipe_Imm_Ext   <= 32'd0;
        Pipe_Rd        <= 4'd0;
        Pipe_Addr12    <= 12'd0;
        Pipe_Pc_Plus1  <= 12'd0;
        Pipe_Alu_Op    <= 5'd0;
        Pipe_Alu_Src   <= 1'b0;
        Pipe_Flag_Store<= 4'd0;
        Pipe_Branch    <= 1'b0;
        Pipe_Br_Cond   <= 3'd0;
        Pipe_Jump      <= 1'b0;
        Pipe_Jump_Reg  <= 1'b0;
        Pipe_Jump_If   <= 1'b0;
        Pipe_Is_Call   <= 1'b0;
        Pipe_Is_Ret    <= 1'b0;
        Pipe_Halt      <= 1'b0;
        Pipe_Mem_Rd    <= 1'b0;
        Pipe_Mem_Wr    <= 1'b0;
        Pipe_Reg_Wr    <= 1'b0;
        Pipe_Wb_Sel    <= 1'b0;
        Pipe_Mem_Addr  <= 2'd0;
    end
    else
    begin
        if (Flush)
        begin
            // Insert bubble / NOP
            Pipe_Op1        <= 32'd0;
            Pipe_Op2        <= 32'd0;
            Pipe_Imm_Ext    <= 32'd0;
            Pipe_Rd         <= 4'd0;
            Pipe_Addr12     <= 12'd0;
            Pipe_Pc_Plus1   <= 12'd0;
            Pipe_Alu_Op     <= 5'd0;
            Pipe_Alu_Src    <= 1'b0;
            Pipe_Flag_Store <= 4'd0;
            Pipe_Branch     <= 1'b0;
            Pipe_Br_Cond    <= 3'd0;
            Pipe_Jump       <= 1'b0;
            Pipe_Jump_Reg   <= 1'b0;
            Pipe_Jump_If    <= 1'b0;
            Pipe_Is_Call    <= 1'b0;
            Pipe_Is_Ret     <= 1'b0;
            Pipe_Halt       <= 1'b0;
            Pipe_Mem_Rd     <= 1'b0;
            Pipe_Mem_Wr     <= 1'b0;
            Pipe_Reg_Wr     <= 1'b0;
            Pipe_Wb_Sel     <= 1'b0;
            Pipe_Mem_Addr   <= 2'd0;
        end
        else if (!Stall)
        begin
            Pipe_Op1        <= Op1;
            Pipe_Op2        <= Op2;
            Pipe_Imm_Ext    <= Imm_Ext;
            Pipe_Rd         <= Rd;
            Pipe_Addr12     <= Addr12;
            Pipe_Pc_Plus1   <= Pc_Plus1;
            Pipe_Alu_Op     <= Alu_Op;
            Pipe_Alu_Src    <= Alu_Src;
            Pipe_Flag_Store <= Flag_Store;
            Pipe_Branch     <= Branch;
            Pipe_Br_Cond    <= Br_Cond;
            Pipe_Jump       <= Jump;
            Pipe_Jump_Reg   <= Jump_Reg;
            Pipe_Jump_If    <= Jump_If;
            Pipe_Is_Call    <= Is_Call;
            Pipe_Is_Ret     <= Is_Ret;
            Pipe_Halt       <= Halt;
            Pipe_Mem_Rd     <= Mem_Rd;
            Pipe_Mem_Wr     <= Mem_Wr;
            Pipe_Reg_Wr     <= Reg_Wr;
            Pipe_Wb_Sel     <= Wb_Sel;
            Pipe_Mem_Addr   <= Mem_Addr;
        end
    end
end
endmodule