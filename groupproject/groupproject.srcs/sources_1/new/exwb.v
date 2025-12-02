`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: exwb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: EX/WB Pipeline Register - buffers execute stage outputs to writeback stage
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module exwb (
    input wire clk,
    input wire rst,
    
    // From EX Stage
    input wire [31:0] ex_alu_result,
    input wire [31:0] ex_mem_data,
    input wire [5:0] ex_rd,
    input wire [5:0] ex_rt,
    input wire [3:0] ex_opcode,
    input wire ex_zero_flag,
    input wire ex_neg_flag,
    
    // Control Signals from EX Stage
    input wire ex_reg_write,
    input wire ex_mem_to_reg,
    
    // To WB Stage
    output reg [31:0] wb_alu_result,
    output reg [31:0] wb_mem_data,
    output reg [5:0] wb_rd,
    output reg [5:0] wb_rt,
    output reg [3:0] wb_opcode,
    output reg wb_zero_flag,
    output reg wb_neg_flag,
    
    // Control Signals to WB Stage
    output reg wb_reg_write,
    output reg wb_mem_to_reg
);

    always @(posedge clk) begin
        if (rst) begin
            wb_alu_result <= 32'd0;
            wb_mem_data <= 32'd0;
            wb_rd <= 6'd0;
            wb_rt <= 6'd0;
            wb_opcode <= 4'd0;
            wb_zero_flag <= 1'b0;
            wb_neg_flag <= 1'b0;
            
            wb_reg_write <= 1'b0;
            wb_mem_to_reg <= 1'b0;
        end else begin
            wb_alu_result <= ex_alu_result;
            wb_mem_data <= ex_mem_data;
            wb_rd <= ex_rd;
            wb_rt <= ex_rt;
            wb_opcode <= ex_opcode;
            wb_zero_flag <= ex_zero_flag;
            wb_neg_flag <= ex_neg_flag;
            
            wb_reg_write <= ex_reg_write;
            wb_mem_to_reg <= ex_mem_to_reg;
            // Debug: show values latched into EX/WB
            $display("EXWB @%0t latched alu=%h mem=%h rd=%0d rt=%0d opcode=%h regw=%b memtoreg=%b", $time, ex_alu_result, ex_mem_data, ex_rd, ex_rt, ex_opcode, ex_reg_write, ex_mem_to_reg);
        end
    end

endmodule

