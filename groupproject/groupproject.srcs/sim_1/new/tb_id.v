`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/25/2025 05:09:46 PM
// Design Name: 
// Module Name: tb_id
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




module tb_id;

    reg clk;
    reg rst;
    
    reg [31:0] instruction;
    
    reg wb_reg_write;
    reg [5:0] wb_write_reg;
    reg [31:0] wb_write_data;

    wire [31:0] read_data1;   
    wire [31:0] read_data2;  
    wire [31:0] imm_out;     
    
    wire reg_write;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire [2:0] alu_op;
    wire branch;
    wire jump;


   
    regfile ID_REG_FILE (
        .clk(clk),
        .rst(rst),
        .reg_write_en(wb_reg_write),   // Input from WB stage
        .read_reg1(instruction[15:10]), // RS
        .read_reg2(instruction[9:4]),   // RT
        .write_reg(wb_write_reg),       // Input from WB stage
        .write_data(wb_write_data),     // Input from WB stage
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    immgen ID_IMM_GEN (
        .instruction(instruction),
        .imm_out(imm_out)
    );

    controlunit ID_CONTROL (
        .opcode(instruction[3:0]),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1;
        wb_reg_write = 0;
        wb_write_reg = 0;
        wb_write_data = 0;
        instruction = 0;
        #10;
        rst = 0;
        $display("Time: %0t | Reset Released", $time);

        @(posedge clk);
        wb_reg_write = 1;
        wb_write_reg = 6'd1;     // x1
        wb_write_data = 32'd100;
        $display("Time: %0t | Writing 100 to x1", $time);

        @(posedge clk);
        wb_write_reg = 6'd2;     // x2
        wb_write_data = 32'd200;
        $display("Time: %0t | Writing 200 to x2", $time);

        // Disable Write-Back for testing read
        wb_reg_write = 0;

        // Assembly: ADD x3, x1, x2 (x3 = x1 + x2)        
        @(negedge clk); 
        instruction = 32'h000C0424; 
        
        #2;
        $display("--- Testing ADD x3, x1, x2 ---");
        $display("Instruction: %h", instruction);
        $display("Opcode: %b (Expected 0100)", instruction[3:0]);
        $display("RS Read Data: %d (Expected 100)", read_data1);
        $display("RT Read Data: %d (Expected 200)", read_data2);
        $display("Control: RegWrite=%b (Exp 1), ALUSrc=%b (Exp 0), ALUOp=%b (Exp 000)", reg_write, alu_src, alu_op);

        // Assembly: LD x4, x1, -5 (x4 = Mem[x1 - 5])
        
        @(posedge clk); 
        instruction = 32'hFF90400E;

        #2;
        $display("--- Testing LD x4, x1, -5 ---");
        $display("Instruction: %h", instruction);
        $display("Immediate: %d (Expected -5)", $signed(imm_out));
        $display("RS Read Data: %d (Expected 100)", read_data1);
        $display("Control: RegWrite=%b (Exp 1), ALUSrc=%b (Exp 1), MemToReg=%b (Exp 1)", reg_write, alu_src, mem_to_reg);

        #20;
        $finish;
    end

endmodule