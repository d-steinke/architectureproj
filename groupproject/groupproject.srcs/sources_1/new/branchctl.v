`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: branchctl
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Branch Control - determines if a conditional branch (BRZ/BRN) should be taken
//              based on flags from the previous instruction
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// BRZ (opcode 1001): Branch if Zero flag = 0 (result was zero)
// BRN (opcode 1010): Branch if Negative flag = 1 (result was negative)
// 
//////////////////////////////////////////////////////////////////////////////////


module branchctl (
    input wire [3:0] opcode,      // Current instruction opcode
    input wire zero_flag,          // Zero flag from previous instruction (in EX/WB stage)
    input wire neg_flag,           // Negative flag from previous instruction (in EX/WB stage)
    output reg branch_taken        // 1 = take branch, 0 = don't take branch
);

    parameter OP_BRZ = 4'b1001;
    parameter OP_BRN = 4'b1010;

    always @(*) begin
        case (opcode)
            OP_BRZ: begin
                // BRZ: branch if result WAS zero (z=0 in truth table means Z flag was 0)
                branch_taken = ~zero_flag;
            end
            
            OP_BRN: begin
                // BRN: branch if result WAS negative (n=1 in truth table means N flag was 1)
                branch_taken = neg_flag;
            end
            
            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end

endmodule

