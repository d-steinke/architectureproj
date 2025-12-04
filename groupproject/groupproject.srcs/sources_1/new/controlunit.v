`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:51:19 PM
// Design Name: 
// Module Name: controlunit
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


module controlunit(
    input wire [3:0] opcode,
    output reg reg_write,
    output reg mem_to_reg,
    output reg mem_write,
    output reg alu_src_a,    // 0=Reg, 1=PC
    output reg alu_src_b,    // 0=Reg, 1=Imm
    output reg [2:0] alu_op, // {ADD, NEG, SUB}
    output reg branch,      
    output reg jump,
    output reg preserve_flags
);

    parameter OP_NOP  = 4'b0000;
    parameter OP_SVPC = 4'b1111;
    parameter OP_LD   = 4'b1110;
    parameter OP_ST   = 4'b0011;
    parameter OP_ADD  = 4'b0100;
    parameter OP_INC  = 4'b0101;
    parameter OP_NEG  = 4'b0110;
    parameter OP_SUB  = 4'b0111;
    parameter OP_J    = 4'b1000;
    parameter OP_BRZ  = 4'b1001;
    parameter OP_BRN  = 4'b1010;

    always @(*) begin
        // Default values
        reg_write = 0; mem_to_reg = 0; mem_write = 0; 
        alu_src_a = 0; alu_src_b = 0; preserve_flags = 0; 
        branch = 0; jump = 0; 
        alu_op = 3'b000; 

        case (opcode)
            OP_NOP: begin
                preserve_flags = 1;  // Don't update flags for NOP
            end
            
            OP_SVPC: begin
                reg_write = 1;
                alu_src_a = 1; // Select PC
                alu_src_b = 1; // Select Imm
                alu_op = 3'b000; // ADD (Result = PC + Imm)
                preserve_flags = 1;  // Don't update flags for SVPC
            end
            
            OP_LD: begin
                reg_write = 1;
                mem_to_reg = 1; 
                alu_src_a = 0;
                alu_src_b = 1; 
                alu_op = 3'b000; 
            end
            
            OP_ST: begin
                mem_write = 1;
                mem_to_reg = 1; // Don't care, but 1 in table
                alu_src_a = 0;
                alu_src_b = 1; 
                alu_op = 3'b000; 
            end
            
            OP_ADD: begin
                reg_write = 1;
                alu_src_a = 0;
                alu_src_b = 0;
                alu_op = 3'b000; 
            end
            
            OP_INC: begin
                reg_write = 1;
                alu_src_a = 0;
                alu_src_b = 1; 
                alu_op = 3'b000;
            end
            
            OP_NEG: begin
                reg_write = 1;
                alu_src_a = 0;
                alu_src_b = 0; 
                alu_op = 3'b110;
            end
            
            OP_SUB: begin
                reg_write = 1;
                alu_src_a = 0;
                alu_src_b = 0;
                alu_op = 3'b101; 
            end

            OP_J: begin
                jump = 1;
            end
            
            OP_BRZ, OP_BRN: begin
                branch = 1;  
            end
            
        endcase
    end
endmodule
