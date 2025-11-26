`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:49:58 PM
// Design Name: 
// Module Name: immgen
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



module immgen(
    input wire [31:0] instruction,
    output reg [31:0] imm_out
);

    always @(*) begin
        if (instruction[31]) begin
            imm_out = {22'b1111111111111111111111, instruction[31:22]};
        end else begin
            imm_out = {22'b0000000000000000000000, instruction[31:22]};
        end
    end

endmodule
