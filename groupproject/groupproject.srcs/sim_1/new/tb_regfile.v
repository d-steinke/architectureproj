`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_regfile
// Tests register file: read/write operations, reset, register isolation
//////////////////////////////////////////////////////////////////////////////////

module tb_regfile;

    reg clk;
    reg rst;
    reg reg_write_en;
    reg [5:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;

    regfile UUT (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .read_reg1(read_reg1),
        .read_reg2(read_reg2),
        .write_reg(write_reg),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Helper task to perform a synchronous write (stable before posedge)
    task do_write;
        input [5:0] regnum;
        input [31:0] data;
        begin
            reg_write_en = 1;
            write_reg = regnum;
            write_data = data;
            @(posedge clk);
            #1; // Hold the write enable for a short time after the clock edge
            reg_write_en = 0;
        end
    endtask

    initial begin
        $display("======= REGISTER FILE TESTBENCH =======");
        
        // Test 1: Reset
        rst = 1;
        reg_write_en = 0;
        read_reg1 = 6'd1;
        read_reg2 = 6'd2;
        #10;
        $display("Test 1 - After Reset: x1=%d, x2=%d %s", 
                 read_data1, read_data2, (read_data1 == 0 && read_data2 == 0) ? "PASS" : "FAIL");
        
        rst = 0;
        
        // Test 2: Write to x1
        $display("Test 2a - Writing 100 to x1...");
        do_write(6'd1, 32'd100);
        read_reg1 = 6'd1;
        @(posedge clk);
        $display("Test 2b - Read x1: Expected 100, Got %d %s", 
             read_data1, (read_data1 == 32'd100) ? "PASS" : "FAIL");
        
        // Test 3: Write to x2
        $display("Test 3a - Writing 200 to x2...");
        do_write(6'd2, 32'd200);
        read_reg1 = 6'd1;
        read_reg2 = 6'd2;
        @(posedge clk);
        $display("Test 3b - Read x1=%d, x2=%d %s", 
             read_data1, read_data2, 
             (read_data1 == 32'd100 && read_data2 == 32'd200) ? "PASS" : "FAIL");
        
        // Test 4: Simultaneous read from multiple registers
        // Test 4: Simultaneous read from multiple registers
        do_write(6'd5, 32'hDEAD_BEEF);
        do_write(6'd10, 32'hCAFE_BABE);
        read_reg1 = 6'd5;
        read_reg2 = 6'd10;
        @(posedge clk);
        $display("Test 4 - Multi-read x5=%h, x10=%h %s", 
             read_data1, read_data2,
             (read_data1 == 32'hDEAD_BEEF && read_data2 == 32'hCAFE_BABE) ? "PASS" : "FAIL");
        
        // Test 5: Disabled write (reg_write_en = 0)
        @(posedge clk);
        reg_write_en = 0;
        write_reg = 6'd15;
        write_data = 32'h1234_5678;
        
        @(posedge clk);
        read_reg1 = 6'd15;
        @(posedge clk);
        $display("Test 5 - No write when disabled: x15=%d %s", 
                 read_data1, (read_data1 == 32'd0) ? "PASS" : "FAIL");
        
        // Test 6: Boundary registers (x0, x63)
        reg_write_en = 1;
        write_reg = 6'd0;
        write_data = 32'hFFFF_FFFF;

        #1; @(posedge clk);
        reg_write_en = 1;
        write_reg = 6'd63;
        write_data = 32'h5555_5555;

        #1; @(posedge clk);
        reg_write_en = 0;
        read_reg1 = 6'd0;
        read_reg2 = 6'd63;
        @(posedge clk);
        $display("Test 6 - Boundary x0=%h, x63=%h %s", 
             read_data1, read_data2,
             (read_data1 == 32'hFFFF_FFFF && read_data2 == 32'h5555_5555) ? "PASS" : "FAIL");
        
        // Test 7: Reset clears all registers
        @(posedge clk);
        rst = 1;
        #10;
        rst = 0;
        
        @(posedge clk);
        read_reg1 = 6'd1;
        read_reg2 = 6'd63;
        @(posedge clk);
        $display("Test 7 - After reset: x1=%d, x63=%d %s", 
                 read_data1, read_data2, (read_data1 == 0 && read_data2 == 0) ? "PASS" : "FAIL");
        
        $display("========================================");
        $finish;
    end


    initial begin
        $dumpfile("tb_regfile.vcd");
        $dumpvars(0, tb_regfile);
    end
endmodule
