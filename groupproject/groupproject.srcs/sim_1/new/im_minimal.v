`timescale 1ns / 1ps

module im_minimal(
    input wire [31:0] address,     
    output reg [31:0] instruction  
);
    parameter MEM_SIZE = 256;
    reg [31:0] mem [0:MEM_SIZE-1];

    always @(*) begin
        instruction = (address < MEM_SIZE) ? mem[address] : 32'h00000000;
        if (address < 2) begin
            $display("IM_MINIMAL: addr=%d, mem[%d]=%h", address, address, mem[address]);
        end
    end

    initial begin
        integer i;
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000000;  // NOP
        end
        
        // mem[0]: INC x1, x0, 5  (x1 = 0 + 5 = 5)
        //   opcode=0101, rt=0, rs=0, rd=1, imm=5
        //   opcode[3:0] | rt[9:4] | rs[15:10] | rd[21:16] | imm[31:22]
        //   0101 | 000000 | 000000 | 000001 | 0000000101
        //   = 0x50010005
        mem[0] = 32'h50010005;
        
        // mem[1]: INC x2, x0, 3  (x2 = 0 + 3 = 3)
        //   opcode=0101, rt=0, rs=0, rd=2, imm=3
        //   0101 | 000000 | 000000 | 000010 | 0000000011
        //   = 0x50020003
        mem[1] = 32'h50020003;
    end
endmodule
