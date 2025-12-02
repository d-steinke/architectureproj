`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_cpu_simple
// Simple CPU testbench with minimal instructions for basic pipeline verification
//////////////////////////////////////////////////////////////////////////////////

module tb_cpu_simple;

    reg clk;
    reg rst;

    cpu_simple CPU_UUT (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("========================================");
        $display("  Simple CPU Pipeline Test");
        $display("========================================\n");
        
        // Reset
        rst = 1;
        #20;
        rst = 0;
        $display("Time: %0t | Reset Released\n", $time);
        
        // Display the program
        $display("Program (First 5 Instructions):");
        $display("mem[0]: SVPC x40, 1   (x40 = PC+1 = 1)");
        $display("mem[1]: INC  x1, x0, 5 (x1 = 0 + 5 = 5)");
        $display("mem[2]: INC  x2, x0, 3 (x2 = 0 + 3 = 3)");
        $display("mem[3]: ADD  x3, x1, x2 (x3 = x1 + x2 = 5 + 3 = 8)");
        $display("mem[4]: NOP");
        $display("\n");
        
        // Run for enough time to execute the instructions
        // Each instruction takes ~5 cycles through the 5-stage pipeline
        // Plus some overhead for setup
        $display("Running program...\n");
        #500;
        
        // Let a few more cycles run to ensure writes are committed
        #200;
        
        // Display results
        $display("========================================");
        $display("Register Values After Execution:");
        $display("========================================");
        $display("x1  (reg 1)  = %0d (expected: 5)", $signed(CPU_UUT.ID_STAGE.ID_REG_FILE.registers[1]));
        $display("x2  (reg 2)  = %0d (expected: 3)", $signed(CPU_UUT.ID_STAGE.ID_REG_FILE.registers[2]));
        $display("x3  (reg 3)  = %0d (expected: 8)", $signed(CPU_UUT.ID_STAGE.ID_REG_FILE.registers[3]));
        $display("x40 (reg 40) = %0d (expected: 1)", $signed(CPU_UUT.ID_STAGE.ID_REG_FILE.registers[40]));
        $display("\n");
        
        // Verify results
        if (CPU_UUT.ID_STAGE.ID_REG_FILE.registers[1] == 32'd5) begin
            $display("✓ x1  = 5  (PASS)");
        end else begin
            $display("✗ x1  != 5  (FAIL) - got %d", CPU_UUT.ID_STAGE.ID_REG_FILE.registers[1]);
        end
        
        if (CPU_UUT.ID_STAGE.ID_REG_FILE.registers[2] == 32'd3) begin
            $display("✓ x2  = 3  (PASS)");
        end else begin
            $display("✗ x2  != 3  (FAIL) - got %d", CPU_UUT.ID_STAGE.ID_REG_FILE.registers[2]);
        end
        
        if (CPU_UUT.ID_STAGE.ID_REG_FILE.registers[3] == 32'd8) begin
            $display("✓ x3  = 8  (PASS)");
        end else begin
            $display("✗ x3  != 8  (FAIL) - got %d", CPU_UUT.ID_STAGE.ID_REG_FILE.registers[3]);
        end
        
        if (CPU_UUT.ID_STAGE.ID_REG_FILE.registers[40] == 32'd1) begin
            $display("✓ x40 = 1  (PASS)");
        end else begin
            $display("✗ x40 != 1  (FAIL) - got %d", CPU_UUT.ID_STAGE.ID_REG_FILE.registers[40]);
        end
        
        $display("\n========================================");
        $display("Test Complete");
        $display("========================================\n");
        
        $finish;
    end

endmodule
