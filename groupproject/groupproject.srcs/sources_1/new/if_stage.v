`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: if_stage
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


module if_stage (
    input wire clk,
    input wire rst,
    
    input wire [31:0] branch_target,    
    input wire [31:0] id_pc,          
    input wire [3:0] id_opcode,    
    input wire [3:0] id_ex_opcode,      
    input wire jump,                  
    input wire branch,                 
    input wire prev_zero_flag,       
    input wire prev_neg_flag,           
    
    output wire [31:0] pc_out,          
    output wire [31:0] next_pc,       
    output wire flush                  
);

    wire [31:0] pc_plus_one;
    wire branch_taken;
    wire pc_mux_sel;

    adder PC_ADDER (
        .a(pc_out),
        .b(32'd1),
        .out(pc_plus_one)
    );

    branchctl BRANCH_LOGIC (
        .opcode(id_ex_opcode),
        .zero_flag(prev_zero_flag),
        .neg_flag(prev_neg_flag),
        .branch_taken(branch_taken)
    );

    // Select next PC:
    // 1. If jump (J instruction): use branch_target
    // 2. Else if branch AND branch_taken (conditional branch taken): use branch_target
    // 3. Else: use PC+1
    assign pc_mux_sel = jump | (branch & branch_taken);

    mux PC_MUX (
        .in0(pc_plus_one),
        .in1(branch_target),
        .sel(pc_mux_sel),
        .out(next_pc)
    );

    assign flush = pc_mux_sel;

    pc PC_REG (
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .pc_out(pc_out)
    );

endmodule

