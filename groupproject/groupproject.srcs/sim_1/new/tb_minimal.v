`timescale 1ns / 1ps

module tb_minimal;
    reg clk, rst;
    cpu_simple CPU (.clk(clk), .rst(rst));

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("=== Minimal 2-Instruction Test ===\n");
        rst = 1;
        #20;
        rst = 0;
        // wait enough cycles for two INC instructions to complete
        #200000;
        
        $display("x1 (reg 1) = %0d (expected: 5)", $signed(CPU.ID_STAGE.ID_REG_FILE.debug_r1));
        $display("x2 (reg 2) = %0d (expected: 3)", $signed(CPU.ID_STAGE.ID_REG_FILE.debug_r2));
        
        if (CPU.ID_STAGE.ID_REG_FILE.debug_r1 == 5 && CPU.ID_STAGE.ID_REG_FILE.debug_r2 == 3)
            $display("PASS: Both registers have correct values\n");
        else
            $display("FAIL: Registers incorrect\n");
        
        $finish;
    end
endmodule
