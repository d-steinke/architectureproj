`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: im_simple
// Simple instruction memory for basic pipeline testing
//////////////////////////////////////////////////////////////////////////////////

module im_simple(
    input wire [31:0] address,     
    output reg [31:0] instruction  
);
    parameter MEM_SIZE = 256;

    reg [31:0] mem [0:MEM_SIZE-1];
    integer i;

    always @(*) begin
        if (address >= 0 && address < MEM_SIZE) begin
            instruction = mem[address];
        end else begin
            instruction = 32'h00000000; 
        end
    end

    initial begin
        mem[0] = 32'h0000028F; // SVPC x40, 1
        mem[1] = 32'h01410005; // INC x1, x0, 5
        mem[2] = 32'h00c20005; // INC x2, x0, 3
        mem[3] = 32'h00030424;  // ADD x3, x1, x2
        mem[4] = 32'h00000000; // NOP
        $display("IM_SIMPLE: mem[0]=%h mem[1]=%h mem[2]=%h mem[3]=%h mem[4]=%h", mem[0], mem[1], mem[2], mem[3], mem[4]);
    end

endmodule

