`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: mem_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: MEM Stage - Memory Access (for LD/ST instructions)
// 
// Dependencies: dmem
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mem_stage (
    input wire clk,
    
    // From EX/WB Pipeline
    input wire [31:0] ex_alu_result,
    input wire [31:0] ex_write_data,
    input wire [5:0] ex_rd,
    input wire [5:0] ex_rt,
    input wire [3:0] ex_opcode,
    input wire ex_zero_flag,
    input wire ex_neg_flag,
    input wire ex_reg_write,
    input wire ex_mem_to_reg,
    input wire ex_mem_write,
    
    // To EX/WB Pipeline (same signals, just renamed)
    output wire [31:0] mem_alu_result,
    output wire [31:0] mem_read_data,
    output wire [5:0] mem_rd,
    output wire [5:0] mem_rt,
    output wire [3:0] mem_opcode,
    output wire mem_zero_flag,
    output wire mem_neg_flag,
    output wire mem_reg_write,
    output wire mem_mem_to_reg
);

    // Data memory
    dmem DATA_MEM (
        .clk(clk),
        .address(ex_alu_result),      // Use ALU result as address
        .write_data(ex_write_data),    // Write ST data
        .mem_write(ex_mem_write),      // Write enable for ST
        .read_data(mem_read_data)      // Output for LD
    );

    // Pass through non-memory signals
    assign mem_alu_result = ex_alu_result;
    assign mem_rd = ex_rd;
    assign mem_rt = ex_rt;
    assign mem_opcode = ex_opcode;
    assign mem_zero_flag = ex_zero_flag;
    assign mem_neg_flag = ex_neg_flag;
    assign mem_reg_write = ex_reg_write;
    assign mem_mem_to_reg = ex_mem_to_reg;

endmodule

