`timescale 1ns / 1ps
`default_nettype none
module Branch_Unit (
    input  wire [3:0]  PSR,
    input  wire Jump,
    input  wire Jump_Reg,
    input  wire Jump_If,
    input  wire Branch,
    input  wire [2:0]  Br_Cond,
    input  wire  Is_Call,
    input  wire  Is_Ret,
    input  wire [31:0] Op1,
    input  wire [11:0] Addr,
    input  wire [11:0] Stack_Top,
    output reg  isBranchTaken,
    output reg [11:0]  Target
);

    wire Z = PSR[0];
    wire N = PSR[1];
    wire C = PSR[2];
    wire V = PSR[3];

    always @(*) begin
        isBranchTaken = 1'b0;
        Target = Addr;

        if (Jump || Is_Call) begin
            isBranchTaken = 1'b1;
        end
        else if (Jump_Reg) begin
            isBranchTaken = 1'b1;
            Target        = Op1[11:0];
        end
        else if (Is_Ret) begin
            isBranchTaken = 1'b1;
            Target= Stack_Top;
        end
        else if (Jump_If) begin
            isBranchTaken = (Op1 != 32'd0) ? 1'b1 : 1'b0;
        end
        else if (Branch) begin
            case (Br_Cond)
                3'd0: isBranchTaken = Z ? 1'b1 : 1'b0;
                3'd1: isBranchTaken = ~Z ? 1'b1 : 1'b0;
                3'd2: isBranchTaken = (N ^ V) ? 1'b1 : 1'b0;
                3'd3: isBranchTaken = ~(N ^ V) ? 1'b1 : 1'b0;
                3'd4: isBranchTaken = ~C ? 1'b1 : 1'b0;
                3'd5: isBranchTaken = C ? 1'b1 : 1'b0;
                default: isBranchTaken = 1'b0;
            endcase
        end
    end

endmodule