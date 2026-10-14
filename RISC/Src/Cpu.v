`timescale 1ns / 1ps
`default_nettype none

module Cpu #(
    parameter LINE = 64
)(
    input  wire        Clk,
    input  wire        Rst,

    // TX FIFO Interface
    output wire        Tx_Wr_En,
    output wire [47:0] Tx_Fifo_Data,
    input  wire        Tx_Fifo_Full,

    // RX FIFO Interface
    output wire        Rx_Rd_En,
    input  wire [31:0] Rx_Fifo_Data,
    input  wire        Rx_Fifo_Empty,

    output wire        Halted,

    // Program Memory Interface
    input  wire [31:0] If_Instruction,
    output wire [11:0] If_Pc
);

    // ---------------- IF ----------------
    wire [11:0] if_Pc_Plus1;

    // ---------------- ID ----------------
    wire [31:0] id_Instruction;
    wire [11:0] id_Pc_Plus1;

    wire [7:0]  id_Opcode;
    wire [3:0]  id_Rd;
    wire [3:0]  id_RegAddr1;
    wire [3:0]  id_RegAddr2;
    wire [3:0]  id_Rf_Addr1;

    wire [11:0] id_Imm12;
    wire [31:0] id_Imm_Ext;
    wire [31:0] id_Op1;
    wire [31:0] id_Op2;

    wire [4:0]  id_Alu_Op;
    wire        id_isImm;
    wire        id_Imm_pad;
    wire        id_Wb_En;
    wire        id_Wb_Sel;

    wire        id_Mem_Read;
    wire        id_Mem_Write;
    wire [1:0]  id_Mem_Addr;

    wire        id_isRd_Need;

    wire [3:0]  id_Flag_Store;

    wire        id_Jump;
    wire        id_Jump_Reg;
    wire        id_Jump_if;
    wire        id_Branch;

    wire [2:0]  id_Br_Cond;

    wire        id_Halt;
    wire        id_isCall;
    wire        id_isRet;

    wire        id_Use_Rs1;
    wire        id_Use_Rs2;

    // ---------------- EX ----------------
    wire [31:0] ex_Op1;
    wire [31:0] ex_Op2;
    wire [31:0] ex_Imm_Ext;

    wire [3:0]  ex_Rd;
    wire [1:0]  ex_Mem_Addr;

    wire [11:0] ex_Addr12;
    wire [11:0] ex_Pc_Plus1;

    wire [4:0]  ex_Alu_Op;
    wire        ex_Alu_Src;

    wire [3:0]  ex_Flag_Store;

    wire        ex_Branch;
    wire [2:0]  ex_Br_Cond;

    wire        ex_Jump;
    wire        ex_Jump_Reg;
    wire        ex_Jump_If;
    wire        ex_Is_Call;
    wire        ex_Is_Ret;
    wire        ex_Halt;

    wire        ex_Mem_Rd;
    wire        ex_Mem_Wr;
    wire        ex_Reg_Wr;
    wire        ex_Wb_Sel;

    wire [31:0] ex_Alu_B;
    wire [31:0] ex_Alu_Result;

    wire [3:0]  ex_PSR;
    wire [3:0]  ex_Flags;
    wire [3:0]  ex_Flag_Valid;

    wire [13:0] ex_Mem_Address;

    wire        ex_isBranchTaken;

    wire [11:0] ex_Target;
    wire [11:0] ex_Stack_Top;

    wire        ex_Push;
    wire        ex_Pop;

    // ---------------- MEM ----------------
    wire [31:0] mem_Alu_Result;
    wire [31:0] mem_Store_Data;

    wire [13:0] mem_Mem_Address;

    wire [3:0]  mem_Rd;

    wire        mem_Mem_Rd;
    wire        mem_Mem_Wr;
    wire        mem_Reg_Wr;
    wire        mem_Wb_Sel;

    wire [31:0] mem_Rd_Data;

    wire        mem_Done;
    wire        mem_Stall;

    // ---------------- WB ----------------
    wire [31:0] wb_Alu_Result;
    wire [31:0] wb_Rd_Data;
    wire        wb_Wb_Sel;
    wire [31:0] wb_Wb_Data;     
    wire [3:0]  wb_Rd;
    wire        wb_Reg_Wr;

    // ---------------- Hazard ----------------
    wire        hz_Hazard_Stall;

    wire        hz_Stall_IfId;
    wire        hz_Flush_IfId;

    wire        hz_Stall_IdEx;
    wire        hz_Flush_IdEx;

    wire        hz_Stall_ExMem;
    wire        hz_Stall_MemWb;


    // ================= Muxes =================
    Mux_2x1 #(4) Rf_Port1_Sel (
        .S  (id_isRd_Need),
        .I0 (id_RegAddr1),
        .I1 (id_Rd),
        .Y  (id_Rf_Addr1)
    );

    Mux_2x1 #(32) Alu_B_Sel (
        .S  (ex_Alu_Src),
        .I0 (ex_Op2),
        .I1 (ex_Imm_Ext),
        .Y  (ex_Alu_B)
    );

    Mux_4X1 #(14) Mem_Addr_Sel (
        .S0 (ex_Mem_Addr[0]),
        .S1 (ex_Mem_Addr[1]),
        .I0 ({2'b00, ex_Addr12}),
        .I1 (ex_Op1[13:0]),
        .I2 (ex_Op2[13:0]),
        .I3 ({2'b00, ex_Addr12}),
        .Y  (ex_Mem_Address)
    );

    Mux_2x1 #(32) Wb_Data_Sel (
        .S  (wb_Wb_Sel),
        .I0 (wb_Alu_Result),
        .I1 (wb_Rd_Data),
        .Y  (wb_Wb_Data)
    );


    // ================= Control glue =================
    assign ex_Push =
        ex_Is_Call && !mem_Stall;

    assign ex_Pop =
        ex_Is_Ret && !mem_Stall;

    assign ex_Flag_Valid =
        ex_Flag_Store & {4{!mem_Stall}};

    assign mem_Stall =
        (mem_Mem_Rd || mem_Mem_Wr) && !mem_Done;

    wire ex_Halt_sticky =
        ex_Halt || Halted;


    // ================= IF =================
    Pc_Unit Program_Counter (
        .Clk           (Clk),
        .Rst           (Rst),
        .Mem_Stall     (mem_Stall),
        .Hazard_Stall  (hz_Hazard_Stall),
        .Halt          (ex_Halt),
        .isBranchTaken (ex_isBranchTaken),
        .Target        (ex_Target),
        .Pc            (If_Pc),
        .Halted        (Halted),
        .Pc_Plus1      (if_Pc_Plus1)
    );

    Pipe_IF_ID Stage_IF_ID (
        .Clk             (Clk),
        .Rst             (Rst),
        .Stall           (hz_Stall_IfId),
        .Flush           (hz_Flush_IfId),

        .Instruction     (If_Instruction),
        .Pc_Plus1        (if_Pc_Plus1),

        .Pipe_Instruction(id_Instruction),
        .Pipe_Pc_Plus1   (id_Pc_Plus1)
    );


    // ================= ID =================
    Instruction_Decode decoder (
        .Instruction (id_Instruction),

        .Opcode      (id_Opcode),
        .Rd          (id_Rd),
        .RegAddr1    (id_RegAddr1),
        .RegAddr2    (id_RegAddr2),
        .Imm         (id_Imm12)
    );

    Control_Unit control (
        .Opcode       (id_Opcode),

        .Alu_Op       (id_Alu_Op),
        .isImm        (id_isImm),
        .Imm_pad      (id_Imm_pad),

        .Wb_En        (id_Wb_En),
        .Wb_Sel       (id_Wb_Sel),

        .Mem_Read     (id_Mem_Read),
        .Mem_Write    (id_Mem_Write),
        .Mem_Addr     (id_Mem_Addr),

        .isRd_Need    (id_isRd_Need),

        .Flag_Store   (id_Flag_Store),

        .Jump         (id_Jump),
        .Jump_Reg     (id_Jump_Reg),
        .Jump_if      (id_Jump_if),
        .Branch       (id_Branch),
        .Br_Cond      (id_Br_Cond),

        .Halt         (id_Halt),
        .isCall       (id_isCall),
        .isRet        (id_isRet),

        .Use_Rs1      (id_Use_Rs1),
        .Use_Rs2      (id_Use_Rs2)
    );

    Imm_padding Pad_Imm (
        .Imm_Old (id_Imm12),
        .Imm_Pad (id_Imm_pad),
        .Imm     (id_Imm_Ext)
    );

    Register_File Register_Bank (
        .Clk      (Clk),
        .Rst      (Rst),

        .RegAddr1 (id_Rf_Addr1),
        .RegAddr2 (id_RegAddr2),

        .Wr_Addr  (wb_Rd),
        .Wr_Data  (wb_Wb_Data),
        .Wr_en    (wb_Reg_Wr),

        .Op1      (id_Op1),
        .Op2      (id_Op2)
    );

    Pipe_ID_EX Stage_ID_EX (
        .Clk             (Clk),
        .Rst             (Rst),
        .Stall           (hz_Stall_IdEx),
        .Flush           (hz_Flush_IdEx),

        .Op1             (id_Op1),
        .Pipe_Op1        (ex_Op1),

        .Op2             (id_Op2),
        .Pipe_Op2        (ex_Op2),

        .Imm_Ext         (id_Imm_Ext),
        .Pipe_Imm_Ext    (ex_Imm_Ext),

        .Rd              (id_Rd),
        .Pipe_Rd         (ex_Rd),

        .Mem_Addr        (id_Mem_Addr),
        .Pipe_Mem_Addr   (ex_Mem_Addr),

        .Addr12          (id_Imm12),
        .Pipe_Addr12     (ex_Addr12),

        .Pc_Plus1        (id_Pc_Plus1),
        .Pipe_Pc_Plus1   (ex_Pc_Plus1),

        .Alu_Op          (id_Alu_Op),
        .Pipe_Alu_Op     (ex_Alu_Op),

        .Alu_Src         (id_isImm),
        .Pipe_Alu_Src    (ex_Alu_Src),

        .Flag_Store      (id_Flag_Store),
        .Pipe_Flag_Store (ex_Flag_Store),

        .Branch          (id_Branch),
        .Pipe_Branch     (ex_Branch),

        .Br_Cond         (id_Br_Cond),
        .Pipe_Br_Cond    (ex_Br_Cond),

        .Jump            (id_Jump),
        .Pipe_Jump       (ex_Jump),

        .Jump_Reg        (id_Jump_Reg),
        .Pipe_Jump_Reg   (ex_Jump_Reg),

        .Jump_If         (id_Jump_if),
        .Pipe_Jump_If    (ex_Jump_If),

        .Is_Call         (id_isCall),
        .Pipe_Is_Call    (ex_Is_Call),

        .Is_Ret          (id_isRet),
        .Pipe_Is_Ret     (ex_Is_Ret),

        .Halt            (id_Halt),
        .Pipe_Halt       (ex_Halt),

        .Mem_Rd          (id_Mem_Read),
        .Pipe_Mem_Rd     (ex_Mem_Rd),

        .Mem_Wr          (id_Mem_Write),
        .Pipe_Mem_Wr     (ex_Mem_Wr),

        .Reg_Wr          (id_Wb_En),
        .Pipe_Reg_Wr     (ex_Reg_Wr),

        .Wb_Sel          (id_Wb_Sel),
        .Pipe_Wb_Sel     (ex_Wb_Sel)
    );


    // ================= EX =================
    Alu_Unit Alu (
        .Op1       (ex_Op1),
        .Op2       (ex_Alu_B),
        .Alu_Op    (ex_Alu_Op),
        .PSR       (ex_PSR),
        .Alu_Result(ex_Alu_Result)
    );

    Flag_Store Flag (
        .Clk         (Clk),
        .Rst         (Rst),
        .PSR         (ex_PSR),
        .Flags_Valid (ex_Flag_Valid),
        .Flags       (ex_Flags)
    );

    Stack Call_Stack (
        .Clk   (Clk),
        .Rst   (Rst),
        .Push  (ex_Push),
        .Pop   (ex_Pop),
        .Din   (ex_Pc_Plus1),
        .Top   (ex_Stack_Top)
    );

    Branch_Unit Branch_Control (
        .PSR            (ex_Flags),

        .Jump           (ex_Jump),
        .Jump_Reg       (ex_Jump_Reg),
        .Jump_If        (ex_Jump_If),
        .Branch         (ex_Branch),

        .Br_Cond        (ex_Br_Cond),

        .Is_Call        (ex_Is_Call),
        .Is_Ret         (ex_Is_Ret),

        .Op1            (ex_Op1),
        .Addr           (ex_Addr12),
        .Stack_Top      (ex_Stack_Top),

        .isBranchTaken  (ex_isBranchTaken),
        .Target         (ex_Target)
    );

    Pipe_EX_MEM Stage_EX_MEM (
        .Clk             (Clk),
        .Rst             (Rst),
        .Stall           (hz_Stall_ExMem),

        .Alu_Result      (ex_Alu_Result),
        .Pipe_Alu_Result (mem_Alu_Result),

        .Store_Data      (ex_Op1),
        .Pipe_Store_Data (mem_Store_Data),

        .Mem_Address     (ex_Mem_Address),
        .Pipe_Mem_Address(mem_Mem_Address),

        .Rd              (ex_Rd),
        .Pipe_Rd         (mem_Rd),

        .Mem_Rd          (ex_Mem_Rd),
        .Pipe_Mem_Rd     (mem_Mem_Rd),

        .Mem_Wr          (ex_Mem_Wr),
        .Pipe_Mem_Wr     (mem_Mem_Wr),

        .Reg_Wr          (ex_Reg_Wr),
        .Pipe_Reg_Wr     (mem_Reg_Wr),

        .Wb_Sel          (ex_Wb_Sel),
        .Pipe_Wb_Sel     (mem_Wb_Sel)
    );


    // ================= MEM =================
    Cache #(LINE) L1 (
        .Clk          (Clk),
        .Rst          (Rst),

        .Read_En      (mem_Mem_Rd),
        .Write_En     (mem_Mem_Wr),

        .Addr         (mem_Mem_Address),
        .Wr_Data      (mem_Store_Data),
        .Rd_Data      (mem_Rd_Data),

        .Tx_Wr_En     (Tx_Wr_En),
        .Tx_Fifo_Data (Tx_Fifo_Data),
        .Tx_Fifo_Full (Tx_Fifo_Full),

        .Rx_Fifo_Empty(Rx_Fifo_Empty),
        .Rx_Fifo_Data (Rx_Fifo_Data),
        .Rx_Rd_En     (Rx_Rd_En),
        .Done         (mem_Done)
    );


    // ================= MEM/WB =================
    Pipe_MEM_WB Stage_MEM_WB (
        .Clk             (Clk),
        .Rst             (Rst),
        .Stall           (hz_Stall_MemWb),

        .Alu_Result      (mem_Alu_Result),
        .Rd_Data         (mem_Rd_Data),
        .Wb_Sel          (mem_Wb_Sel),
        .Rd              (mem_Rd),
        .Reg_Wr          (mem_Reg_Wr),

        .Pipe_Alu_Result (wb_Alu_Result),
        .Pipe_Rd_Data    (wb_Rd_Data),
        .Pipe_Wb_Sel     (wb_Wb_Sel),
        .Pipe_Rd         (wb_Rd),
        .Pipe_Reg_Wr     (wb_Reg_Wr)
    );


    // ================= Hazard =================
    Hazard_Unit Hazard_Control (
        .Rs1          (id_RegAddr1),
        .Rs2          (id_RegAddr2),
        .Rd_Src       (id_Rd),

        .Use_Rs1      (id_Use_Rs1),
        .Use_Rs2      (id_Use_Rs2),
        .Use_Rd_Src   (id_isRd_Need),

        .IdEx_Rd      (ex_Rd),
        .IdEx_Reg_Wr  (ex_Reg_Wr),

        .ExMem_Rd     (mem_Rd),
        .ExMem_Reg_Wr (mem_Reg_Wr),

        .MemWb_Rd     (wb_Rd),
        .MemWb_Reg_Wr (wb_Reg_Wr),

        .Mem_Stall    (mem_Stall),
        .isBranchTaken(ex_isBranchTaken),
        .Halt         (ex_Halt_sticky),

        .Hazard_Stall (hz_Hazard_Stall),

        .Stall_IfId   (hz_Stall_IfId),
        .Flush_IfId   (hz_Flush_IfId),

        .Stall_IdEx   (hz_Stall_IdEx),
        .Flush_IdEx   (hz_Flush_IdEx),

        .Stall_ExMem  (hz_Stall_ExMem),
        .Stall_MemWb  (hz_Stall_MemWb)
    );

endmodule