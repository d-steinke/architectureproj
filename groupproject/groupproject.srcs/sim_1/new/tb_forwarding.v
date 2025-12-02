`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_forwarding
// Tests data forwarding for hazard resolution
//////////////////////////////////////////////////////////////////////////////////

module tb_forwarding;

    reg [5:0] id_ex_rs, id_ex_rt;
    reg [5:0] ex_wb_rd, mem_rd;
    reg ex_wb_reg_write, mem_reg_write;
    reg [31:0] id_ex_reg_data1, id_ex_reg_data2;
    reg [31:0] ex_wb_alu_result, mem_alu_result;
    wire [31:0] alu_input1, alu_input2;

    forwarding UUT (
        .id_ex_rs(id_ex_rs),
        .id_ex_rt(id_ex_rt),
        .ex_wb_rd(ex_wb_rd),
        .ex_wb_reg_write(ex_wb_reg_write),
        .mem_rd(mem_rd),
        .mem_reg_write(mem_reg_write),
        .id_ex_reg_data1(id_ex_reg_data1),
        .id_ex_reg_data2(id_ex_reg_data2),
        .ex_wb_alu_result(ex_wb_alu_result),
        .mem_alu_result(mem_alu_result),
        .alu_input1(alu_input1),
        .alu_input2(alu_input2)
    );

    initial begin
        $display("========== DATA FORWARDING TESTBENCH ==========\n");

        // Test 1: No forwarding (no register matches)
        id_ex_rs = 6'd1;
        id_ex_rt = 6'd2;
        ex_wb_rd = 6'd3;
        mem_rd = 6'd4;
        ex_wb_reg_write = 1;
        mem_reg_write = 1;
        id_ex_reg_data1 = 32'd100;
        id_ex_reg_data2 = 32'd200;
        ex_wb_alu_result = 32'd300;
        mem_alu_result = 32'd400;
        #5;
        $display("Test 1 - No forward: alu_input1=%d (Expected 100), alu_input2=%d (Expected 200) %s",
                 alu_input1, alu_input2,
                 (alu_input1 == 100 && alu_input2 == 200) ? "PASS" : "FAIL");

        // Test 2: Forward RS from EX/WB
        id_ex_rs = 6'd3;
        #5;
        $display("Test 2 - Forward RS from EX/WB: alu_input1=%d (Expected 300) %s",
                 alu_input1, (alu_input1 == 300) ? "PASS" : "FAIL");

        // Test 3: Forward RT from EX/WB
        id_ex_rt = 6'd3;
        #5;
        $display("Test 3 - Forward RT from EX/WB: alu_input2=%d (Expected 300) %s",
                 alu_input2, (alu_input2 == 300) ? "PASS" : "FAIL");

        // Test 4: Forward both RS and RT from EX/WB
        id_ex_rs = 6'd3;
        id_ex_rt = 6'd3;
        #5;
        $display("Test 4 - Forward both from EX/WB: in1=%d, in2=%d (Both Expected 300) %s",
                 alu_input1, alu_input2, (alu_input1 == 300 && alu_input2 == 300) ? "PASS" : "FAIL");

        // Test 5: Forward RS from MEM (when EX/WB doesn't match)
        id_ex_rs = 6'd4;
        id_ex_rt = 6'd2;
        ex_wb_rd = 6'd5;
        #5;
        $display("Test 5 - Forward RS from MEM: alu_input1=%d (Expected 400) %s",
                 alu_input1, (alu_input1 == 400) ? "PASS" : "FAIL");

        // Test 6: EX/WB takes priority over MEM
        id_ex_rs = 6'd4;
        id_ex_rt = 6'd5;
        ex_wb_rd = 6'd4;
        mem_rd = 6'd4;
        ex_wb_alu_result = 32'd500;
        #5;
        $display("Test 6 - EX/WB priority: alu_input1=%d (Expected 500, not 400) %s",
                 alu_input1, (alu_input1 == 500) ? "PASS" : "FAIL");

        // Test 7: Disabled write (ex_wb_reg_write = 0)
        id_ex_rs = 6'd4;
        ex_wb_rd = 6'd4;
        ex_wb_reg_write = 0;
        mem_reg_write = 0;
        id_ex_reg_data1 = 32'd100;
        #5;
        $display("Test 7 - Disabled write: alu_input1=%d (Expected 100) %s",
                 alu_input1, (alu_input1 == 100) ? "PASS" : "FAIL");

        // Test 8: x0 (zero register) never forwarded
        id_ex_rs = 6'd0;
        ex_wb_rd = 6'd0;
        ex_wb_reg_write = 1;
        id_ex_reg_data1 = 32'd1000;
        ex_wb_alu_result = 32'd2000;
        #5;
        $display("Test 8 - x0 excluded: alu_input1=%d (Expected 1000, not forwarded) %s",
                 alu_input1, (alu_input1 == 1000) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end

endmodule
