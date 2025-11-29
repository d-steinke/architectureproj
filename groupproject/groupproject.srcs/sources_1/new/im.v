`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 06:24:39 PM
// Design Name: 
// Module Name: im
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

module im(
    input wire [31:0] address,     
    output reg [31:0] instruction  
);
    parameter MEM_SIZE = 256;

    reg [31:0] mem [0:MEM_SIZE-1];

always @(*) begin
        if (address >= 0 && address < MEM_SIZE) begin
            instruction = mem[address];
        end else begin
            instruction = 32'h00000000; 
        end
    end

integer i;
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
    end
endmodule
