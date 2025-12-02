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
// Description: IF Stage - Instruction Fetch with branch/jump control
//              Selects next PC based on: normal increment, unconditional jump, or conditional branch
// 
// Dependencies: pc, mux, adder, branchctl
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module if_stage (
    input wire clk,
    input wire rst,
    
    // Branch/Jump information from pipeline
    input wire [31:0] branch_target,    // Target address (from EX stage)
    input wire [31:0] id_pc,            // Current PC (from IF/ID pipeline)
    input wire [3:0] id_opcode,         // Current instruction opcode (from IF/ID pipeline)
    input wire jump,                    // Jump signal from control unit (J instruction)
    input wire branch,                  // Branch signal (BRZ/BRN instruction)
    input wire prev_zero_flag,          // Zero flag from previous instruction (from EX/WB pipeline)
    input wire prev_neg_flag,           // Negative flag from previous instruction (from EX/WB pipeline)
    
    output wire [31:0] pc_out,          // Current program counter
    output wire [31:0] next_pc,         // Next program counter (PC+1)
    output wire flush                   // Flush signal: 1 = squash instruction in IF/ID stage
);

    wire [31:0] pc_plus_one;
    wire branch_taken;
    wire pc_mux_sel;

    // Always compute PC + 1
    adder PC_ADDER (
        .a(pc_out),
        .b(32'd1),
        .out(pc_plus_one)
    );

    // Determine if conditional branch should be taken
    branchctl BRANCH_LOGIC (
        .opcode(id_opcode),
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

    // Flush signal: squash instruction in IF/ID stage when branch/jump is taken
    assign flush = pc_mux_sel;

    // PC register
    pc PC_REG (
        .clk(clk),
        .rst(rst),
        .pc_in(next_pc),
        .pc_out(pc_out)
    );

endmodule

