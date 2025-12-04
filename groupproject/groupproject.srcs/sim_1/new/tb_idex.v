`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_idex
// Tests ID/EX pipeline register
//////////////////////////////////////////////////////////////////////////////////

module tb_idex;

    reg clk, rst, flush;
    reg [31:0] id_pc, id_reg_data1, id_reg_data2, id_imm;
    reg [5:0] id_rd, id_rs, id_rt;
    reg [3:0] id_opcode;
    reg id_reg_write, id_mem_to_reg, id_mem_write;
    reg id_alu_src_a, id_alu_src_b, id_branch, id_jump;
    reg [2:0] id_alu_op;
    reg id_preserve_flags;
    
    wire [31:0] ex_pc, ex_reg_data1, ex_reg_data2, ex_imm;
    wire [5:0] ex_rd, ex_rs, ex_rt;
    wire [3:0] ex_opcode;
    wire ex_reg_write, ex_mem_to_reg, ex_mem_write;
    wire ex_alu_src_a, ex_alu_src_b, ex_branch, ex_jump;
    wire [2:0] ex_alu_op;
    wire ex_preserve_flags;

    idex UUT (
        .clk(clk),
        .rst(rst),
        .flush(flush),
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
        .ex_pc(ex_pc),
        .ex_reg_data1(ex_reg_data1),
        .ex_reg_data2(ex_reg_data2),
        .ex_imm(ex_imm),
        .ex_rd(ex_rd),
        .ex_rs(ex_rs),
        .ex_rt(ex_rt),
        .ex_opcode(ex_opcode),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_write(ex_mem_write),
        .ex_alu_src_a(ex_alu_src_a),
        .ex_alu_src_b(ex_alu_src_b),
        .ex_alu_op(ex_alu_op),
        .ex_branch(ex_branch),
        .ex_jump(ex_jump),
        .ex_preserve_flags(ex_preserve_flags)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== ID/EX PIPELINE REGISTER TESTBENCH ==========\n");

        // Test 1: Reset clears all outputs
        rst = 1;
        id_pc = 32'd100;
        id_reg_data1 = 32'd1000;
        id_reg_data2 = 32'd2000;
        id_imm = 32'd300;
        id_rd = 6'd10;
        id_rs = 6'd1;
        id_rt = 6'd2;
        id_reg_write = 1;
        id_mem_to_reg = 1;
        id_mem_write = 1;
        id_alu_src_a = 0;
        id_alu_src_b = 1;
        id_alu_op = 3'b101;
        id_branch = 1;
        id_jump = 1;
        #10;
        rst = 0;

        $display("Test 1 - Reset: ex_pc=%d (Expected 0), ex_rd=%d (Expected 0) %s",
                 ex_pc, ex_rd, (ex_pc == 0 && ex_rd == 0) ? "PASS" : "FAIL");

        // Test 2: Capture data on clock edge
        @(posedge clk);
        id_pc = 32'd100;
        id_reg_data1 = 32'd1111;
        id_reg_data2 = 32'd2222;
        id_imm = 32'd333;
        id_rd = 6'd5;
        id_rs = 6'd1;
        id_rt = 6'd2;
        id_reg_write = 1;
        id_mem_to_reg = 0;
        id_mem_write = 0;
        id_alu_src_a = 0;
        id_alu_src_b = 1;
        id_alu_op = 3'b000;
        id_branch = 0;
        id_jump = 0;
        
        @(posedge clk);
        #5;
        $display("Test 2 - Capture data: ex_pc=%d (Expected 100), ex_imm=%d (Expected 333) %s",
                 ex_pc, ex_imm, (ex_pc == 100 && ex_imm == 333) ? "PASS" : "FAIL");

        // Test 3: Register indices captured
        $display("Test 3 - Indices: ex_rd=%d (Expected 5), ex_rs=%d (Expected 1), ex_rt=%d (Expected 2) %s",
                 ex_rd, ex_rs, ex_rt,
                 (ex_rd == 5 && ex_rs == 1 && ex_rt == 2) ? "PASS" : "FAIL");

        // Test 4: Data values captured
        $display("Test 4 - Data: ex_reg_data1=%d (Expected 1111), ex_reg_data2=%d (Expected 2222) %s",
                 ex_reg_data1, ex_reg_data2,
                 (ex_reg_data1 == 1111 && ex_reg_data2 == 2222) ? "PASS" : "FAIL");

        // Test 5: Control signals captured
        $display("Test 5 - Control: reg_write=%b, mem_to_reg=%b, mem_write=%b, alu_src_b=%b %s",
                 ex_reg_write, ex_mem_to_reg, ex_mem_write, ex_alu_src_b,
                 (ex_reg_write == 1 && ex_mem_to_reg == 0 && 
                  ex_mem_write == 0 && ex_alu_src_b == 1) ? "PASS" : "FAIL");

        // Test 6: ALU operation and branch signals
        $display("Test 6 - ALU op=%b (Expected 000), branch=%b, jump=%b %s",
                 ex_alu_op, ex_branch, ex_jump,
                 (ex_alu_op == 3'b000 && ex_branch == 0 && ex_jump == 0) ? "PASS" : "FAIL");

        // Test 7: Different values on next cycle
        @(posedge clk);
        id_pc = 32'd200;
        id_reg_data1 = 32'd3333;
        id_alu_op = 3'b110;
        id_branch = 1;
        id_jump = 1;
        
        @(posedge clk);
        #5;
        $display("Test 7 - Update: ex_pc=%d (Expected 200), ex_reg_data1=%d (Expected 3333) %s",
                 ex_pc, ex_reg_data1, (ex_pc == 200 && ex_reg_data1 == 3333) ? "PASS" : "FAIL");

        $display("Test 8 - Updated control: alu_op=%b (Expected 110), branch=%b, jump=%b %s",
                 ex_alu_op, ex_branch, ex_jump,
                 (ex_alu_op == 3'b110 && ex_branch == 1 && ex_jump == 1) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_idex.vcd");
        $dumpvars(0, tb_idex);
    end
endmodule
