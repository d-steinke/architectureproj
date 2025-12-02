`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: forwarding
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Data Forwarding Unit - Resolves data hazards by forwarding
//              ALU results to ALU inputs, bypassing register file delays
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Forwarding paths:
// 1. EX/WB -> EX (from previous ALU result)
// 2. MEM -> EX (from current memory result)
// 
//////////////////////////////////////////////////////////////////////////////////


module forwarding (
    input wire [5:0] id_ex_rs,           // RS of current instruction
    input wire [5:0] id_ex_rt,           // RT of current instruction
    input wire [5:0] ex_wb_rd,           // Destination register of previous instruction
    input wire ex_wb_reg_write,          // Write enable of previous instruction
    input wire [5:0] mem_rd,             // Destination register of instruction before previous
    input wire mem_reg_write,            // Write enable of instruction before previous
    
    input wire [31:0] id_ex_reg_data1,   // RS data from register file
    input wire [31:0] id_ex_reg_data2,   // RT data from register file
    input wire [31:0] ex_wb_alu_result,  // ALU result from previous instruction
    input wire [31:0] mem_alu_result,    // ALU result from 2 instructions ago (for load)
    
    output wire [31:0] alu_input1,       // Forwarded RS value
    output wire [31:0] alu_input2        // Forwarded RT value
);

    // Forward RS (id_ex_rs)
    assign alu_input1 = 
        // Forward from EX/WB if RS matches destination and write is enabled
        (id_ex_rs == ex_wb_rd && ex_wb_reg_write && id_ex_rs != 0) ? ex_wb_alu_result :
        // Forward from MEM if RS matches destination and write is enabled
        (id_ex_rs == mem_rd && mem_reg_write && id_ex_rs != 0) ? mem_alu_result :
        // Otherwise, use value from register file
        id_ex_reg_data1;

    // Forward RT (id_ex_rt)
    assign alu_input2 = 
        // Forward from EX/WB if RT matches destination and write is enabled
        (id_ex_rt == ex_wb_rd && ex_wb_reg_write && id_ex_rt != 0) ? ex_wb_alu_result :
        // Forward from MEM if RT matches destination and write is enabled
        (id_ex_rt == mem_rd && mem_reg_write && id_ex_rt != 0) ? mem_alu_result :
        // Otherwise, use value from register file
        id_ex_reg_data2;

endmodule

