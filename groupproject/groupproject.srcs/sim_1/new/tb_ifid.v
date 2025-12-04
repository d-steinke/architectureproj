`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 06:09:29 PM
// Design Name: 
// Module Name: tb_ifid
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_ifid
// Tests IF/ID pipeline register (instruction and PC buffering)
//////////////////////////////////////////////////////////////////////////////////

module tb_ifid;

    reg clk;
    reg [31:0] instr_in, pc_in;
    wire [31:0] instr_out, pc_out;

    ifid UUT (
        .clk(clk),
        .instr_in(instr_in),
        .pc_in(pc_in),
        .instr_out(instr_out),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("======= IF/ID PIPELINE TESTBENCH =======");
        
        instr_in = 32'h0000_0000;
        pc_in = 32'h0000_0000;
        
        // Test 1: Initial state
        #5;
        $display("Test 1 - Initial: instr_out=%h, pc_out=%h", instr_out, pc_out);
        
        // Test 2: Load values on clock edge
        instr_in = 32'hAAAA_AAAA;
        pc_in = 32'h0000_0001;
        #10;
        $display("Test 2 - After 1st cycle: instr=%h, pc=%h %s", 
                 instr_out, pc_out,
                 (instr_out == 32'hAAAA_AAAA && pc_out == 32'h0000_0001) ? "PASS" : "FAIL");
        
        // Test 3: Update with new values
        instr_in = 32'hBBBB_BBBB;
        pc_in = 32'h0000_0002;
        #10;
        $display("Test 3 - After 2nd cycle: instr=%h, pc=%h %s", 
                 instr_out, pc_out,
                 (instr_out == 32'hBBBB_BBBB && pc_out == 32'h0000_0002) ? "PASS" : "FAIL");
        
        // Test 4: Verify previous values don't leak
        instr_in = 32'hCCCC_CCCC;
        pc_in = 32'h0000_0003;
        #10;
        $display("Test 4 - After 3rd cycle: instr=%h, pc=%h %s", 
                 instr_out, pc_out,
                 (instr_out == 32'hCCCC_CCCC && pc_out == 32'h0000_0003) ? "PASS" : "FAIL");
        
        // Test 5: Stress with all 1s
        instr_in = 32'hFFFF_FFFF;
        pc_in = 32'hFFFF_FFFF;
        #10;
        $display("Test 5 - All 1s: instr=%h, pc=%h %s", 
                 instr_out, pc_out,
                 (instr_out == 32'hFFFF_FFFF && pc_out == 32'hFFFF_FFFF) ? "PASS" : "FAIL");
        
        // Test 6: Stress with all 0s
        instr_in = 32'h0000_0000;
        pc_in = 32'h0000_0000;
        #10;
        $display("Test 6 - All 0s: instr=%h, pc=%h %s", 
                 instr_out, pc_out,
                 (instr_out == 32'h0000_0000 && pc_out == 32'h0000_0000) ? "PASS" : "FAIL");
        
        $display("=========================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_ifid.vcd");
        $dumpvars(0, tb_ifid);
    end
endmodule

