`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2025
// Design Name: 
// Module Name: forwarding
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


module forwarding (
    input wire [5:0] id_ex_rs,          
    input wire [5:0] id_ex_rt,         
    input wire [5:0] ex_wb_rd,       
    input wire ex_wb_reg_write,        
    input wire [5:0] mem_rd,            
    input wire mem_reg_write,          
    
    input wire [31:0] id_ex_reg_data1,   
    input wire [31:0] id_ex_reg_data2,  
    input wire [31:0] ex_wb_alu_result, 
    input wire [31:0] mem_alu_result,    
    
    output wire [31:0] alu_input1,      
    output wire [31:0] alu_input2        
);

    // Forward RS (id_ex_rs)
    assign alu_input1 = 
        (id_ex_rs == ex_wb_rd && ex_wb_reg_write && id_ex_rs != 0) ? ex_wb_alu_result :
        (id_ex_rs == mem_rd && mem_reg_write && id_ex_rs != 0) ? mem_alu_result :
        id_ex_reg_data1;

    // Forward RT (id_ex_rt)
    assign alu_input2 = 
        (id_ex_rt == ex_wb_rd && ex_wb_reg_write && id_ex_rt != 0) ? ex_wb_alu_result :
        (id_ex_rt == mem_rd && mem_reg_write && id_ex_rt != 0) ? mem_alu_result :
        id_ex_reg_data2;

endmodule

