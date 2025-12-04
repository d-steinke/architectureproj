`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_mem_stage
// Tests memory access stage
//////////////////////////////////////////////////////////////////////////////////

module tb_mem_stage;

    reg clk;
    reg [31:0] ex_alu_result, ex_write_data;
    reg [5:0] ex_rd;
    reg ex_zero_flag, ex_neg_flag;
    reg ex_reg_write, ex_mem_to_reg, ex_mem_write;
    
    wire [31:0] mem_alu_result, mem_read_data;
    wire [5:0] mem_rd;
    wire mem_zero_flag, mem_neg_flag;
    wire mem_reg_write, mem_mem_to_reg;

    mem_stage UUT (
        .clk(clk),
        .ex_alu_result(ex_alu_result),
        .ex_write_data(ex_write_data),
        .ex_rd(ex_rd),
        .ex_zero_flag(ex_zero_flag),
        .ex_neg_flag(ex_neg_flag),
        .ex_reg_write(ex_reg_write),
        .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_write(ex_mem_write),
        .mem_alu_result(mem_alu_result),
        .mem_read_data(mem_read_data),
        .mem_rd(mem_rd),
        .mem_zero_flag(mem_zero_flag),
        .mem_neg_flag(mem_neg_flag),
        .mem_reg_write(mem_reg_write),
        .mem_mem_to_reg(mem_mem_to_reg)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== MEMORY STAGE TESTBENCH ==========\n");

        // Test 1: ALU result pass-through
        ex_alu_result = 32'd12345;
        ex_rd = 6'd10;
        ex_zero_flag = 0;
        ex_neg_flag = 0;
        ex_reg_write = 1;
        ex_mem_to_reg = 0;
        ex_mem_write = 0;
        ex_write_data = 32'd0;
        #5;
        $display("Test 1 - ALU pass-through: mem_alu_result=%d (Expected 12345) %s",
                 mem_alu_result, (mem_alu_result == 12345) ? "PASS" : "FAIL");

        // Test 2: Register index pass-through
        $display("Test 2 - Register index: mem_rd=%d (Expected 10) %s",
                 mem_rd, (mem_rd == 10) ? "PASS" : "FAIL");

        // Test 3: Flags pass-through
        ex_zero_flag = 1;
        ex_neg_flag = 1;
        #5;
        $display("Test 3 - Flags: zero=%b, neg=%b (Expected 1, 1) %s",
                 mem_zero_flag, mem_neg_flag,
                 (mem_zero_flag == 1 && mem_neg_flag == 1) ? "PASS" : "FAIL");

        // Test 4: Control signals pass-through
        ex_reg_write = 0;
        ex_mem_to_reg = 1;
        #5;
        $display("Test 4 - Control: reg_write=%b (Expected 0), mem_to_reg=%b (Expected 1) %s",
                 mem_reg_write, mem_mem_to_reg,
                 (mem_reg_write == 0 && mem_mem_to_reg == 1) ? "PASS" : "FAIL");

        // Test 5: Store (write to memory)
        @(posedge clk);
        ex_alu_result = 32'd100;  // Address
        ex_write_data = 32'hDEAD_BEEF;  // Data to store
        ex_mem_write = 1;
        ex_mem_to_reg = 0;
        @(posedge clk);
        #5;
        $display("Test 5 - Store: wrote to addr 100, data=DEAD_BEEF");

        // Test 6: Load (read from memory)
        @(posedge clk);
        ex_alu_result = 32'd100;  // Read from address 100
        ex_mem_write = 0;
        ex_mem_to_reg = 1;
        @(posedge clk);
        #10;
        $display("Test 6 - Load: mem_read_data=%h (Expected DEAD_BEEF) %s",
                 mem_read_data, (mem_read_data == 32'hDEAD_BEEF) ? "PASS" : "FAIL");

        // Test 7: Read-after-write
        @(posedge clk);
        ex_alu_result = 32'd50;
        ex_write_data = 32'hCAFE_BABE;
        ex_mem_write = 1;
        @(posedge clk);

        @(posedge clk);
        ex_alu_result = 32'd50;
        ex_mem_write = 0;
        ex_mem_to_reg = 1;
        @(posedge clk);
        #10;
        $display("Test 7 - Read-after-write: mem_read_data=%h (Expected CAFE_BABE) %s",
                 mem_read_data, (mem_read_data == 32'hCAFE_BABE) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_mem_stage.vcd");
        $dumpvars(0, tb_mem_stage);
    end
endmodule
