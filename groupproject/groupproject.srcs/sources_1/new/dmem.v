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
    integer i, j;

    // Combinational read
    always @(*) begin
        if (address >= 0 && address < MEM_SIZE) begin
            read_data = mem[address];
        end else begin
            read_data = 32'h00000000;
        end
    end

    // Synchronous write — also accept immediate writes when mem_write rises
    always @(posedge clk or posedge mem_write) begin
        if (mem_write) begin
            if (address >= 0 && address < MEM_SIZE) begin
                mem[address] <= write_data;
            end
        end
    end

    // Initialize memory with test array data
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
        
        // Prepopulate array at addresses 100-109 (safe from any hardcoded jumps)
        // This will be the input array for the 1D media program
        mem[100] = 32'd5;
        mem[101] = 32'd10;
        mem[102] = 32'd3;
        mem[103] = 32'd7;
        mem[104] = 32'd2;
        mem[105] = 32'd8;
        mem[106] = 32'd1;
        mem[107] = 32'd9;
        mem[108] = 32'd4;
        mem[109] = 32'd6;
    end

endmodule

