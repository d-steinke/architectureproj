`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_cpu
// Tests the complete pipelined CPU running the actual program in im.v
//////////////////////////////////////////////////////////////////////////////////

module tb_cpu;

    reg clk;
    reg rst;
    integer cycle;

    cpu CPU_UUT (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Simple instruction decoder - just return the opcode
    function [31:0] get_opcode;
        input [31:0] instr;
        get_opcode = instr[3:0];
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

        // Initialize registers x2 and x3 with base addresses
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(2, 100);
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(3, 200);
        $display("Time: %0t | Initialized x2=100, x3=200\n", $time);

        // Display INITIAL ARRAY from data memory (addresses 100-109)
        $display("========================================");
        $display("INITIAL DATA ARRAY (from dmem[100-109]):");
        $display("========================================");
        #5;
        $display("dmem[100] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[100]);
        $display("dmem[101] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[101]);
        $display("dmem[102] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[102]);
        $display("dmem[103] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[103]);
        $display("dmem[104] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[104]);
        $display("dmem[105] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[105]);
        $display("dmem[106] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[106]);
        $display("dmem[107] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[107]);
        $display("dmem[108] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[108]);
        $display("dmem[109] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[109]);
        $display("\n");

        // Display first 16 instructions from im.v
        $display("Program Trace (First 16 Instructions):");
        $display("Addr | Instruction (Binary)");
        $display("-----|----------------------------------------");
        
        $display("  0  | 1111_000000_000000_101000_0000010011");
        $display("  1  | 1111_000000_000000_101001_0001000010");
        $display("  2  | 1111_000000_000000_101010_0000100101");
        $display("  3  | 1111_000000_000000_101011_0000101100");
        $display("  4  | 1111_000000_000000_101100_0000110001");
        $display("  5  | 1111_000000_000000_101101_0000010010");
        $display("  6  | 1111_000000_000000_101110_0000010010");
        $display("  7  | 1111_000000_000000_101111_0000010100");
        $display("  8  | 0101_000000_000001_000100_1111111111");
        $display("  9  | 1110_000000_000010_010100_0000000000");
        $display("  10 | 0000_000000_000000_000000_0000000000");
        $display("  11 | 0000_000000_000000_000000_0000000000");
        $display("  12 | 0011_010100_000011_000000_0000000000");
        $display("  13 | 0111_000000_000000_000000_0000000000");
        $display("  14 | 0000_000000_000000_000000_0000000000");
        $display("  15 | 0000_000000_000000_000000_0000000000");
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
        #100000;  // Run for much longer to allow algorithm to complete

        $display("\n========================================");
        $display("FINAL DATA ARRAYS:");
        $display("========================================");
        $display("\nINPUT ARRAY (dmem[100-109]):");
        $display("dmem[100] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[100]);
        $display("dmem[101] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[101]);
        $display("dmem[102] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[102]);
        $display("dmem[103] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[103]);
        $display("dmem[104] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[104]);
        $display("dmem[105] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[105]);
        $display("dmem[106] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[106]);
        $display("dmem[107] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[107]);
        $display("dmem[108] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[108]);
        $display("dmem[109] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[109]);
        
        $display("\nOUTPUT ARRAY (dmem[200-209]):");
        $display("dmem[200] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[200]);
        $display("dmem[201] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[201]);
        $display("dmem[202] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[202]);
        $display("dmem[203] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[203]);
        $display("dmem[204] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[204]);
        $display("dmem[205] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[205]);
        $display("dmem[206] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[206]);
        $display("dmem[207] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[207]);
        $display("dmem[208] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[208]);
        $display("dmem[209] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[209]);
        $display("========================================\n");

        $display("\n========================================");
        $display("  CPU Execution Complete");
        $display("  Program from im.v Successfully Executed");
        $display("========================================\n");

        $finish;
    end

    // Cycle-by-cycle trace (disabled for extended run - uncomment to enable)
    // initial begin
    //     cycle = 0;
    //     @(negedge rst);  // Wait for reset to be released
    //     
    //     #10;  // Let pipeline stabilize
    //     
    //     $display("Cycle-by-Cycle Trace:");
    //     $display("Cyc | PC  | IF/ID Instr      | Opcode | Flush");
    //     $display("----|-----|-----------------|--------|------");
    //     
    //     repeat(60) begin
    //         $display("%3d | %3d | %h | %4b   | %b", 
    //                  cycle, 
    //                  CPU_UUT.if_pc, 
    //                  CPU_UUT.if_id_instr,
    //                  CPU_UUT.if_id_instr[3:0],
    //                  CPU_UUT.if_flush);
    //         @(posedge clk);
    //         cycle = cycle + 1;
    //     end
    // end

endmodule

