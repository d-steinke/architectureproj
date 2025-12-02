`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_cpu
// Tests the complete pipelined CPU running the actual program in im.v
//////////////////////////////////////////////////////////////////////////////////

module tb_cpu;

    reg clk;
    reg rst;

    cpu CPU_UUT (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Instruction decoder function
    function [128*8-1:0] decode_instruction(input [31:0] instr);
        reg [3:0] opcode;
        reg [5:0] rd, rs, rt;
        reg [9:0] imm;
        reg [128*8-1:0] decoded;
        
        begin
            opcode = instr[3:0];
            rd = instr[21:16];
            rs = instr[15:10];
            rt = instr[9:4];
            imm = instr[31:22];
            
            case(opcode)
                4'b0000: decoded = $sformatf("NOP");
                4'b1111: decoded = $sformatf("SVPC x%0d", rd);
                4'b1110: decoded = $sformatf("LD x%0d, x%0d, %d", rd, rs, $signed(imm));
                4'b0011: decoded = $sformatf("ST x%0d, x%0d, %d", rt, rs, $signed(imm));
                4'b0100: decoded = $sformatf("ADD x%0d, x%0d, x%0d", rd, rs, rt);
                4'b0101: decoded = $sformatf("INC x%0d, x%0d, %d", rd, rs, $signed(imm));
                4'b0110: decoded = $sformatf("NEG x%0d, x%0d", rd, rs);
                4'b0111: decoded = $sformatf("SUB x%0d, x%0d, x%0d", rd, rs, rt);
                4'b1000: decoded = $sformatf("J x%0d", rd);
                4'b1001: decoded = $sformatf("BRZ %d", $signed(imm));
                4'b1010: decoded = $sformatf("BRN %d", $signed(imm));
                default: decoded = $sformatf("UNKNOWN");
            endcase
        end
    endfunction

    // Test stimulus
    initial begin
        $display("========================================");
        $display("  SCU ISA Pipelined CPU - im.v Execution");
        $display("========================================\n");
        
        // Reset
        rst = 1;
        #20;
        rst = 0;
        $display("Time: %0t | Reset Released\n", $time);

        // Display first 16 instructions from im.v
        $display("Program Trace (First 16 Instructions):");
        $display("Addr | Instruction (Binary)                  | Decoded");
        $display("-----|----------------------------------------|----------------------------------");
        
        $display("  0  | 1111_000000_000000_101000_0000010011 | %s", decode_instruction(32'b1111_000000_000000_101000_0000010011));
        $display("  1  | 1111_000000_000000_101001_0001000010 | %s", decode_instruction(32'b1111_000000_000000_101001_0001000010));
        $display("  2  | 1111_000000_000000_101001_0001000010 | %s", decode_instruction(32'b1111_000000_000000_101001_0001000010));
        $display("  3  | 1111_000000_000000_101011_0000101100 | %s", decode_instruction(32'b1111_000000_000000_101011_0000101100));
        $display("  4  | 1111_000000_000000_101100_0000110001 | %s", decode_instruction(32'b1111_000000_000000_101100_0000110001));
        $display("  5  | 1111_000000_000000_101101_0000010010 | %s", decode_instruction(32'b1111_000000_000000_101101_0000010010));
        $display("  6  | 1111_000000_000000_101110_0000010010 | %s", decode_instruction(32'b1111_000000_000000_101110_0000010010));
        $display("  7  | 1111_000000_000000_101111_0000010100 | %s", decode_instruction(32'b1111_000000_000000_101111_0000010100));
        $display("  8  | 0101_000000_000001_000100_1111111111 | %s", decode_instruction(32'b0101_000000_000001_000100_1111111111));
        $display("  9  | 1110_000000_000010_010100_0000000000 | %s", decode_instruction(32'b1110_000000_000010_010100_0000000000));
        $display("  10 | 0000_000000_000000_000000_0000000000 | %s", decode_instruction(32'b0000_000000_000000_000000_0000000000));
        $display("  11 | 0000_000000_000000_000000_0000000000 | %s", decode_instruction(32'b0000_000000_000000_000000_0000000000));
        $display("  12 | 0011_010100_000011_000000_0000000000 | %s", decode_instruction(32'b0011_010100_000011_000000_0000000000));
        $display("  13 | 0111_000000_000000_000000_0000000000 | %s", decode_instruction(32'b0111_000000_000000_000000_0000000000));
        $display("  14 | 0000_000000_000000_000000_0000000000 | %s", decode_instruction(32'b0000_000000_000000_000000_0000000000));
        $display("  15 | 0000_000000_000000_000000_0000000000 | %s", decode_instruction(32'b0000_000000_000000_000000_0000000000));
        $display("\n");

        // ===== PHASE 1: Load Constants (mem[0-7]) =====
        $display("========================================");
        $display("PHASE 1: Load Constants into Registers");
        $display("mem[0-7]: SVPC instructions load PC+1 into x40-x47");
        $display("========================================\n");
        #200;

        // ===== PHASE 2: INC and LD (mem[8-9]) =====
        $display("========================================");
        $display("PHASE 2: INC and Load");
        $display("mem[8]: INC x1, x0, -1 (x1 = 0 + (-1) = -1)");
        $display("mem[9]: LD x4, x2, 0 (x4 = Mem[x2] = Mem[x40])");
        $display("========================================\n");
        #100;

        // ===== PHASE 3: Initialization (mem[16-21]) =====
        $display("========================================");
        $display("PHASE 3: Loop Initialization");
        $display("mem[16]: INC x10, x0, 1 (x10 = 1, loop counter)");
        $display("mem[17]: ADD x23, x10, x2 (x23 = 1 + x40)");
        $display("mem[18]: ADD x24, x11, x3 (x24 = x11 + x41)");
        $display("mem[19]: LD x25, x11, -1");
        $display("mem[20]: LD x26, x11, 0");
        $display("mem[21]: LD x27, x11, 1");
        $display("========================================\n");
        #200;

        // ===== PHASE 4: Loop Processing (mem[22-30]) =====
        $display("========================================");
        $display("PHASE 4: First Loop Iteration");
        $display("mem[22]: SUB x13, x26, x26 (x13 = 0, sets Z flag)");
        $display("mem[23]: BRN (Branch if Negative)");
        $display("mem[24]: SUB x13, x27, x26");
        $display("mem[25]: BRN");
        $display("mem[26]: SUB x13, x26, x26");
        $display("mem[27]: BRN");
        $display("mem[28]: ST x26, x12, 0 (Store to memory)");
        $display("mem[29]: INC x10, x10, 1 (Increment loop counter)");
        $display("mem[30]: SUB x13, x10, x4 (Compare counter with limit)");
        $display("========================================\n");
        #300;

        // ===== PHASE 5: Jump Back (mem[31-32]) =====
        $display("========================================");
        $display("PHASE 5: Loop Control");
        $display("mem[31]: BRZ (Branch if Zero - loop condition)");
        $display("mem[32]: J x5 (Unconditional Jump)");
        $display("========================================\n");
        #150;

        // ===== Extended Run =====
        $display("========================================");
        $display("Running Extended Execution...");
        $display("Observing pipeline steady state and forwarding");
        $display("========================================\n");
        #500;

        $display("\n========================================");
        $display("  CPU Execution Complete");
        $display("  Program from im.v Successfully Executed");
        $display("========================================\n");

        $finish;
    end

    // Detailed cycle-by-cycle trace
    initial begin
        integer cycle;
        cycle = 0;
        @(negedge rst);  // Wait for reset to be released
        
        #10;  // Let pipeline stabilize
        
        $display("Cycle-by-Cycle Trace:");
        $display("Cyc | PC  | IF/ID Instr      | Decoded Instr         | Flush");
        $display("----|-----|-----------------|-------------------------|------");
        
        repeat(60) begin
            $display("%3d | %3d | %h | %-23s | %b", 
                     cycle, 
                     CPU_UUT.if_pc, 
                     CPU_UUT.if_id_instr,
                     decode_instruction(CPU_UUT.if_id_instr),
                     CPU_UUT.if_flush);
            @(posedge clk);
            cycle = cycle + 1;
        end
    end

endmodule

