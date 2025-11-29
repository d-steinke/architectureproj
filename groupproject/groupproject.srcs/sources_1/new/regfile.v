`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 04:24:48 PM
// Design Name: 
// Module Name: regfile
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


module regfile(
    input wire clk,
    input wire rst,
    input wire reg_write_en,        
    input wire [5:0] read_reg1,     
    input wire [5:0] read_reg2,    
    input wire [5:0] write_reg,   
    input wire [31:0] write_data,  
    output reg [31:0] read_data1,  
    output reg [31:0] read_data2   
);

    reg [31:0] registers [0:63];
    integer i;

    always @(*) begin
        read_data1 = registers[read_reg1];
        read_data2 = registers[read_reg2];
    end

    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                registers[i] <= 32'd0;
            end
        end else if (reg_write_en) begin
            registers[write_reg] <= write_data;
        end
    end

endmodule
