`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 05:34:59 PM
// Design Name: 
// Module Name: alu
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



module alu(
    input wire [31:0] a,      
    input wire [31:0] b,     
    input wire [2:0] alu_control,
    output reg [31:0] result, 
    output wire zero,          
    output wire negative      
);

    wire cmd_add = alu_control[2];
    wire cmd_neg = alu_control[1];
    wire cmd_sub = alu_control[0]; 

    always @(*) begin
        case (alu_control)
            3'b000: result = a + b;       
            3'b101: result = a - b;       
            3'b110: result = -a;          
            3'b111: result = a;           
            default: result = 32'd0;       
        endcase
    end

    assign zero = (result == 32'd0);
    assign negative = result[31]; 

endmodule
