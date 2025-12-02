`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_alu
// Tests ALU operations: add, subtract, negate, pass
// Control codes: 000=add, 101=sub, 110=neg, 111=pass
//////////////////////////////////////////////////////////////////////////////////

module tb_alu;

    reg [31:0] a, b;
    reg [2:0] alu_control;
    wire [31:0] result;
    wire zero, negative;

    alu UUT (
        .a(a),
        .b(b),
        .alu_control(alu_control),
        .result(result),
        .zero(zero),
        .negative(negative)
    );

    initial begin
        $display("============ ALU TESTBENCH ============");
        
        // Test 1: ADD (000) - basic addition
        a = 32'd10;
        b = 32'd20;
        alu_control = 3'b000;
        #5;
        $display("Test 1 - ADD 10+20: Expected 30, Got %d | Zero=%b, Neg=%b %s", 
                 result, zero, negative, (result == 32'd30 && zero == 0 && negative == 0) ? "PASS" : "FAIL");
        
        // Test 2: ADD resulting in ZERO flag
        a = 32'd100;
        b = 32'hFFFF_FF9C; // -100
        alu_control = 3'b000;
        #5;
        $display("Test 2 - ADD 100+(-100): Expected 0, Zero=1 | Got %d, Zero=%b %s", 
                 result, zero, (result == 32'd0 && zero == 1) ? "PASS" : "FAIL");
        
        // Test 3: ADD resulting in NEGATIVE flag
        a = 32'hFFFF_FFFF; // -1
        b = 32'hFFFF_FFFF; // -1
        alu_control = 3'b000;
        #5;
        $display("Test 3 - ADD (-1)+(-1): Expected -2, Neg=1 | Got %h, Neg=%b %s", 
                 result, negative, (result == 32'hFFFF_FFFE && negative == 1) ? "PASS" : "FAIL");
        
        // Test 4: SUB (101) - basic subtraction
        a = 32'd50;
        b = 32'd30;
        alu_control = 3'b101;
        #5;
        $display("Test 4 - SUB 50-30: Expected 20, Got %d %s", 
                 result, (result == 32'd20) ? "PASS" : "FAIL");
        
        // Test 5: SUB resulting in ZERO
        a = 32'd100;
        b = 32'd100;
        alu_control = 3'b101;
        #5;
        $display("Test 5 - SUB 100-100: Expected 0, Zero=1 | Got %d, Zero=%b %s", 
                 result, zero, (result == 32'd0 && zero == 1) ? "PASS" : "FAIL");
        
        // Test 6: SUB resulting in NEGATIVE
        a = 32'd10;
        b = 32'd50;
        alu_control = 3'b101;
        #5;
        $display("Test 6 - SUB 10-50: Expected -40, Neg=1 | Got %h, Neg=%b %s", 
                 result, negative, (result == 32'hFFFF_FFD8 && negative == 1) ? "PASS" : "FAIL");
        
        // Test 7: NEG (110) - negate operand A
        a = 32'd42;
        b = 32'd0; // unused
        alu_control = 3'b110;
        #5;
        $display("Test 7 - NEG 42: Expected -42, Got %h, Neg=%b %s", 
                 result, negative, (result == 32'hFFFF_FFD6 && negative == 1) ? "PASS" : "FAIL");
        
        // Test 8: NEG zero
        a = 32'd0;
        alu_control = 3'b110;
        #5;
        $display("Test 8 - NEG 0: Expected 0, Zero=1 | Got %d, Zero=%b %s", 
                 result, zero, (result == 32'd0 && zero == 1) ? "PASS" : "FAIL");
        
        // Test 9: NEG negative number
        a = 32'hFFFF_FFFF; // -1
        alu_control = 3'b110;
        #5;
        $display("Test 9 - NEG (-1): Expected 1, Got %d %s", 
                 result, (result == 32'd1) ? "PASS" : "FAIL");
        
        // Test 10: PASS (111) - output A unchanged
        a = 32'hDEAD_BEEF;
        b = 32'hBEEF_DEAD;
        alu_control = 3'b111;
        #5;
        $display("Test 10 - PASS: Expected %h, Got %h %s", 
                 a, result, (result == a) ? "PASS" : "FAIL");
        
        // Test 11: NOP behavior (if alu_control is 3'b001 or 3'b010 or 3'b011 or 3'b100)
        a = 32'd5;
        b = 32'd7;
        alu_control = 3'b001;
        #5;
        $display("Test 11 - Default case (001): Got %h %s", result, (result == 32'd0) ? "Default returns 0 - PASS" : "FAIL");
        
        $display("========================================");
        $finish;
    end

endmodule
