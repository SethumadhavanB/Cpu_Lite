`timescale 1ns / 1ps
`default_nettype none

module Hazard_Unit (
    input  wire [3:0] Rs1,
    input  wire [3:0] Rs2,
    input  wire [3:0] Rd_Src,
    input  wire       Use_Rs1,
    input  wire       Use_Rs2,
    input  wire       Use_Rd_Src,

    input  wire [3:0] IdEx_Rd,
    input  wire       IdEx_Reg_Wr,

    input  wire [3:0] ExMem_Rd,
    input  wire       ExMem_Reg_Wr,

    input  wire [3:0] MemWb_Rd,
    input  wire       MemWb_Reg_Wr,

    input  wire       Mem_Stall,
    input  wire       isBranchTaken,
    input  wire       Halt,

    output wire       Hazard_Stall,
    output wire       Stall_IfId,
    output wire       Flush_IfId,
    output wire       Stall_IdEx,
    output wire       Flush_IdEx,
    output wire       Stall_ExMem,
    output wire       Stall_MemWb
);

    wire Match_IdEx  = IdEx_Reg_Wr  && ( (Use_Rs1 && (IdEx_Rd  == Rs1)) || (Use_Rs2 && (IdEx_Rd  == Rs2)) || (Use_Rd_Src && (IdEx_Rd  == Rd_Src)) );

    wire Match_ExMem = ExMem_Reg_Wr && ( (Use_Rs1 && (ExMem_Rd == Rs1)) || (Use_Rs2 && (ExMem_Rd == Rs2)) || (Use_Rd_Src && (ExMem_Rd == Rd_Src)) );

    wire Match_MemWb = MemWb_Reg_Wr && ( (Use_Rs1 && (MemWb_Rd == Rs1)) || (Use_Rs2 && (MemWb_Rd == Rs2)) || (Use_Rd_Src && (MemWb_Rd == Rd_Src)) );

    assign Hazard_Stall = Match_IdEx || Match_ExMem || Match_MemWb;

    wire Kill = isBranchTaken || Halt;

    assign Stall_IfId  = Hazard_Stall || Mem_Stall;
    assign Stall_IdEx  = Mem_Stall;
    assign Stall_ExMem = Mem_Stall;
    assign Stall_MemWb = Mem_Stall;

    assign Flush_IfId  =  Kill && !Mem_Stall;
    assign Flush_IdEx  = (Kill || Hazard_Stall)  && !Mem_Stall;

endmodule