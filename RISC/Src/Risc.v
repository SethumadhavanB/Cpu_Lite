`timescale 1ns / 1ps
`default_nettype none

module Risc #(
    parameter LINE = 64
)(
    input  wire        Clk_Fast,
    input  wire        Clk_Slow,
    input  wire        Rst,

    output wire        Halted,

    output wire [11:0] Prog_Addr,
    input  wire [31:0] Prog_Data,

    output wire        Data_Wr_En,
    output wire        Data_Rd_En,
    output wire [13:0] Data_Addr,
    output wire [31:0] Data_Wr_Data,
    input  wire [31:0] Data_Rd_Data
);

    wire        cpu_Tx_Wr_En;
    wire [47:0] cpu_Tx_Fifo_Data;
    wire        cpu_Tx_Fifo_Full;

    wire        cpu_Rx_Rd_En;
    wire [31:0] cpu_Rx_Fifo_Data;
    wire        cpu_Rx_Fifo_Empty;

    wire        hnd_Tx_Rd_En;
    wire [47:0] hnd_Cache_Data;
    wire        hnd_Tx_Fifo_Empty;

    wire        hnd_Rx_Wr_En;
    wire [31:0] hnd_Fifo_Wr_Data;
    wire        hnd_Rx_Fifo_Full;

    wire        mem_Wr_En;
    wire        mem_Rd_En;
    wire [13:0] mem_Addr;
    wire [31:0] mem_Wr_Data;
    wire [31:0] mem_Rd_Data;
   


   wire RSt_Ft,RSt_Sl;
   Reset_Sync Fast(.clk(Clk_Fast),.reset_n(Rst),.reset_sync_n(RSt_Ft));
   Reset_Sync Slow(.clk(Clk_Slow),.reset_n(Rst),.reset_sync_n(RSt_Sl));


   wire cpu_Tx_Fifo_Full_Async,cpu_Rx_Fifo_Empty_Asyn;
   d_ff Tx_full (.clk(Clk_Fast),.rst_n(Rst),.d(cpu_Tx_Fifo_Full),.q(cpu_Tx_Fifo_Full_Async));
   d_ff Rx_Empty (.clk(Clk_Fast),.rst_n(Rst),.d(cpu_Rx_Fifo_Empty),.q(cpu_Rx_Fifo_Empty_Asyn));


    Cpu #(
        .LINE (LINE)
    ) Cpu (
        .Clk           (Clk_Fast),
        .Rst           (RSt_Ft),
        .Tx_Wr_En      (cpu_Tx_Wr_En),
        .Tx_Fifo_Data  (cpu_Tx_Fifo_Data),
        .Tx_Fifo_Full  (cpu_Tx_Fifo_Full_Async),
        .Rx_Rd_En      (cpu_Rx_Rd_En),
        .Rx_Fifo_Data  (cpu_Rx_Fifo_Data),
        .Rx_Fifo_Empty (cpu_Rx_Fifo_Empty_Asyn),
        .Halted        (Halted),
        .If_Instruction(Prog_Data),
        .If_Pc         (Prog_Addr)
    );

    Async_FIFO #(
        .DEPTH (4),
        .WIDTH (48)
    ) Tx_Fifo (
        .wr_clk (Clk_Fast),
        .wr_rst (RSt_Ft),
        .wr_en  (cpu_Tx_Wr_En),
        .din    (cpu_Tx_Fifo_Data),
        .rd_clk (Clk_Slow),
        .rd_rst (RSt_Sl),
        .rd_en  (hnd_Tx_Rd_En),
        .dout   (hnd_Cache_Data),
        .Full   (cpu_Tx_Fifo_Full),
        .Empty  (hnd_Tx_Fifo_Empty)
    );

    Async_FIFO #(
        .DEPTH (4),
        .WIDTH (32)
    ) Rx_Fifo (
        .wr_clk (Clk_Slow),
        .wr_rst (RSt_Sl),
        .wr_en  (hnd_Rx_Wr_En),
        .din    (hnd_Fifo_Wr_Data),
        .rd_clk (Clk_Fast),
        .rd_rst (RSt_Ft),
        .rd_en  (cpu_Rx_Rd_En),
        .dout   (cpu_Rx_Fifo_Data),
        .Full   (hnd_Rx_Fifo_Full),
        .Empty  (cpu_Rx_Fifo_Empty)
    );

    Fifo_Handler Handler (
        .Clk           (Clk_Slow),
        .Rst           (RSt_Sl),
        .Cache_Data    (hnd_Cache_Data),
        .Tx_Fifo_Empty (hnd_Tx_Fifo_Empty),
        .Tx_Rd_En      (hnd_Tx_Rd_En),
        .Fifo_Wr_Data  (hnd_Fifo_Wr_Data),
        .Rx_Wr_En      (hnd_Rx_Wr_En),
        .Rx_Fifo_Full  (hnd_Rx_Fifo_Full),
        .Wr_En         (mem_Wr_En),
        .Rd_En         (mem_Rd_En),
        .Wr_Data       (mem_Wr_Data),
        .Addr          (mem_Addr),
        .Mem_Rd_Data   (mem_Rd_Data)
    );

    assign Data_Wr_En   = mem_Wr_En;
    assign Data_Rd_En   = mem_Rd_En;
    assign Data_Addr    = mem_Addr;
    assign Data_Wr_Data = mem_Wr_Data;

    assign mem_Rd_Data  = Data_Rd_Data;

endmodule