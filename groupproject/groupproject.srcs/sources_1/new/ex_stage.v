`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2025 05:56:46 PM
// Design Name: 
// Module Name: ex_stage
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




module ex_stage(
    input wire [31:0] id_ex_pc,        
    input wire [31:0] id_ex_reg_data1, 
    input wire [31:0] id_ex_reg_data2, 
    input wire [31:0] id_ex_imm,       
    input wire [3:0] id_ex_opcode,
    
    // Control Signals
    input wire alu_src_a,            
    input wire alu_src_b,          
    input wire [2:0] alu_op,          
    input wire id_ex_mem_write,
    input wire preserve_flags,
    input wire prev_zero_flag,
    input wire prev_neg_flag,
    
    output wire [31:0] ex_alu_result,  
    output wire [31:0] ex_write_data,  
    output wire [31:0] ex_branch_target, 
    output wire zero_flag,            
    output wire neg_flag
);

    wire [31:0] alu_operand_a; 
    wire [31:0] alu_operand_b;
    wire alu_zero;
    wire alu_neg;

    mux EX_ALU_MUX_A (
        .in0(id_ex_reg_data1), 
        .in1(id_ex_pc),        
        .sel(alu_src_a),
        .out(alu_operand_a)
    );

    mux EX_ALU_MUX_B (
        .in0(id_ex_reg_data2),
        .in1(id_ex_imm),
        .sel(alu_src_b),
        .out(alu_operand_b)
    );

    alu EX_ALU (
        .a(alu_operand_a),     
        .b(alu_operand_b),     
        .alu_control(alu_op),  
        .result(ex_alu_result),
        .zero(alu_zero),
        .negative(alu_neg)
    );
    
    assign zero_flag = preserve_flags ? prev_zero_flag : alu_zero;
    assign neg_flag = preserve_flags ? prev_neg_flag : alu_neg;
    
    assign ex_branch_target = id_ex_reg_data1; 
    
    assign ex_write_data = id_ex_reg_data2;

endmodule