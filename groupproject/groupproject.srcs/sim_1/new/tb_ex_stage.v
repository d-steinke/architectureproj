`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_ex_stage
// Tests execute stage with ALU and branch target calculation
//////////////////////////////////////////////////////////////////////////////////

module tb_ex_stage;

    reg [31:0] id_ex_pc;
    reg [31:0] id_ex_reg_data1, id_ex_reg_data2;
    reg [31:0] id_ex_imm;
    reg alu_src;
    reg [2:0] alu_op;
    wire [31:0] ex_alu_result, ex_write_data, ex_branch_target;
    wire zero_flag, neg_flag;

    ex_stage UUT (
        .id_ex_pc(id_ex_pc),
        .id_ex_reg_data1(id_ex_reg_data1),
        .id_ex_reg_data2(id_ex_reg_data2),
        .id_ex_imm(id_ex_imm),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .ex_alu_result(ex_alu_result),
        .ex_write_data(ex_write_data),
        .ex_branch_target(ex_branch_target),
        .zero_flag(zero_flag),
        .neg_flag(neg_flag)
    );

    initial begin
        $display("========== EXECUTE STAGE TESTBENCH ==========\n");

        // Test 1: ADD (alu_src=0 use reg_data2)
        id_ex_pc = 32'd10;
        id_ex_reg_data1 = 32'd100;
        id_ex_reg_data2 = 32'd50;
        id_ex_imm = 32'd0;
        alu_src = 1'b0;
        alu_op = 3'b000;  // ADD
        #5;
        $display("Test 1 - ADD 100+50: result=%d (Expected 150), flags z=%b n=%b %s",
                 ex_alu_result, zero_flag, neg_flag,
                 (ex_alu_result == 150 && zero_flag == 0) ? "PASS" : "FAIL");

        // Test 2: INC with immediate (alu_src=1 use imm)
        id_ex_reg_data1 = 32'd100;
        id_ex_imm = 32'd5;
        alu_src = 1'b1;
        alu_op = 3'b000;  // ADD
        #5;
        $display("Test 2 - INC 100+5: result=%d (Expected 105) %s",
                 ex_alu_result, (ex_alu_result == 105) ? "PASS" : "FAIL");

        // Test 3: SUB
        id_ex_reg_data1 = 32'd100;
        id_ex_reg_data2 = 32'd30;
        alu_src = 1'b0;
        alu_op = 3'b101;  // SUB
        #5;
        $display("Test 3 - SUB 100-30: result=%d (Expected 70) %s",
                 ex_alu_result, (ex_alu_result == 70) ? "PASS" : "FAIL");

        // Test 4: NEG
        id_ex_reg_data1 = 32'd50;
        alu_op = 3'b110;  // NEG
        #5;
        $display("Test 4 - NEG 50: result=%d (Expected -50, n=1) n=%b %s",
                 $signed(ex_alu_result), neg_flag,
                 ($signed(ex_alu_result) == -50 && neg_flag == 1) ? "PASS" : "FAIL");

        // Test 5: Zero result (sets Z flag)
        id_ex_reg_data1 = 32'd100;
        id_ex_reg_data2 = 32'd100;
        alu_op = 3'b101;  // SUB
        #5;
        $display("Test 5 - SUB 100-100: result=%d (Expected 0, z=1) z=%b %s",
                 ex_alu_result, zero_flag,
                 (ex_alu_result == 0 && zero_flag == 1) ? "PASS" : "FAIL");

        // Test 6: Branch target calculation (PC + imm)
        id_ex_pc = 32'd100;
        id_ex_imm = 32'd20;
        alu_op = 3'b000;  // Not used for branch target
        #5;
        $display("Test 6 - Branch target PC+imm 100+20: target=%d (Expected 120) %s",
                 ex_branch_target, (ex_branch_target == 120) ? "PASS" : "FAIL");

        // Test 7: Write data pass-through
        id_ex_reg_data2 = 32'hAABB_CCDD;
        #5;
        $display("Test 7 - Write data pass-through: write_data=%h (Expected AABB_CCDD) %s",
                 ex_write_data, (ex_write_data == 32'hAABB_CCDD) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_ex_stage.vcd");
        $dumpvars(0, tb_ex_stage);
    end
endmodule
