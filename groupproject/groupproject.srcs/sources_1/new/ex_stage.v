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
    input wire alu_src_a,             // 0=Reg, 1=PC
    input wire alu_src_b,             // 0=Reg, 1=Imm
    input wire [2:0] alu_op,          
    input wire id_ex_mem_write,
    
    output wire [31:0] ex_alu_result,  
    output wire [31:0] ex_write_data,  
    output wire [31:0] ex_branch_target, 
    output wire zero_flag,            
    output wire neg_flag
);

    wire [31:0] alu_operand_a; 
    wire [31:0] alu_operand_b;

    // --- MUX A ---
    // Selects between Register Data 1 and PC (for SVPC)
    mux EX_ALU_MUX_A (
        .in0(id_ex_reg_data1), 
        .in1(id_ex_pc),        
        .sel(alu_src_a),
        .out(alu_operand_a)
    );

    // --- MUX B ---
    // Selects between Register Data 2 and Immediate
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
        .zero(zero_flag),
        .negative(neg_flag)
    );
    
    // Branch Target is simply the register value (Absolute Jump)
    assign ex_branch_target = id_ex_reg_data1; 
    
    assign ex_write_data = id_ex_reg_data2;

endmodule