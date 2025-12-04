`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_dmem
// Tests data memory read/write operations
//////////////////////////////////////////////////////////////////////////////////

module tb_dmem;

    reg clk;
    reg [31:0] address;
    reg [31:0] write_data;
    reg mem_write;
    wire [31:0] read_data;

    dmem UUT (
        .clk(clk),
        .address(address),
        .write_data(write_data),
        .mem_write(mem_write),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $display("========== DATA MEMORY TESTBENCH ==========\n");

        mem_write = 0;
        address = 0;

        // Test 1: Read from uninitialized memory
        #5;
        $display("Test 1 - Read addr 0: read_data=%h (Expected 0) %s",
                 read_data, (read_data == 0) ? "PASS" : "FAIL");

        // Test 2: Write to address 0
        @(posedge clk);
        mem_write = 1;
        address = 32'd0;
        write_data = 32'hDEAD_BEEF;
        @(posedge clk);

        // Test 3: Read back from address 0
        mem_write = 0;
        address = 32'd0;
        #10;
        $display("Test 3 - Read addr 0 after write: read_data=%h (Expected DEAD_BEEF) %s",
                 read_data, (read_data == 32'hDEAD_BEEF) ? "PASS" : "FAIL");

        // Test 4: Write to multiple addresses
        @(posedge clk);
        mem_write = 1;
        address = 32'd10;
        write_data = 32'hCAFE_BABE;
        @(posedge clk);

        address = 32'd20;
        write_data = 32'h5555_5555;
        @(posedge clk);

        // Test 5: Read from different addresses
        mem_write = 0;
        address = 32'd10;
        #10;
        $display("Test 5 - Read addr 10: read_data=%h (Expected CAFE_BABE) %s",
                 read_data, (read_data == 32'hCAFE_BABE) ? "PASS" : "FAIL");

        address = 32'd20;
        #10;
        $display("Test 6 - Read addr 20: read_data=%h (Expected 5555_5555) %s",
                 read_data, (read_data == 32'h5555_5555) ? "PASS" : "FAIL");

        // Test 7: Out of bounds read
        address = 32'd300;
        #10;
        $display("Test 7 - Read out of bounds addr 300: read_data=%h (Expected 0) %s",
                 read_data, (read_data == 0) ? "PASS" : "FAIL");

        // Test 8: Disabled write (mem_write = 0)
        @(posedge clk);
        mem_write = 0;
        address = 32'd0;
        write_data = 32'hFFFF_FFFF;
        @(posedge clk);

        address = 32'd0;
        #10;
        $display("Test 8 - Read addr 0 (write disabled): read_data=%h (Expected DEAD_BEEF) %s",
                 read_data, (read_data == 32'hDEAD_BEEF) ? "PASS" : "FAIL");

        $display("\n========== TEST COMPLETE ==========\n");
        $finish;
    end


    initial begin
        $dumpfile("tb_dmem.vcd");
        $dumpvars(0, tb_dmem);
    end
endmodule
