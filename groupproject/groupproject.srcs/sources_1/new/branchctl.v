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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module branchctl (
    input wire [3:0] opcode,      
    input wire zero_flag,          
    input wire neg_flag,           
    output reg branch_taken        
);

    parameter OP_BRZ = 4'b1001;
    parameter OP_BRN = 4'b1010;

    always @(*) begin
        case (opcode)
            OP_BRZ: begin
                branch_taken = zero_flag;
            end
            
            OP_BRN: begin
                branch_taken = neg_flag;
            end
            
            default: begin
                branch_taken = 1'b0;
            end
        endcase
    end

endmodule
