`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_pc
// Tests the Program Counter module
//////////////////////////////////////////////////////////////////////////////////

module tb_pc;

    reg clk;
    reg rst;
    reg [31:0] pc_in;
    wire [31:0] pc_out;

    pc UUT (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== PC TESTBENCH ==========");
        
        // Test 1: Reset functionality
        rst = 1;
        pc_in = 32'hDEAD_BEEF;
        #10;
        $display("Test 1 - Reset: Expected 0, Got %h %s", pc_out, (pc_out == 32'd0) ? "PASS" : "FAIL");
        
        // Test 2: Load value after reset release
        rst = 0;
        pc_in = 32'd1000;
        #10;
        $display("Test 2 - Load 1000: Expected 1000, Got %d %s", pc_out, (pc_out == 32'd1000) ? "PASS" : "FAIL");
        
        // Test 3: PC increment (PC + 1)
        pc_in = 32'd1001;
        #10;
        $display("Test 3 - Increment to 1001: Expected 1001, Got %d %s", pc_out, (pc_out == 32'd1001) ? "PASS" : "FAIL");
        
        // Test 4: PC continues incrementing
        pc_in = 32'd1002;
        #10;
        $display("Test 4 - Increment to 1002: Expected 1002, Got %d %s", pc_out, (pc_out == 32'd1002) ? "PASS" : "FAIL");
        
        // Test 5: Reset mid-execution
        rst = 1;
        #10;
        $display("Test 5 - Reset mid-exec: Expected 0, Got %h %s", pc_out, (pc_out == 32'd0) ? "PASS" : "FAIL");
        
        // Test 6: Resume after reset
        rst = 0;
        pc_in = 32'd500;
        #10;
        $display("Test 6 - Resume at 500: Expected 500, Got %d %s", pc_out, (pc_out == 32'd500) ? "PASS" : "FAIL");
        
        // Test 7: Branch (jump to arbitrary address)
        pc_in = 32'd10;
        #10;
        $display("Test 7 - Branch to 10: Expected 10, Got %d %s", pc_out, (pc_out == 32'd10) ? "PASS" : "FAIL");
        
        $display("=====================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_pc.vcd");
        $dumpvars(0, tb_pc);
    end
endmodule
