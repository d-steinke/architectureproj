`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_branchctl
// Tests branch control logic for BRZ and BRN instructions
//////////////////////////////////////////////////////////////////////////////////

module tb_branchctl;

    reg [3:0] opcode;
    reg zero_flag, neg_flag;
    wire branch_taken;

    branchctl UUT (
        .opcode(opcode),
        .zero_flag(zero_flag),
        .neg_flag(neg_flag),
        .branch_taken(branch_taken)
    );

    initial begin
        $display("========== BRANCH CONTROL TESTBENCH ==========\n");

        // Test 1: BRZ with zero_flag = 0 (should branch)
        opcode = 4'b1001;  // BRZ
        zero_flag = 0;
        neg_flag = 0;
        #5;
        $display("Test 1 - BRZ (1001) with zero_flag=0: branch_taken=%b (Expected 1) %s",
                 branch_taken, (branch_taken == 1) ? "PASS" : "FAIL");

        // Test 2: BRZ with zero_flag = 1 (should NOT branch)
        zero_flag = 1;
        #5;
        $display("Test 2 - BRZ (1001) with zero_flag=1: branch_taken=%b (Expected 0) %s",
                 branch_taken, (branch_taken == 0) ? "PASS" : "FAIL");

        // Test 3: BRN with neg_flag = 1 (should branch)
        opcode = 4'b1010;  // BRN
        zero_flag = 0;
        neg_flag = 1;
        #5;
        $display("Test 3 - BRN (1010) with neg_flag=1: branch_taken=%b (Expected 1) %s",
                 branch_taken, (branch_taken == 1) ? "PASS" : "FAIL");

        // Test 4: BRN with neg_flag = 0 (should NOT branch)
        neg_flag = 0;
        #5;
        $display("Test 4 - BRN (1010) with neg_flag=0: branch_taken=%b (Expected 0) %s",
                 branch_taken, (branch_taken == 0) ? "PASS" : "FAIL");

        // Test 5: NOP (should never branch)
        opcode = 4'b0000;
        neg_flag = 1;
        zero_flag = 0;
        #5;
        $display("Test 5 - NOP (0000): branch_taken=%b (Expected 0) %s",
                 branch_taken, (branch_taken == 0) ? "PASS" : "FAIL");

        // Test 6: ADD (should never branch)
        opcode = 4'b0100;
        #5;
        $display("Test 6 - ADD (0100): branch_taken=%b (Expected 0) %s",
                 branch_taken, (branch_taken == 0) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end

endmodule
