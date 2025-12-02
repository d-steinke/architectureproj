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
    output [31:0] read_data1,
    output [31:0] read_data2,
    output wire [31:0] debug_r1,
    output wire [31:0] debug_r2
);

    reg [31:0] registers [0:63];
    integer i;

    // Synchronous write, asynchronous read with write-forwarding
    // If a write is occurring this cycle to the same register being read,
    // forward `write_data` so the read sees the newly written value.
    assign read_data1 = (reg_write_en && (write_reg == read_reg1)) ? write_data : registers[read_reg1];
    assign read_data2 = (reg_write_en && (write_reg == read_reg2)) ? write_data : registers[read_reg2];

    // Synchronous write on clock edge; async reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 64; i = i + 1) begin
                registers[i] <= 32'd0;
            end
            $display("%M: regfile reset at %0t", $time);
        end else begin
            if (reg_write_en) begin
                registers[write_reg] <= write_data;
                $display("%M: write reg %0d <= %h at %0t (we=%b read1=%0d read2=%0d)", write_reg, write_data, $time, reg_write_en, read_reg1, read_reg2);
            end
        end
    end

    // Expose a couple of registers for outside debug (reg 1 and reg 2)
    assign debug_r1 = registers[1];
    assign debug_r2 = registers[2];

    task initialize_register;
        input [5:0] reg_index;
        input [31:0] reg_value;
        begin
            registers[reg_index] = reg_value;
        end
    endtask

endmodule
