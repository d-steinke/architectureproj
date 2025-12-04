`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_adder
// Tests the adder module with various input combinations
//////////////////////////////////////////////////////////////////////////////////

module tb_adder;

    reg [31:0] a, b;
    wire [31:0] out;

    adder UUT (
        .a(a),
        .b(b),
        .out(out)
    );

    initial begin
        $display("========== ADDER TESTBENCH ==========");
        
        // Test 1: Simple addition
        a = 32'd10;
        b = 32'd20;
        #5;
        $display("Test 1 - Add 10 + 20: Expected 30, Got %d %s", out, (out == 32'd30) ? "PASS" : "FAIL");
        
        // Test 2: Add with zero
        a = 32'd100;
        b = 32'd0;
        #5;
        $display("Test 2 - Add 100 + 0: Expected 100, Got %d %s", out, (out == 32'd100) ? "PASS" : "FAIL");
        
        // Test 3: Large numbers
        a = 32'hFFFF_FFFF;
        b = 32'd1;
        #5;
        $display("Test 3 - Add 0xFFFFFFFF + 1: Expected 0x00000000, Got %h %s", out, (out == 32'h0000_0000) ? "PASS" : "FAIL");
        
        // Test 4: PC increment (1 + current)
        a = 32'd1000;
        b = 32'd1;
        #5;
        $display("Test 4 - PC+1 (1000 + 1): Expected 1001, Got %d %s", out, (out == 32'd1001) ? "PASS" : "FAIL");
        
        // Test 5: Negative numbers (two's complement)
        a = 32'hFFFF_FFFF; // -1
        b = 32'hFFFF_FFFF; // -1
        #5;
        $display("Test 5 - Add -1 + -1: Expected 0xFFFFFFFE (-2), Got %h %s", out, (out == 32'hFFFF_FFFE) ? "PASS" : "FAIL");
        
        // Test 6: Mixed signs
        a = 32'd50;
        b = 32'hFFFF_FFCE; // -50 in two's complement
        #5;
        $display("Test 6 - Add 50 + (-50): Expected 0, Got %d %s", out, (out == 32'd0) ? "PASS" : "FAIL");
        
        $display("====================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_adder.vcd");
        $dumpvars(0, tb_adder);
    end
endmodule
