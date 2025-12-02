`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: idex
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: ID/EX Pipeline Register - buffers decode stage outputs to execute stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module idex (
    input wire clk,
    input wire rst,
    
    // From ID Stage
    input wire [31:0] id_pc,
    input wire [31:0] id_reg_data1,
    input wire [31:0] id_reg_data2,
    input wire [31:0] id_imm,
    input wire [5:0] id_rd,
    input wire [5:0] id_rs,
    input wire [5:0] id_rt,
    input wire [3:0] id_opcode,
    
    // Control Signals from ID Stage
    input wire id_reg_write,
    input wire id_mem_to_reg,
    input wire id_mem_write,
    input wire id_alu_src,
    input wire [2:0] id_alu_op,
    input wire id_branch,
    input wire id_jump,
    
    // To EX Stage
    output reg [31:0] ex_pc,
    output reg [31:0] ex_reg_data1,
    output reg [31:0] ex_reg_data2,
    output reg [31:0] ex_imm,
    output reg [5:0] ex_rd,
    output reg [5:0] ex_rs,
    output reg [5:0] ex_rt,
    output reg [3:0] ex_opcode,
    
    // Control Signals to EX Stage
    output reg ex_reg_write,
    output reg ex_mem_to_reg,
    output reg ex_mem_write,
    output reg ex_alu_src,
    output reg [2:0] ex_alu_op,
    output reg ex_branch,
    output reg ex_jump
);

    always @(posedge clk) begin
        if (rst) begin
            ex_pc <= 32'd0;
            ex_reg_data1 <= 32'd0;
            ex_reg_data2 <= 32'd0;
            ex_imm <= 32'd0;
            ex_rd <= 6'd0;
            ex_rs <= 6'd0;
            ex_rt <= 6'd0;
            
            ex_reg_write <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_mem_write <= 1'b0;
            ex_alu_src <= 1'b0;
            ex_alu_op <= 3'b000;
            ex_branch <= 1'b0;
            ex_jump <= 1'b0;
        end else begin
            ex_pc <= id_pc;
            ex_reg_data1 <= id_reg_data1;
            ex_reg_data2 <= id_reg_data2;
            ex_imm <= id_imm;
            ex_rd <= id_rd;
            ex_rs <= id_rs;
            ex_rt <= id_rt;
            
            ex_reg_write <= id_reg_write;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_mem_write <= id_mem_write;
            ex_alu_src <= id_alu_src;
            ex_alu_op <= id_alu_op;
            ex_branch <= id_branch;
            ex_jump <= id_jump;
            ex_opcode <= id_opcode;
            // Debug: show values latched into ID/EX
            $display("IDEX @%0t latched PC=%h instr_fields rd=%0d rs=%0d rt=%0d imm=%0d (%h) opc=%b regw=%b memtoreg=%b", $time, id_pc, id_rd, id_rs, id_rt, $signed(id_imm), id_imm, id_opcode, id_reg_write, id_mem_to_reg);
        end
    end

endmodule

