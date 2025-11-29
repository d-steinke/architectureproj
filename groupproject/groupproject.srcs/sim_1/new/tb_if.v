`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:13:05 PM
// Design Name: 
// Module Name: tb_if
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



module tb_if;

    reg clk;
    reg rst;
    reg pcs_src;               // MUX Select
    reg [31:0] branch_target;  // Input from hypothetical EX stage
    
    wire [31:0] pc_current;    // Output of PC
    wire [31:0] pc_next;       // Output of Mux
    wire [31:0] pc_plus_1;     // Output of Adder
    wire [31:0] imem_instr;    // Output of Instruction Memory (Raw)
    
    wire [31:0] ifid_instr_out;
    wire [31:0] ifid_pc_out;


    mux IF_MUX (
        .in0(pc_plus_1),       
        .in1(branch_target),   
        .sel(pcs_src),         
        .out(pc_next)          
    );

    pc IF_PC (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next),
        .pc_out(pc_current)
    );

    adder IF_ADDER (
        .a(pc_current),
        .b(32'd1),             
        .out(pc_plus_1)
    );

    im IF_IMEM (
        .address(pc_current),
        .instruction(imem_instr)
    );

    ifid IF_ID_BUFFER (
        .clk(clk),
        .instr_in(imem_instr),
        .pc_in(pc_current), 
        .instr_out(ifid_instr_out),
        .pc_out(ifid_pc_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1;
        pcs_src = 0;
        branch_target = 32'd0;

        IF_IMEM.mem[0] = 32'hAAAA_AAAA; 
        IF_IMEM.mem[1] = 32'hBBBB_BBBB; 
        IF_IMEM.mem[2] = 32'hCCCC_CCCC; 
        IF_IMEM.mem[10] = 32'hDEAD_BEEF; 

        #10;
        rst = 0;
        $display("Time: %0t | Reset Released", $time);

        #10; 
        $display("Time: %0t | PC: %d | Raw Instr: %h | IF/ID Output: %h", 
                 $time, pc_current, imem_instr, ifid_instr_out);

        #10;
        $display("Time: %0t | PC: %d | Raw Instr: %h | IF/ID Output: %h", 
                 $time, pc_current, imem_instr, ifid_instr_out);
        
        pcs_src = 1;
        branch_target = 32'd10;
        $display("Time: %0t | *** Branch Asserted -> 10 ***", $time);

        #10;
        pcs_src = 0; 
        $display("Time: %0t | PC: %d | Raw Instr: %h | IF/ID Output: %h", 
                 $time, pc_current, imem_instr, ifid_instr_out);
        
        #5; 
        $display("Time: %0t (NegEdge) | IF/ID Output Updated to: %h", 
                 $time, ifid_instr_out);

        #20;
        $finish;
    end

endmodule