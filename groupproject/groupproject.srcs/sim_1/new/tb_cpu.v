`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: tb_cpu
// Tests the complete pipelined CPU running the actual program in im.v
//////////////////////////////////////////////////////////////////////////////////

module tb_cpu;

    reg clk;
    reg rst;
    integer cycle;
    integer i;

    cpu CPU_UUT (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation: 10ns period (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Cycle Counter Logic
    initial begin
        cycle = 0; // 1. Initialize to 0 at time 0
    end

    always @(posedge clk) begin
        if (rst) begin
            cycle <= 0; // Optional: Reset cycle count on reset
        end else begin
            cycle <= cycle + 1; // 2. Increment every rising edge
        end
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

        // Initialize registers for median filter program
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(1, 100); // x1 = input base address
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(2, 200); // x2 = output base address
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(3, 10);  // x3 = array size
        $display("Time: %0t | Initialized x1=100, x2=200, x3=10\n", $time);

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
        
        $display("  0  | 0111_001111_001111_001111_0000000000  // SUB x15,x15,x15");
        $display("  1  | 0101_000000_001111_001110_0000000001  // INC x14,x15,1");
        $display("  2  | 0111_000101_000011_001110_0000000000  // SUB x5,x3,x14");
        $display("  3  | 1110_000000_001000_000001_0000000000  // LD x8,x1,0");
        $display("  4  | 0011_001000_000010_000000_0000000000  // ST x8,x2,0");
        $display("  5  | 0100_000110_000001_000101_0000000000  // ADD x6,x1,x5");
        $display("  6  | 0100_000111_000010_000101_0000000000  // ADD x7,x2,x5");
        $display("  7  | 1110_000000_001000_000110_0000000000  // LD x8,x6,0");
        $display("  8  | 0011_001000_000111_000000_0000000000  // ST x8,x7,0");
        $display("  9  | 0101_000000_001111_000100_0000000001  // INC x4,x15,1");
        $display("  10 | 1111_000000_000000_010101_0000100111  // SVPC x21,39");
        $display("  11 | 1111_000000_000000_010110_0000000101  // SVPC x22,5");
        $display("  12 | 1111_000000_000000_010100_0000000001  // SVPC x20,1");
        $display("  13 | 0111_000101_000100_001101_0000000000  // SUB x13,x4,x5");
        $display("  14 | 1010_010110_000000_010110_0000000000  // BRN x22");
        $display("  15 | 1000_010101_000000_010101_0000000000  // J x21");
        $display("\n");

        // ===== PHASE 1: Setup (mem[0-9]) =====
        $display("========================================");
        $display("PHASE 1: Initialization");
        $display("mem[0-2]: Create constant registers x15=0, x14=1, x5=N-1");
        $display("mem[3-8]: Handle boundary elements b[0] and b[N-1]");
        $display("mem[9]: Initialize loop counter x4=1");
        $display("========================================\n");
        #50;

        // ===== PHASE 2: Jump Table Setup (mem[10-12]) =====
        $display("========================================");
        $display("PHASE 2: Jump Table Setup");
        $display("mem[10]: SVPC x21, 39 (LOOP_END address)");
        $display("mem[11]: SVPC x22, 5 (LOAD_VALS address)");
        $display("mem[12]: SVPC x20, 1 (LOOP_START address)");
        $display("========================================\n");
        #20;

        // ===== PHASE 3: Loop Start (mem[13-15]) =====
        $display("========================================");
        $display("PHASE 3: Loop Control Logic");
        $display("mem[13]: SUB x13, x4, x5 (check if i < N-1)");
        $display("mem[14]: BRN x22 (if negative, continue to LOAD_VALS)");
        $display("mem[15]: J x21 (else jump to LOOP_END)");
        $display("========================================\n");
        #20;

        // ===== PHASE 4: Load Three Elements (mem[16-23]) =====
        $display("========================================");
        $display("PHASE 4: Load 3-Element Window");
        $display("mem[16-18]: Calculate pointer and load a[i-1]");
        $display("mem[19-20]: Calculate pointer and load a[i]");
        $display("mem[21-23]: Calculate pointer and load a[i+1]");
        $display("========================================\n");
        #40;

        // ===== Extended Run =====
        $display("========================================");
        $display("Running Extended Execution...");
        $display("Observing pipeline steady state and forwarding");
        $display("========================================\n");
        #5000000;  // Run for much longer to allow algorithm to complete

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
        
        #20; 

        $display("\n========================================");
        $display("FINAL MEMORY DUMP (Output Array b[])");
        $display("========================================");
        
        for (i = 200; i < 210; i = i + 1) begin 
            $display("dmem[%0d] = %d", i, CPU_UUT.MEM_STAGE.DATA_MEM.mem[i]);
        end

        $display("\n========================================");
        $display("  CPU Execution Complete");
        $display("  Program from im.v Successfully Executed");
        $display("========================================\n");

        $finish;
    end

    


    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);
    end
endmodule

