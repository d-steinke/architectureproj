`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_controlunit
// Tests all 11 opcodes from SCU ISA and verifies control signals
// Opcodes: NOP(0000), SVPC(1111), LD(1110), ST(0011), ADD(0100), INC(0101),
//          NEG(0110), SUB(0111), J(1000), BRZ(1001), BRN(1010)
//////////////////////////////////////////////////////////////////////////////////

module tb_controlunit;

    reg [3:0] opcode;
    wire reg_write, mem_to_reg, mem_write, alu_src, branch, jump;
    wire [2:0] alu_op;

    controlunit UUT (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .jump(jump)
    );

    initial begin
        $display("===== CONTROL UNIT TESTBENCH =====");
        $display("Checking all 11 opcodes and control signals...\n");
        
        // Test 1: NOP (0000)
        opcode = 4'b0000;
        #5;
        $display("Test 1 - NOP (0000):");
        $display("  reg_write=%b, mem_to_reg=%b, mem_write=%b, alu_src=%b, alu_op=%b, branch=%b, jump=%b",
                 reg_write, mem_to_reg, mem_write, alu_src, alu_op, branch, jump);
        $display("  Expected: reg_write=0, mem_write=0, branch=0, jump=0");
        if (reg_write==0 && mem_write==0 && branch==0 && jump==0) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 2: SVPC (1111)
        opcode = 4'b1111;
        #5;
        $display("Test 2 - SVPC (1111):");
        $display("  reg_write=%b, mem_to_reg=%b, mem_write=%b, alu_src=%b, alu_op=%b",
                 reg_write, mem_to_reg, mem_write, alu_src, alu_op);
        $display("  Expected: reg_write=1, mem_to_reg=0, mem_write=0, alu_src=1 (immediate)");
        if (reg_write==1 && mem_to_reg==0 && mem_write==0 && alu_src==1) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 3: LD (1110)
        opcode = 4'b1110;
        #5;
        $display("Test 3 - LD (1110):");
        $display("  reg_write=%b, mem_to_reg=%b, mem_write=%b, alu_src=%b",
                 reg_write, mem_to_reg, mem_write, alu_src);
        $display("  Expected: reg_write=1, mem_to_reg=1, mem_write=0, alu_src=1 (immediate for address)");
        if (reg_write==1 && mem_to_reg==1 && mem_write==0 && alu_src==1) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 4: ST (0011)
        opcode = 4'b0011;
        #5;
        $display("Test 4 - ST (0011):");
        $display("  reg_write=%b, mem_write=%b, alu_src=%b",
                 reg_write, mem_write, alu_src);
        $display("  Expected: reg_write=0, mem_write=1, alu_src=1 (immediate for address)");
        if (reg_write==0 && mem_write==1 && alu_src==1) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 5: ADD (0100)
        opcode = 4'b0100;
        #5;
        $display("Test 5 - ADD (0100):");
        $display("  reg_write=%b, mem_write=%b, alu_src=%b, alu_op=%b",
                 reg_write, mem_write, alu_src, alu_op);
        $display("  Expected: reg_write=1, mem_write=0, alu_src=0 (register), alu_op=000 (add)");
        if (reg_write==1 && mem_write==0 && alu_src==0 && alu_op==3'b000) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 6: INC (0101)
        opcode = 4'b0101;
        #5;
        $display("Test 6 - INC (0101):");
        $display("  reg_write=%b, mem_write=%b, alu_src=%b, alu_op=%b",
                 reg_write, mem_write, alu_src, alu_op);
        $display("  Expected: reg_write=1, mem_write=0, alu_src=1 (immediate)");
        if (reg_write==1 && mem_write==0 && alu_src==1) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 7: NEG (0110)
        opcode = 4'b0110;
        #5;
        $display("Test 7 - NEG (0110):");
        $display("  reg_write=%b, mem_write=%b, alu_op=%b",
                 reg_write, mem_write, alu_op);
        $display("  Expected: reg_write=1, mem_write=0, alu_op=110 (negate)");
        if (reg_write==1 && mem_write==0 && alu_op==3'b110) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 8: SUB (0111)
        opcode = 4'b0111;
        #5;
        $display("Test 8 - SUB (0111):");
        $display("  reg_write=%b, mem_write=%b, alu_op=%b",
                 reg_write, mem_write, alu_op);
        $display("  Expected: reg_write=1, mem_write=0, alu_op=101 (subtract)");
        if (reg_write==1 && mem_write==0 && alu_op==3'b101) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 9: J (1000) - Jump
        opcode = 4'b1000;
        #5;
        $display("Test 9 - J (1000):");
        $display("  reg_write=%b, mem_write=%b, branch=%b, jump=%b",
                 reg_write, mem_write, branch, jump);
        $display("  Expected: reg_write=0, mem_write=0, jump=1");
        if (reg_write==0 && mem_write==0 && jump==1) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 10: BRZ (1001) - Branch if Zero
        opcode = 4'b1001;
        #5;
        $display("Test 10 - BRZ (1001):");
        $display("  reg_write=%b, mem_write=%b, branch=%b",
                 reg_write, mem_write, branch);
        $display("  Expected: reg_write=0, mem_write=0 (branch signal depends on Z flag in datapath)");
        if (reg_write==0 && mem_write==0) $display("  PASS\n");
        else $display("  FAIL\n");
        
        // Test 11: BRN (1010) - Branch if Negative
        opcode = 4'b1010;
        #5;
        $display("Test 11 - BRN (1010):");
        $display("  reg_write=%b, mem_write=%b, branch=%b",
                 reg_write, mem_write, branch);
        $display("  Expected: reg_write=0, mem_write=0 (branch signal depends on N flag in datapath)");
        if (reg_write==0 && mem_write==0) $display("  PASS\n");
        else $display("  FAIL\n");
        
        $display("===================================");
        $finish;
    end

endmodule
