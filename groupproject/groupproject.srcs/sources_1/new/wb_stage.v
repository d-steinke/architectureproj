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
// Description: WB Stage - Writeback: selects write data and controls register write
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Selects between ALU result and memory data based on mem_to_reg signal
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

    // Parameter for SVPC opcode
    parameter OP_SVPC = 4'b1111;

    // Select write register based on opcode
    // SVPC writes to rt, all other instructions write to rd
    assign wb_write_reg = (wb_opcode == OP_SVPC) ? wb_rt : wb_rd;
    
    // Select write data: memory data (LD) or ALU result (everything else)
    assign wb_write_data = (wb_mem_to_reg) ? wb_mem_data : wb_alu_result;
    
    // Pass through write enable
    assign wb_write_en = wb_reg_write;

endmodule

