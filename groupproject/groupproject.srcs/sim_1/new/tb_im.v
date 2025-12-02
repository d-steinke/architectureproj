`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_im
// Tests instruction memory reads from various addresses
//////////////////////////////////////////////////////////////////////////////////

module tb_im;

    reg [31:0] address;
    wire [31:0] instruction;

    im UUT (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        $display("===== INSTRUCTION MEMORY TESTBENCH =====");
        
        // Test 1: Read from address 0
        address = 32'd0;
        #5;
        $display("Test 1 - Address 0: Got instruction %h", instruction);
        
        // Test 2: Read from address 1
        address = 32'd1;
        #5;
        $display("Test 2 - Address 1: Got instruction %h", instruction);
        
        // Test 3: Read from address 2
        address = 32'd2;
        #5;
        $display("Test 3 - Address 2: Got instruction %h", instruction);
        
        // Test 4: Read from address 10
        address = 32'd10;
        #5;
        $display("Test 4 - Address 10: Got instruction %h (should be DEAD_BEEF from init)", instruction);
        
        // Test 5: Out of bounds read (should return 0)
        address = 32'd1000;
        #5;
        $display("Test 5 - Address 1000 (out of bounds): Got instruction %h %s", 
                 instruction, (instruction == 32'h0000_0000) ? "PASS (returns 0)" : "FAIL");
        
        // Test 6: Verify pre-initialized value
        address = 32'd10;
        #5;
        $display("Test 6 - Address 10 (pre-loaded): Expected DEAD_BEEF, Got %h %s", 
                 instruction, (instruction == 32'hDEAD_BEEF) ? "PASS" : "FAIL");
        
        // Test 7: Sequential reads
        address = 32'd0;
        #5;
        $display("Test 7a - Sequential addr 0: Got %h", instruction);
        
        address = 32'd1;
        #5;
        $display("Test 7b - Sequential addr 1: Got %h", instruction);
        
        address = 32'd2;
        #5;
        $display("Test 7c - Sequential addr 2: Got %h", instruction);
        
        $display("========================================");
        $finish;
    end

endmodule
