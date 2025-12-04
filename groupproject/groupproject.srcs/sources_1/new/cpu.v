`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: cpu
// Project Name: SCU ISA 3-Stage Pipelined CPU
// Target Devices: 
// Tool Versions: 
// Description: Top-level CPU module integrating all pipeline stages
// 
// Dependencies: if_stage, ifid, id_stage, idex, ex_stage, mem_stage, exwb, 
//               wb_stage, forwarding
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: 
// Pipeline: IF -> ID -> EX -> MEM -> WB
// Includes branch/jump control, data forwarding, and flush on branch
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module cpu (
    input wire clk,
    input wire rst
);

    // ===== IF STAGE =====
    wire [31:0] if_pc;
    wire [31:0] if_next_pc;
    wire if_flush;
    wire [31:0] if_id_instr;
    wire [31:0] if_id_pc;
    
    // ===== ID STAGE =====
    wire [31:0] id_pc;
    wire [31:0] id_reg_data1;
    wire [31:0] id_reg_data2;
    wire [31:0] id_imm;
    wire [5:0] id_rd, id_rs, id_rt;
    wire [3:0] id_opcode;
    wire id_reg_write, id_mem_to_reg, id_mem_write;
    wire id_alu_src_a, id_alu_src_b;
    wire id_branch, id_jump;
    wire [2:0] id_alu_op;
    
    // ===== ID/EX PIPELINE =====
    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_reg_data1;
    wire [31:0] id_ex_reg_data2;
    wire [31:0] id_ex_imm;
    wire [5:0] id_ex_rd, id_ex_rs, id_ex_rt;
    wire [3:0] id_ex_opcode;
    wire id_ex_reg_write, id_ex_mem_to_reg, id_ex_mem_write;
    wire id_ex_alu_src_a, id_ex_alu_src_b;
    wire id_ex_branch, id_ex_jump;
    wire [2:0] id_ex_alu_op;
    
    // ===== EX STAGE =====
    wire [31:0] ex_alu_result;
    wire [31:0] ex_write_data;
    wire [31:0] ex_branch_target;
    wire ex_zero_flag, ex_neg_flag;
    wire id_preserve_flags, id_ex_preserve_flags;
    
    // ===== EX/WB PIPELINE (and MEM signals) =====
    wire [31:0] ex_wb_alu_result;
    wire [31:0] ex_wb_mem_data;
    wire [5:0] ex_wb_rd;
    wire [5:0] ex_wb_rt;
    wire [3:0] ex_wb_opcode;
    wire ex_wb_zero_flag, ex_wb_neg_flag;
    wire ex_wb_reg_write, ex_wb_mem_to_reg;
    wire ex_wb_mem_write_sig; 
    
    // ===== MEM STAGE =====
    wire [31:0] mem_alu_result;
    wire [31:0] mem_read_data;
    wire [5:0] mem_rd;
    wire [5:0] mem_rt;
    wire [3:0] mem_opcode;
    wire mem_zero_flag, mem_neg_flag;
    wire mem_reg_write, mem_mem_to_reg;
    
    // ===== WB STAGE =====
    wire [5:0] wb_write_reg;
    wire [31:0] wb_write_data;
    wire wb_write_en;
    
    // ===== FORWARDING =====
    wire [31:0] alu_input1, alu_input2;
    
    // --------------------------------------------------------
    // INSTANTIATIONS
    // --------------------------------------------------------

    if_stage IF_STAGE (
        .clk(clk),
        .rst(rst),
        .branch_target(ex_branch_target),
        .id_pc(if_id_pc),
        .id_opcode(if_id_instr[3:0]),
        .id_ex_opcode(id_ex_opcode),
        .jump(id_ex_jump),
        .branch(id_ex_branch),
        .prev_zero_flag(mem_zero_flag),
        .prev_neg_flag(mem_neg_flag),
        .pc_out(if_pc),
        .next_pc(if_next_pc),
        .flush(if_flush)
    );

    wire [31:0] if_instr;
    im IF_IMEM_INST (
        .address(if_pc),
        .instruction(if_instr)
    );
    
    ifid IF_ID_REG (
        .clk(clk),
        .flush(if_flush),
        .instr_in(if_instr),
        .pc_in(if_pc),
        .instr_out(if_id_instr),
        .pc_out(if_id_pc)
    );

    // Register WB signals to break combinational path
    reg reg_write_r;
    reg [5:0] write_reg_r;
    reg [31:0] write_data_r;
    
    always @(posedge clk) begin
        if (rst) begin
            reg_write_r <= 0;
            write_reg_r <= 0;
            write_data_r <= 0;
        end else begin
            reg_write_r <= mem_reg_write;
            write_reg_r <= mem_rd;
            write_data_r <= mem_mem_to_reg ? mem_read_data : mem_alu_result;
        end
    end

    id_stage ID_STAGE (
        .clk(clk),
        .rst(rst),
        .if_id_instr(if_id_instr),
        .if_id_pc(if_id_pc),
        .wb_reg_write(reg_write_r),
        .wb_write_reg(write_reg_r),
        .wb_write_data(write_data_r),
        .id_pc(id_pc),
        .id_reg_data1(id_reg_data1),
        .id_reg_data2(id_reg_data2),
        .id_imm(id_imm),
        .id_rd(id_rd),
        .id_rs(id_rs),
        .id_rt(id_rt),
        .id_opcode(id_opcode),
        .id_reg_write(id_reg_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_mem_write(id_mem_write),
        .id_alu_src_a(id_alu_src_a),
        .id_alu_src_b(id_alu_src_b),
        .id_alu_op(id_alu_op),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_preserve_flags(id_preserve_flags)
    );

    idex ID_EX_REG (
        .clk(clk),
        .rst(rst),
        .flush(if_flush),  // Flush on taken branch/jump
        .id_pc(id_pc),
        .id_reg_data1(id_reg_data1),
        .id_reg_data2(id_reg_data2),
        .id_imm(id_imm),
        .id_rd(id_rd),
        .id_rs(id_rs),
        .id_rt(id_rt),
        .id_opcode(id_opcode),
        .id_reg_write(id_reg_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_mem_write(id_mem_write),
        .id_alu_src_a(id_alu_src_a),
        .id_alu_src_b(id_alu_src_b),
        .id_alu_op(id_alu_op),
        .id_branch(id_branch),
        .id_jump(id_jump),
        .id_preserve_flags(id_preserve_flags),
        .ex_pc(id_ex_pc),
        .ex_reg_data1(id_ex_reg_data1),
        .ex_reg_data2(id_ex_reg_data2),
        .ex_imm(id_ex_imm),
        .ex_rd(id_ex_rd),
        .ex_rs(id_ex_rs),
        .ex_rt(id_ex_rt),
        .ex_opcode(id_ex_opcode),
        .ex_reg_write(id_ex_reg_write),
        .ex_mem_to_reg(id_ex_mem_to_reg),
        .ex_mem_write(id_ex_mem_write),
        .ex_alu_src_a(id_ex_alu_src_a),
        .ex_alu_src_b(id_ex_alu_src_b),
        .ex_alu_op(id_ex_alu_op),
        .ex_branch(id_ex_branch),
        .ex_jump(id_ex_jump),
        .ex_preserve_flags(id_ex_preserve_flags)
    );

    forwarding FORWARD_UNIT (
        .id_ex_rs(id_ex_rs),
        .id_ex_rt(id_ex_rt),
        .ex_wb_rd(ex_wb_rd),
        .ex_wb_reg_write(ex_wb_reg_write),
        .mem_rd(write_reg_r),              // Connect to WB stage register
        .mem_reg_write(reg_write_r),       // Connect to WB stage register
        .id_ex_reg_data1(id_ex_reg_data1),
        .id_ex_reg_data2(id_ex_reg_data2),
        .ex_wb_alu_result(ex_wb_alu_result),
        .mem_alu_result(write_data_r),     // Connect to WB stage register
        .alu_input1(alu_input1),
        .alu_input2(alu_input2)
    );

    ex_stage EX_STAGE (
        .id_ex_pc(id_ex_pc),
        .id_ex_reg_data1(alu_input1),
        .id_ex_reg_data2(alu_input2),
        .id_ex_imm(id_ex_imm),
        .id_ex_opcode(id_ex_opcode),
        .alu_src_a(id_ex_alu_src_a),
        .alu_src_b(id_ex_alu_src_b),
        .alu_op(id_ex_alu_op),
        .id_ex_mem_write(id_ex_mem_write), 
        .ex_alu_result(ex_alu_result),
        .ex_write_data(ex_write_data),
        .ex_branch_target(ex_branch_target),
        .zero_flag(ex_zero_flag),
        .neg_flag(ex_neg_flag)
    );

    exwb EX_WB_REG (
        .clk(clk),
        .rst(rst),
        .flush(if_flush),  // Flush on taken branch/jump
        .ex_alu_result(ex_alu_result),
        .ex_mem_data(ex_write_data),
        .ex_rd(id_ex_rd),
        .ex_rt(id_ex_rt),
        .ex_opcode(id_ex_opcode),
        .ex_zero_flag(ex_zero_flag),
        .ex_neg_flag(ex_neg_flag),
        .ex_reg_write(id_ex_reg_write),
        .ex_mem_to_reg(id_ex_mem_to_reg),
        .ex_preserve_flags(id_ex_preserve_flags),
        
        .ex_mem_write(id_ex_mem_write), 
        .wb_mem_write(ex_wb_mem_write_sig), 
        
        .wb_alu_result(ex_wb_alu_result),
        .wb_mem_data(ex_wb_mem_data),
        .wb_rd(ex_wb_rd),
        .wb_rt(ex_wb_rt),
        .wb_opcode(ex_wb_opcode),
        .wb_zero_flag(ex_wb_zero_flag),
        .wb_neg_flag(ex_wb_neg_flag),
        .wb_reg_write(ex_wb_reg_write),
        .wb_mem_to_reg(ex_wb_mem_to_reg)
    );

    mem_stage MEM_STAGE (
        .clk(clk),
        .ex_alu_result(ex_wb_alu_result),
        .ex_write_data(ex_wb_mem_data),
        .ex_rd(ex_wb_rd),
        .ex_rt(ex_wb_rt),
        .ex_opcode(ex_wb_opcode),
        .ex_zero_flag(ex_wb_zero_flag),
        .ex_neg_flag(ex_wb_neg_flag),
        .ex_reg_write(ex_wb_reg_write),
        .ex_mem_to_reg(ex_wb_mem_to_reg),
        
        .ex_mem_write(ex_wb_mem_write_sig), 
        
        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_read_data),
        .mem_rd(mem_rd),
        .mem_rt(mem_rt),
        .mem_opcode(mem_opcode),
        .mem_zero_flag(mem_zero_flag),
        .mem_neg_flag(mem_neg_flag),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg)
    );

    wb_stage WB_STAGE (
        .wb_alu_result(mem_alu_result),
        .wb_mem_data(mem_read_data),
        .wb_rd(mem_rd),
        .wb_rt(mem_rt),
        .wb_opcode(mem_opcode),
        .wb_reg_write(mem_reg_write),
        .wb_mem_to_reg(mem_mem_to_reg),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data),
        .wb_write_en(wb_write_en)
    );

endmodule