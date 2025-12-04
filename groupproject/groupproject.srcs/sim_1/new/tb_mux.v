`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_mux
// Tests the 2-to-1 multiplexer
//////////////////////////////////////////////////////////////////////////////////

module tb_mux;

    reg [31:0] in0, in1;
    reg sel;
    wire [31:0] out;

    mux UUT (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out(out)
    );

    initial begin
        $display("========== MUX TESTBENCH ==========");
        
        // Test 1: Select in0 (sel=0)
        in0 = 32'hAAAA_AAAA;
        in1 = 32'hBBBB_BBBB;
        sel = 1'b0;
        #5;
        $display("Test 1 - sel=0: Expected %h, Got %h %s", in0, out, (out == in0) ? "PASS" : "FAIL");
        
        // Test 2: Select in1 (sel=1)
        sel = 1'b1;
        #5;
        $display("Test 2 - sel=1: Expected %h, Got %h %s", in1, out, (out == in1) ? "PASS" : "FAIL");
        
        // Test 3: Toggle sel multiple times
        sel = 1'b0;
        #5;
        if (out != in0) $display("Test 3a FAIL");
        sel = 1'b1;
        #5;
        if (out != in1) $display("Test 3b FAIL");
        sel = 1'b0;
        #5;
        $display("Test 3 - Toggle: %s", (out == in0) ? "PASS" : "FAIL");
        
        // Test 4: PC+1 path (in0)
        in0 = 32'd1001;  // PC + 1
        in1 = 32'd100;   // Branch target
        sel = 1'b0;
        #5;
        $display("Test 4 - PC+1 path: Expected 1001, Got %d %s", out, (out == 32'd1001) ? "PASS" : "FAIL");
        
        // Test 5: Branch target path (in1)
        sel = 1'b1;
        #5;
        $display("Test 5 - Branch target: Expected 100, Got %d %s", out, (out == 32'd100) ? "PASS" : "FAIL");
        
        $display("====================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_mux.vcd");
        $dumpvars(0, tb_mux);
    end
endmodule
