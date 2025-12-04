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
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(1, 100); // x1 = input base address
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(2, 200); // x2 = output base address
        CPU_UUT.ID_STAGE.ID_REG_FILE.initialize_register(3, 7);   // x3 = array size

        // Run simulation until dmem[205] is updated (last median value)
        begin : sim_loop
            integer t;
            for (t = 0; t < 5000000; t = t + 1) begin
                @(posedge clk);
                if (CPU_UUT.MEM_STAGE.DATA_MEM.mem[205] != 0) begin
                    disable sim_loop;
                end
            end
            $display("Simulation timed out!");
        end
        
        #200; // Wait for pipeline to finish pending instructions

        $display("\nFINAL DATA ARRAYS:");
        $display("INPUT ARRAY (dmem[100-106]):");
        $display("dmem[100] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[100]);
        $display("dmem[101] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[101]);
        $display("dmem[102] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[102]);
        $display("dmem[103] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[103]);
        $display("dmem[104] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[104]);
        $display("dmem[105] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[105]);
        $display("dmem[106] = %0d", CPU_UUT.MEM_STAGE.DATA_MEM.mem[106]);
        
        $display("\nOUTPUT ARRAY (dmem[200-206]):");
        $display("dmem[200] = %0d (Expected 3)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[200]);
        $display("dmem[201] = %0d (Expected 3)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[201]);
        $display("dmem[202] = %0d (Expected 5)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[202]);
        $display("dmem[203] = %0d (Expected 5)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[203]);
        $display("dmem[204] = %0d (Expected 7)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[204]);
        $display("dmem[205] = %0d (Expected 8)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[205]);
        $display("dmem[206] = %0d (Expected 8)", CPU_UUT.MEM_STAGE.DATA_MEM.mem[206]);

        if (CPU_UUT.MEM_STAGE.DATA_MEM.mem[200] == 3 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[201] == 3 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[202] == 5 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[203] == 5 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[204] == 7 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[205] == 8 &&
            CPU_UUT.MEM_STAGE.DATA_MEM.mem[206] == 8) begin
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

