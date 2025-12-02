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
    
    input wire alu_src,               
    input wire [2:0] alu_op,          
    input wire id_ex_mem_write, // New input for debugging
    
    output wire [31:0] ex_alu_result,  
    output wire [31:0] ex_write_data,  
    output wire [31:0] ex_branch_target, 
    output wire zero_flag,            
    output wire neg_flag            
);

    wire [31:0] alu_operand_b;
    wire [31:0] alu_result_wire;
    parameter OP_SVPC = 4'b1111;

    mux EX_ALU_MUX (
        .in0(id_ex_reg_data2),
        .in1(id_ex_imm),
        .sel(alu_src),
        .out(alu_operand_b)
    );

   alu EX_ALU (
        .a(id_ex_reg_data1),    
        .b(alu_operand_b),     
        .alu_control(alu_op),  
        .result(alu_result_wire),
        .zero(zero_flag),
        .negative(neg_flag)
    );
    
    assign ex_alu_result = (id_ex_opcode == OP_SVPC) ? id_ex_pc + 1 : alu_result_wire;
    
    adder EX_PC_ADDER (
        .a(id_ex_pc),
        .b(id_ex_imm),
        .out(ex_branch_target)
    );
    
    assign ex_write_data = id_ex_reg_data2;

    always @(*) begin
        $display("EX_STAGE @%0t PC=%h MEM_WRITE=%b", $time, id_ex_pc, id_ex_mem_write);
    end

endmodule
