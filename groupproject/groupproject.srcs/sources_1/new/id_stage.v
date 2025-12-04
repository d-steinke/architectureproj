`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: id_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ID Stage - Instruction Decode and Register Read
// 
// Dependencies: controlunit, regfile, immgen
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module id_stage (
    input wire clk,
    input wire rst,
    input wire [31:0] if_id_instr,
    input wire [31:0] if_id_pc,
    input wire wb_reg_write,
    input wire [5:0] wb_write_reg,
    input wire [31:0] wb_write_data,
    
    output wire [31:0] id_pc,
    output wire [31:0] id_reg_data1,
    output wire [31:0] id_reg_data2,
    output wire [31:0] id_imm,
    output wire [5:0] id_rd,
    output wire [5:0] id_rs,
    output wire [5:0] id_rt,
    output wire [3:0] id_opcode,
    
    output wire id_reg_write,
    output wire id_mem_to_reg,
    output wire id_mem_write,
    output wire id_alu_src_a,
    output wire id_alu_src_b,
    output wire [2:0] id_alu_op,
    output wire id_branch,
    output wire id_jump,
    output wire id_preserve_flags
);

    // Instruction format: [31:22]=y [21:16]=rd [15:10]=rs [9:4]=rt [3:0]=opcode
    wire [3:0] opcode = if_id_instr[3:0];
    wire [5:0] rt = if_id_instr[9:4];
    wire [5:0] rs = if_id_instr[15:10];
    wire [5:0] rd = if_id_instr[21:16];
    wire [9:0] imm  = if_id_instr[31:22];
    
    // All instructions use rs for read_reg1
    wire [5:0] read_reg1_sel = rs;

    assign id_pc = if_id_pc;
    assign id_rs = rs;
    assign id_rt = rt;
    assign id_rd = rd;
    assign id_opcode = opcode;

    controlunit ID_CONTROL (
        .opcode(opcode),
        .reg_write(id_reg_write),
        .mem_to_reg(id_mem_to_reg),
        .mem_write(id_mem_write),
        .alu_src_a(id_alu_src_a),
        .alu_src_b(id_alu_src_b),
        .alu_op(id_alu_op),
        .branch(id_branch),
        .jump(id_jump),
        .preserve_flags(id_preserve_flags)
    );

    regfile ID_REG_FILE (
        .clk(clk),
        .rst(rst),
        .reg_write_en(wb_reg_write),
        .read_reg1(read_reg1_sel),
        .read_reg2(rt),
        .write_reg(wb_write_reg),
        .write_data(wb_write_data),
        .read_data1(id_reg_data1),
        .read_data2(id_reg_data2)
    );

    immgen ID_IMM_GEN (
        .instruction(if_id_instr),
        .imm_out(id_imm)
    );

endmodule

