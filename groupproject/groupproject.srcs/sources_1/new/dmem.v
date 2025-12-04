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
// Description: 
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
    input wire [31:0] address,     
    input wire [31:0] write_data,  
    input wire mem_write,          
    output reg [31:0] read_data   
);

    parameter MEM_SIZE = 256;
    reg [31:0] mem [0:MEM_SIZE-1];
    integer i;

    always @(*) begin
        if (address >= 0 && address < MEM_SIZE) begin
            read_data = mem[address];
        end else begin
            read_data = 32'h00000000;
        end
    end

    always @(posedge clk) begin
        if (mem_write) begin
            if (address >= 0 && address < MEM_SIZE) begin
                mem[address] <= write_data;
            end
        end
    end

    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;
        end
        
        mem[2] = 32'd3;
        mem[3] = 32'd1;
        mem[4] = 32'd5;
        mem[5] = 32'd7;
        mem[6] = 32'd2;
        mem[7] = 32'd9;
        mem[8] = 32'd8;
    end

endmodule

