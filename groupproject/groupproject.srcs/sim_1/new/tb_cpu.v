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

    // Test stimulus
    initial begin
        // Reset
        rst = 1;
        #20;
        rst = 0;

        // Initialize registers for median filter program
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(10, 2);   // x10 = input base address (2)
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(11, 71);  // x11 = output base address (71)
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(12, 7);   // x12 = array size (7)

        // Run simulation until dmem[76] is updated (last median value)
        begin : sim_loop
            integer t;
            for (t = 0; t < 5000000; t = t + 1) begin
                @(posedge clk);
                if (CPU_UUT.MEM_STAGE.DATA_MEM.mem[76] != 0) begin
                    disable sim_loop;
                end
            end
            $display("Simulation timed out!");
        end
        
        #500; // Wait for pipeline to finish pending instructions

        $display("\nFINAL DATA ARRAYS:");
        $display("INPUT ARRAY (dmem[2-8]):");
        $display("dmem[2] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[2]);
        $display("dmem[3] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[3]);
        $display("dmem[4] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[4]);
        $display("dmem[5] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[5]);
        $display("dmem[6] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[6]);
        $display("dmem[7] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[7]);
        $display("dmem[8] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[8]);
        
        $display("\nOUTPUT ARRAY (dmem[71-77]):");
        $display("dmem[71] = %0d (Expected 3)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[71]);
        $display("dmem[72] = %0d (Expected 3)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[72]);
        $display("dmem[73] = %0d (Expected 5)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[73]);
        $display("dmem[74] = %0d (Expected 5)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[74]);
        $display("dmem[75] = %0d (Expected 7)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[75]);
        $display("dmem[76] = %0d (Expected 8)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[76]);
        $display("dmem[77] = %0d (Expected 8)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[77]);

        $display("\nNEGATE TEST:");
        $display("x30 = %0d (Expected -2)", $signed(CPU_UUT.ID_STAGE.ID_REG_FILE.registers[30]));

        if (CPU_UUT.MEM_STAGE.DATA_MEM.mem[71] == 3 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[72] == 3 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[73] == 5 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[74] == 5 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[75] == 7 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[76] == 8 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[77] == 8) begin
            $display("\nMEDIAN FILTER TEST PASSED");
        end else begin
            $display("\nMEDIAN FILTER TEST FAILED");
        end

        $finish;
    end

    


    initial begin
        $dumpfile("tb_cpu.vcd");
        $dumpvars(0, tb_cpu);
    end
endmodule

