#!/bin/bash

# Script to run all testbenches and generate a summary.

# Create a directory for simulation runs if it doesn't exist
mkdir -p sim_runs

# Find all source files
SOURCES=$(find groupproject/groupproject.srcs/sources_1/new -name "*.v")
SIM_SOURCES=$(find groupproject/groupproject.srcs/sim_1/new -name "*.v" ! -name "tb_*.v")

# Find all testbenches
TESTBENCHES=$(find groupproject/groupproject.srcs/sim_1/new -name "tb_*.v")

# Log file for the summary
SUMMARY_LOG="sim_runs/full_test_summary.log"
echo "Test Summary" > $SUMMARY_LOG
echo "============" >> $SUMMARY_LOG
echo "" >> $SUMMARY_LOG

# Loop through each testbench
for tb in $TESTBENCHES; do
    # Get the testbench name without the extension
    tb_name=$(basename $tb .v)
    echo "Running testbench: $tb_name"

    # Compile the testbench with all source files
    iverilog -o sim_runs/$tb_name.vvp $tb $SOURCES $SIM_SOURCES -g2012 2> sim_runs/$tb_name.compile.err
    if [ $? -ne 0 ]; then
        echo "  [FAIL] Compilation failed. See sim_runs/$tb_name.compile.err"
        echo "$tb_name: COMPILE FAIL" >> $SUMMARY_LOG
        continue
    fi

    # Run the simulation
    vvp sim_runs/$tb_name.vvp > sim_runs/$tb_name.log
    if [ $? -ne 0 ]; then
        echo "  [FAIL] Simulation failed. See sim_runs/$tb_name.log"
        echo "$tb_name: SIMULATION FAIL" >> $SUMMARY_LOG
        continue
    fi

    # Check for errors in the log file
    if grep -q -i "fail" sim_runs/$tb_name.log; then
        echo "  [FAIL] Simulation completed with failures. See sim_runs/$tb_name.log"
        echo "$tb_name: SIMULATION FAIL" >> $SUMMARY_LOG
    elif grep -q -i "error" sim_runs/$tb_name.log; then
        echo "  [FAIL] Simulation completed with errors. See sim_runs/$tb_name.log"
        echo "$tb_name: SIMULATION ERROR" >> $SUMMARY_LOG
    else
        echo "  [PASS] Simulation successful."
        echo "$tb_name: PASS" >> $SUMMARY_LOG
    fi
done

echo ""
echo "All testbenches have been run. See the summary in $SUMMARY_LOG"