`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_immgen
// Tests immediate value generator with sign extension
// 10-bit signed immediate (bits 31:22) -> 32-bit sign-extended output
//////////////////////////////////////////////////////////////////////////////////

module tb_immgen;

    reg [31:0] instruction;
    wire [31:0] imm_out;

    immgen UUT (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    initial begin
        $display("========= IMMGEN TESTBENCH =========");
        
        // Test 1: Positive immediate (MSB=0)
        instruction = {10'b0000000001, 22'b0};
        // Immediate field (bits 31:22) = 0000000001 -> 0x001
        #5;
        $display("Test 1 - Positive imm (0x001): Expected 0x00000001, Got %h %s", 
                 imm_out, (imm_out == 32'h0000_0001) ? "PASS" : "FAIL");
        
        // Test 2: Zero immediate
        instruction = {10'b0000000000, 22'b0};
        #5;
        $display("Test 2 - Zero imm: Expected 0x00000000, Got %h %s", 
                 imm_out, (imm_out == 32'h0000_0000) ? "PASS" : "FAIL");
        
        // Test 3: Max positive immediate (511 = 0b0111111111)
        instruction = {10'b0111111111, 22'b0};
        // Immediate bits 31:22 = 0111111111
        #5;
        $display("Test 3 - Max positive (0x1FF): Expected 0x000001FF, Got %h %s", 
                 imm_out, (imm_out == 32'h0000_01FF) ? "PASS" : "FAIL");
        
        // Test 4: Negative immediate (MSB=1), min value (-512 = 0b1000000000)
        instruction = {10'b1000000000, 22'b0};
        // Immediate bits 31:22 = 1000000000
        // Should sign-extend to 0xFFFFFE00
        #5;
        $display("Test 4 - Min negative (-512 = 0xFFFFFE00): Expected 0xFFFFFE00, Got %h %s", 
                 imm_out, (imm_out == 32'hFFFF_FE00) ? "PASS" : "FAIL");
        
        // Test 5: Negative immediate (-1 = 0b1111111111)
        instruction = {10'b1111111111, 22'b0};
        // Immediate bits 31:22 = 1111111111
        // Should sign-extend to 0xFFFFFFFF
        #5;
        $display("Test 5 - Negative (-1 = 0xFFFFFFFF): Expected 0xFFFFFFFF, Got %h %s", 
                 imm_out, (imm_out == 32'hFFFF_FFFF) ? "PASS" : "FAIL");
        
        // Test 6: Immediate = -100
        // -100 in 10-bit two's complement = 1110011100 (0x39C)
        instruction = {10'b1110011100, 22'b0};
        #5;
        $display("Test 6 - Negative (-100): Expected 0xFFFFFF9C, Got %h %s", 
                 imm_out, (imm_out == 32'hFFFF_FF9C) ? "PASS" : "FAIL");
        
        // Test 7: Positive = 100
        // 100 in 10-bit = 0001100100 (0x064)
        instruction = {10'b0001100100, 22'b0};
        #5;
        $display("Test 7 - Positive (100): Expected 0x00000064, Got %h %s", 
                 imm_out, (imm_out == 32'h0000_0064) ? "PASS" : "FAIL");
        
        $display("=====================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_immgen.vcd");
        $dumpvars(0, tb_immgen);
    end
endmodule
