`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: dmem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Data Memory - Read/write memory for LD/ST instructions
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module dmem (
    input wire clk,
    input wire [31:0] address,      // Memory address (word-addressed)
    input wire [31:0] write_data,   // Data to write
    input wire mem_write,           // Write enable
    output reg [31:0] read_data     // Data read from memory
);

    parameter MEM_SIZE = 256;
    reg [31:0] mem [0:MEM_SIZE-1];
    integer i;

    // Combinational read
    always @(*) begin
        if (address >= 0 && address < MEM_SIZE) begin
            read_data = mem[address];
        end else begin
            read_data = 32'h00000000;
        end
    end

    // Synchronous write
    always @(posedge clk) begin
        if (mem_write) begin
            if (address >= 0 && address < MEM_SIZE) begin
                mem[address] <= write_data;
            end
        end
    end

    // Initialize memory with some test data
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end

endmodule

