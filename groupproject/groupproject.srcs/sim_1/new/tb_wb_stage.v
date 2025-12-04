`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_wb_stage
// Tests writeback stage
//////////////////////////////////////////////////////////////////////////////////

module tb_wb_stage;

    reg [31:0] wb_alu_result, wb_mem_data;
    reg [5:0] wb_rd;
    reg wb_reg_write, wb_mem_to_reg;
    
    wire [5:0] wb_write_reg;
    wire [31:0] wb_write_data;
    wire wb_write_en;

    wb_stage UUT (
        .wb_alu_result(wb_alu_result),
        .wb_mem_data(wb_mem_data),
        .wb_rd(wb_rd),
        .wb_reg_write(wb_reg_write),
        .wb_mem_to_reg(wb_mem_to_reg),
        .wb_write_reg(wb_write_reg),
        .wb_write_data(wb_write_data),
        .wb_write_en(wb_write_en)
    );

    initial begin
        $display("========== WRITEBACK STAGE TESTBENCH ==========\n");

        // Test 1: ALU result to register (mem_to_reg=0)
        wb_alu_result = 32'hDEAD_BEEF;
        wb_mem_data = 32'hCAFE_BABE;
        wb_rd = 6'd10;
        wb_reg_write = 1;
        wb_mem_to_reg = 0;
        #5;
        $display("Test 1 - ALU result: write_data=%h (Expected DEAD_BEEF) %s",
                 wb_write_data, (wb_write_data == 32'hDEAD_BEEF) ? "PASS" : "FAIL");

        // Test 2: Memory data to register (mem_to_reg=1)
        wb_mem_to_reg = 1;
        #5;
        $display("Test 2 - Memory data: write_data=%h (Expected CAFE_BABE) %s",
                 wb_write_data, (wb_write_data == 32'hCAFE_BABE) ? "PASS" : "FAIL");

        // Test 3: Register index pass-through
        wb_rd = 6'd25;
        #5;
        $display("Test 3 - Register index: wb_write_reg=%d (Expected 25) %s",
                 wb_write_reg, (wb_write_reg == 25) ? "PASS" : "FAIL");

        // Test 4: Write enable pass-through
        wb_reg_write = 1;
        #5;
        $display("Test 4 - Write enable (1): wb_write_en=%b (Expected 1) %s",
                 wb_write_en, (wb_write_en == 1) ? "PASS" : "FAIL");

        // Test 5: Write disabled
        wb_reg_write = 0;
        #5;
        $display("Test 5 - Write enable (0): wb_write_en=%b (Expected 0) %s",
                 wb_write_en, (wb_write_en == 0) ? "PASS" : "FAIL");

        // Test 6: Different values
        wb_alu_result = 32'h1111_1111;
        wb_mem_data = 32'h2222_2222;
        wb_rd = 6'd0;
        wb_reg_write = 1;
        wb_mem_to_reg = 0;
        #5;
        $display("Test 6 - New values (ALU): write_data=%h, reg=%d (Expected 1111_1111, 0) %s",
                 wb_write_data, wb_write_reg,
                 (wb_write_data == 32'h1111_1111 && wb_write_reg == 0) ? "PASS" : "FAIL");

        // Test 7: Switch to memory data
        wb_mem_to_reg = 1;
        #5;
        $display("Test 7 - New values (MEM): write_data=%h (Expected 2222_2222) %s",
                 wb_write_data, (wb_write_data == 32'h2222_2222) ? "PASS" : "FAIL");

        // Test 8: Large register index
        wb_rd = 6'd63;
        wb_alu_result = 32'hFFFF_FFFF;
        wb_mem_to_reg = 0;
        #5;
        $display("Test 8 - Max register: reg=%d, data=%h (Expected 63, FFFF_FFFF) %s",
                 wb_write_reg, wb_write_data,
                 (wb_write_reg == 63 && wb_write_data == 32'hFFFF_FFFF) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_wb_stage.vcd");
        $dumpvars(0, tb_wb_stage);
    end
endmodule
