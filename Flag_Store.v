`timescale 1ns / 1ps
`default_nettype none
module Flag_Store (
    input wire Clk,
    input wire Rst,
    input wire [3:0] PSR,
    input wire [3:0] Flags_Valid,
    output reg [3:0] Flags
);


always @(posedge Clk or negedge Rst)
begin
    if (!Rst)
        Flags <= 4'b0000;
    else
    begin
        if (Flags_Valid[0]) Flags[0] <= PSR[0];   
        if (Flags_Valid[1]) Flags[1] <= PSR[1];  
        if (Flags_Valid[2]) Flags[2] <= PSR[2];   
        if (Flags_Valid[3]) Flags[3] <= PSR[3];   
    end
end
    
endmodule