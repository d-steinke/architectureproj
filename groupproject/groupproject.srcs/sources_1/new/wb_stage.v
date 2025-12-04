`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: wb_stage
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



module wb_stage (
    input wire [31:0] wb_alu_result,
    input wire [31:0] wb_mem_data,
    input wire [5:0] wb_rd,
    input wire [5:0] wb_rt,
    input wire [3:0] wb_opcode,
    input wire wb_reg_write,
    input wire wb_mem_to_reg,
    
    output wire [5:0] wb_write_reg,
    output wire [31:0] wb_write_data,
    output wire wb_write_en
);
    assign wb_write_reg = wb_rd; 
    
    assign wb_write_data = (wb_mem_to_reg) ? wb_mem_data : wb_alu_result;
    assign wb_write_en = wb_reg_write;
    
endmodule
