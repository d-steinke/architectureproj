`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 06:42:16 PM
// Design Name: 
// Module Name: pc
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


module pc (
    input wire clk,             
    input wire rst,             
    input wire [31:0] pc_in,    
    output reg [31:0] pc_out    
);

    initial pc_out = 32'd0;

    always @(posedge clk) begin
        if (rst) begin
            pc_out <= 32'd0;
        end else begin
            pc_out <= pc_in;
        end
    end

endmodule
