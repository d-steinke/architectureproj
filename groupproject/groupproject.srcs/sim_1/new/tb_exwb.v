`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_exwb
// Tests EX/WB pipeline register
//////////////////////////////////////////////////////////////////////////////////

module tb_exwb;

    reg clk, rst;
    reg [31:0] ex_alu_result, ex_mem_data;
    reg [5:0] ex_rd;
    reg ex_zero_flag, ex_neg_flag;
    reg ex_reg_write, ex_mem_to_reg;
    
    wire [31:0] wb_alu_result, wb_mem_data;
    wire [5:0] wb_rd;
    wire wb_zero_flag, wb_neg_flag;
    wire wb_reg_write, wb_mem_to_reg;

    exwb UUT (
        .clk(clk),
        .rst(rst),
        .ex_alu_result(ex_alu_result),
        .ex_mem_data(ex_mem_data),
        .ex_rd(ex_rd),
        .ex_zero_flag(ex_zero_flag),
        .ex_neg_flag(ex_neg_flag),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .wb_alu_result(wb_alu_result),
        .wb_mem_data(wb_mem_data),
        .wb_rd(wb_rd),
        .wb_zero_flag(wb_zero_flag),
        .wb_neg_flag(wb_neg_flag),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== EX/WB PIPELINE REGISTER TESTBENCH ==========\n");

        // Test 1: Reset clears outputs
        rst = 1;
        ex_alu_result = 32'hDEAD_BEEF;
        ex_mem_data = 32'hCAFE_BABE;
        ex_rd = 6'd10;
        ex_zero_flag = 1;
        ex_neg_flag = 1;
        ex_reg_write = 1;
        ex_mem_to_reg = 1;
        #10;
        rst = 0;

        $display("Test 1 - Reset: wb_alu_result=%h (Expected 0), wb_rd=%d (Expected 0) %s",
                 wb_alu_result, wb_rd, (wb_alu_result == 0 && wb_rd == 0) ? "PASS" : "FAIL");

        // Test 2: Capture data on clock edge
        @(posedge clk);
        ex_alu_result = 32'd12345;
        ex_mem_data = 32'd67890;
        ex_rd = 6'd25;
        ex_zero_flag = 0;
        ex_neg_flag = 1;
        ex_reg_write = 1;
        ex_mem_to_reg = 0;
        
        @(posedge clk);
        #5;
        $display("Test 2 - Capture: wb_alu_result=%d (Expected 12345), wb_rd=%d (Expected 25) %s",
                 wb_alu_result, wb_rd, 
                 (wb_alu_result == 12345 && wb_rd == 25) ? "PASS" : "FAIL");

        // Test 3: Flags captured
        $display("Test 3 - Flags: wb_zero=%b (Expected 0), wb_neg=%b (Expected 1) %s",
                 wb_zero_flag, wb_neg_flag,
                 (wb_zero_flag == 0 && wb_neg_flag == 1) ? "PASS" : "FAIL");

        // Test 4: Control signals captured
        $display("Test 4 - Control: wb_reg_write=%b (Expected 1), wb_mem_to_reg=%b (Expected 0) %s",
                 wb_reg_write, wb_mem_to_reg,
                 (wb_reg_write == 1 && wb_mem_to_reg == 0) ? "PASS" : "FAIL");

        // Test 5: Different data on next cycle
        @(posedge clk);
        ex_alu_result = 32'hFFFF_FFFF;
        ex_mem_data = 32'h1111_1111;
        ex_rd = 6'd0;
        ex_zero_flag = 1;
        ex_neg_flag = 0;
        ex_reg_write = 0;
        ex_mem_to_reg = 1;
        
        @(posedge clk);
        #5;
        $display("Test 5 - Update: wb_alu_result=%h (Expected FFFF_FFFF) %s",
                 wb_alu_result, (wb_alu_result == 32'hFFFF_FFFF) ? "PASS" : "FAIL");

        // Test 6: Memory data captured
        $display("Test 6 - Mem data: wb_mem_data=%h (Expected 1111_1111) %s",
                 wb_mem_data, (wb_mem_data == 32'h1111_1111) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_exwb.vcd");
        $dumpvars(0, tb_exwb);
    end
endmodule
