`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/19/2025 06:09:29 PM
// Design Name: 
// Module Name: tb_ifid
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


module tb_ifid();
reg clk;
reg [31:0] instr_in;
reg [31:0] pc_in;
wire [31:0] instr_out;
wire [31:0] pc_out;

ifid test(
    .clk(clk),
    .instr_in(instr_in),
    .pc_in(pc_in),
    .instr_out(instr_out),
    .pc_out(pc_out)
);

initial begin
    clk = 1;
    forever #5 clk = ~clk;
end

initial begin
    instr_in = 32'd1;
    pc_in = 32'd10;
    #50;
    instr_in = 32'd6320;
    pc_in = 32'd14;
    #50;
    $finish;
    end
endmodule
