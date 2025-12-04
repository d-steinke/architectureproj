`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_id_stage
// Tests instruction decode stage
//////////////////////////////////////////////////////////////////////////////////

module tb_id_stage;

    reg clk, rst;
    reg [31:0] if_id_instr, if_id_pc;
    reg wb_reg_write;
    reg [5:0] wb_write_reg;
    reg [31:0] wb_write_data;
    
    wire [31:0] id_pc, id_reg_data1, id_reg_data2, id_imm;
    wire [5:0] id_rd, id_rs, id_rt;
    wire id_reg_write, id_mem_to_reg, id_mem_write;
    wire id_alu_src;
    wire [2:0] id_alu_op;
    wire id_branch, id_jump;

    id_stage UUT (
        .clk(clk),
        .rst(rst),
        .if_id_instr(if_id_instr),
        .if_id_pc(if_id_pc),
        .wb_reg_write(wb_reg_write),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data),
        .id_pc(id_pc),
        .id_reg_data1(id_reg_data1),
        .id_reg_data2(id_reg_data2),
        .id_imm(id_imm),
        .id_rd(id_rd),
        .id_rs(id_rs),
        .id_rt(id_rt),
        .id_reg_write(id_reg_write),
        .id_mem_to_reg(id_mem_to_reg),
        .id_mem_write(id_mem_write),
        .id_alu_src(id_alu_src),
        .id_alu_op(id_alu_op),
        .id_branch(id_branch),
        .id_jump(id_jump)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== ID STAGE TESTBENCH ==========\n");

        // Reset and initialize
        rst = 1;
        wb_reg_write = 0;
        #10;
        rst = 0;

        // Pre-load some registers for testing
        @(posedge clk);
        wb_reg_write = 1;
        wb_write_reg = 6'd1;
        wb_write_data = 32'd100;
        @(posedge clk);
        
        wb_write_reg = 6'd2;
        wb_write_data = 32'd200;
        @(posedge clk);
        
        wb_write_reg = 6'd5;
        wb_write_data = 32'd500;
        @(posedge clk);
        
        wb_reg_write = 0;

        // Test 1: NOP instruction (opcode=0000)
        if_id_pc = 32'd0;
        if_id_instr = {10'b0, 6'd0, 6'd0, 6'd0, 4'b0000};
        #5;
        $display("Test 1 - NOP: opcode decoded, reg_write=%b (Expected 0) %s",
                 id_reg_write, (id_reg_write == 0) ? "PASS" : "FAIL");

        // Test 2: ADD x5, x1, x2 (opcode=0100, rd=5, rs=1, rt=2)
        if_id_instr = {10'b0, 6'd5, 6'd1, 6'd2, 4'b0100};
        #5;
        $display("Test 2 - ADD x5, x1, x2:");
        $display("  rd=%d, rs=%d, rt=%d (Expected 5, 1, 2) %s",
                 id_rd, id_rs, id_rt,
                 (id_rd == 5 && id_rs == 1 && id_rt == 2) ? "PASS" : "FAIL");
        $display("  data1=%d (Expected 100), data2=%d (Expected 200) %s",
                 id_reg_data1, id_reg_data2,
                 (id_reg_data1 == 100 && id_reg_data2 == 200) ? "PASS" : "FAIL");
        $display("  reg_write=%b (Expected 1), alu_op=%b (Expected 000) %s",
                 id_reg_write, id_alu_op,
                 (id_reg_write == 1 && id_alu_op == 3'b000) ? "PASS" : "FAIL");

        // Test 3: SUB x3, x5, x2 (opcode=0111, rd=3, rs=5, rt=2)
        if_id_instr = {10'b0, 6'd3, 6'd5, 6'd2, 4'b0111};
        #5;
        $display("Test 3 - SUB x3, x5, x2:");
        $display("  rd=%d, rs=%d, rt=%d (Expected 3, 5, 2) %s",
                 id_rd, id_rs, id_rt,
                 (id_rd == 3 && id_rs == 5 && id_rt == 2) ? "PASS" : "FAIL");
        $display("  alu_op=%b (Expected 101) %s",
                 id_alu_op, (id_alu_op == 3'b101) ? "PASS" : "FAIL");

        // Test 4: INC x10, x1, -5 (opcode=0101, rd=10, rs=1, imm=-5)
        if_id_instr = {10'b1111111011, 6'd10, 6'd1, 6'd0, 4'b0101};
        #5;
        $display("Test 4 - INC x10, x1, -5:");
        $display("  rd=%d, rs=%d (Expected 10, 1) %s",
                 id_rd, id_rs, (id_rd == 10 && id_rs == 1) ? "PASS" : "FAIL");
        $display("  imm=%d (Expected -5), alu_src=%b (Expected 1) %s",
                 $signed(id_imm), id_alu_src,
                 ($signed(id_imm) == -5 && id_alu_src == 1) ? "PASS" : "FAIL");

        // Test 5: LD x4, x1, 0 (opcode=1110, rd=4, rs=1, imm=0)
        if_id_instr = {10'b0, 6'd4, 6'd1, 6'd0, 4'b1110};
        #5;
        $display("Test 5 - LD x4, x1, 0:");
        $display("  rd=%d, rs=%d (Expected 4, 1) %s",
                 id_rd, id_rs, (id_rd == 4 && id_rs == 1) ? "PASS" : "FAIL");
        $display("  reg_write=%b (Expected 1), mem_to_reg=%b (Expected 1) %s",
                 id_reg_write, id_mem_to_reg,
                 (id_reg_write == 1 && id_mem_to_reg == 1) ? "PASS" : "FAIL");

        // Test 6: ST x3, x1, 10 (opcode=0011, rs=1, rt=3, imm=10)
        if_id_instr = {10'd10, 6'd0, 6'd1, 6'd3, 4'b0011};
        #5;
        $display("Test 6 - ST x3, x1, 10:");
        $display("  rs=%d, rt=%d (Expected 1, 3) %s",
                 id_rs, id_rt, (id_rs == 1 && id_rt == 3) ? "PASS" : "FAIL");
        $display("  mem_write=%b (Expected 1), reg_write=%b (Expected 0) %s",
                 id_mem_write, id_reg_write,
                 (id_mem_write == 1 && id_reg_write == 0) ? "PASS" : "FAIL");

        // Test 7: NEG x6, x5 (opcode=0110, rd=6, rs=5)
        if_id_instr = {10'b0, 6'd6, 6'd5, 6'd0, 4'b0110};
        #5;
        $display("Test 7 - NEG x6, x5:");
        $display("  rd=%d, rs=%d (Expected 6, 5) %s",
                 id_rd, id_rs, (id_rd == 6 && id_rs == 5) ? "PASS" : "FAIL");
        $display("  alu_op=%b (Expected 110) %s",
                 id_alu_op, (id_alu_op == 3'b110) ? "PASS" : "FAIL");

        // Test 8: J x7 (opcode=1000, rd=7)
        if_id_instr = {10'b0, 6'd7, 6'd0, 6'd0, 4'b1000};
        #5;
        $display("Test 8 - J x7:");
        $display("  jump=%b (Expected 1), reg_write=%b (Expected 0) %s",
                 id_jump, id_reg_write, (id_jump == 1 && id_reg_write == 0) ? "PASS" : "FAIL");

        // Test 9: BRZ (opcode=1001, rs=0)
        if_id_instr = {10'b0, 6'd0, 6'd0, 6'd0, 4'b1001};
        #5;
        $display("Test 9 - BRZ:");
        $display("  branch=%b (Expected 1), reg_write=%b (Expected 0) %s",
                 id_branch, id_reg_write, (id_branch == 1 && id_reg_write == 0) ? "PASS" : "FAIL");

        // Test 10: PC passthrough
        if_id_pc = 32'd12345;
        if_id_instr = 32'b0000_000000_000000_000000_0000000000;
        #5;
        $display("Test 10 - PC passthrough: id_pc=%d (Expected 12345) %s",
                 id_pc, (id_pc == 12345) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_id_stage.vcd");
        $dumpvars(0, tb_id_stage);
    end
endmodule
