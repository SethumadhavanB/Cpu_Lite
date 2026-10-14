`timescale 1ns / 1ps
`default_nettype none
module Program_Mem #(parameter  Comment = "program.mem")(
    input  wire [11:0] Addr,
    output wire  [31:0] Instruction
);

reg [31:0] Mem [0:4095];
initial begin
    $readmemh(Comment, Mem);
end

assign Instruction = Mem[Addr];
endmodule