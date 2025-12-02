`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 05:57:35 PM
// Design Name: 
// Module Name: ifid
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


module ifid(
    input wire clk,
    input wire flush,                   // Flush signal: 1 = squash instruction
    input wire [31:0] instr_in,
    input wire [31:0] pc_in,
    
    output reg [31:0] instr_out,
    output reg [31:0] pc_out
    );
    always@(negedge clk) begin
        if (flush) begin
            // Squash instruction: output NOP (opcode 0000)
            instr_out <= 32'h00000000;
            pc_out <= pc_in;
        end else begin
            instr_out <= instr_in;
            pc_out <= pc_in;
        end
    end
endmodule
