`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: exwb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: EX/WB Pipeline Register - buffers execute stage outputs to writeback stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module exwb (
    input wire clk,
    input wire rst,
    input wire flush,  // Flush signal from branch/jump
    input wire [31:0] ex_alu_result,
    input wire [31:0] ex_mem_data,
    input wire [5:0] ex_rd,
    input wire [5:0] ex_rt,
    input wire [3:0] ex_opcode,
    input wire ex_zero_flag,
    input wire ex_neg_flag,
    input wire ex_reg_write,
    input wire ex_mem_to_reg,
    input wire ex_preserve_flags,
    
    // ADDED: Input for mem_write signal
    input wire ex_mem_write, 

    output reg [31:0] wb_alu_result,
    output reg [31:0] wb_mem_data,
    output reg [5:0] wb_rd,
    output reg [5:0] wb_rt,
    output reg [3:0] wb_opcode,
    output reg wb_zero_flag,
    output reg wb_neg_flag,
    output reg wb_reg_write,
    output reg wb_mem_to_reg,
    
    // ADDED: Output for mem_write signal
    output reg wb_mem_write
);

    always @(negedge clk) begin
        if (rst || flush) begin
            // Reset or flush: prevent writes
            wb_alu_result <= 0;
            wb_mem_data <= 0;
            wb_rd <= 0;
            wb_rt <= 0;
            wb_opcode <= 4'b0000;  // NOP opcode
            // Don't update flags on flush
            wb_reg_write <= 0;  // Critical: prevent register writes
            wb_mem_to_reg <= 0;
            wb_mem_write <= 0;  // Critical: prevent memory writes
        end else begin
            wb_alu_result <= ex_alu_result;
            wb_mem_data <= ex_mem_data;
            wb_rd <= ex_rd;
            wb_rt <= ex_rt;
            wb_opcode <= ex_opcode;
            // Update flags only if preserve_flags is NOT set (i.e., not a NOP)
            if (!ex_preserve_flags) begin
                wb_zero_flag <= ex_zero_flag;
                wb_neg_flag <= ex_neg_flag;
            end
            wb_reg_write <= ex_reg_write;
            wb_mem_to_reg <= ex_mem_to_reg;
            wb_mem_write <= ex_mem_write;
        end
    end

endmodule
