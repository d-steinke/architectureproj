`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 06:41:06 PM
// Design Name: 
// Module Name: mux
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



module mux (
    input wire [31:0] in0,      // Input 0 (default: PC + 1)
    input wire [31:0] in1,      // Input 1 (Branch/Jump Target)
    input wire sel,             // Selection Signal (0 for in0, 1 for in1)
    output wire [31:0] out      // Output (Next PC value)
);

    assign out = (sel) ? in1 : in0;

endmodule
