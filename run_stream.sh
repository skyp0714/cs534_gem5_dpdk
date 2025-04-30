#!/bin/bash

# Created by: SrikarVanavasam
# Date: 2025-04-16 21:19:34

# CONFIGURABLE PARAMETERS
# -------------------------
# Benchmark to run
BENCHMARK="stream.sh"

# Replacement policies to test
POLICIES=(
    "LFURP"
    "RRIPRP" 
    "RandomRP"
    "LRURP"
    "SecondChanceRP"
)

# Configuration scripts
CONFIGS=(
    # Script name                  # Description for logging
    "l2fwd-ckp.sh                 DDIO-Enabled_Inclusive"
    "l2fwd-ckp-disabled.sh        DDIO-Disabled_NonInclusive"
)

# Test parameters
PACKET_RATE=107538400
PACKET_SIZE=512
FREQUENCY="3GHz"
NUM_NICS=1

# Script paths
RUN_SCRIPT_DIR="./run-scripts"
BENCHMARK_DIR="./guest-scripts"

# -------------------------

# Set up logging
LOG_FILE="stream_benchmark_runs_$(date +%Y%m%d_%H%M%S).log"
RESULTS_DIR="stream_benchmark_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

echo "Starting stream benchmark runs at $(date)" | tee -a "$LOG_FILE"
echo "Results will be saved in $RESULTS_DIR" | tee -a "$LOG_FILE"

# Calculate total number of runs
TOTAL_RUNS=$((${#POLICIES[@]} * ${#CONFIGS[@]}))
CURRENT_RUN=0

# Function to run a single benchmark with given parameters
run_benchmark() {
    local policy=$1
    local config_line=$2
    
    # Parse config line
    local config_script=$(echo "$config_line" | awk '{print $1}')
    local config_desc=$(echo "$config_line" | awk '{print $2}')
    
    # Create descriptive filename based on parameters
    local output_file="$RESULTS_DIR/stream_${policy}_${config_desc}.out"
    
    CURRENT_RUN=$((CURRENT_RUN + 1))
    echo "[$CURRENT_RUN/$TOTAL_RUNS] Running stream benchmark with:" | tee -a "$LOG_FILE"
    echo "  - Policy: $policy" | tee -a "$LOG_FILE"
    echo "  - Config: $config_desc" | tee -a "$LOG_FILE"
    echo "  - Script: $config_script" | tee -a "$LOG_FILE"
    echo "Started at: $(date)" | tee -a "$LOG_FILE"
    
    # Run the command and capture output
    {
        time $RUN_SCRIPT_DIR/$config_script \
            --num-nics $NUM_NICS \
            --script "$BENCHMARK" \
            --packet-rate $PACKET_RATE \
            --packet-size $PACKET_SIZE \
            --replacement "$policy" &
    } > "$output_file" 2>&1
    
    local exit_code=$?
    
    echo "Finished at: $(date)" | tee -a "$LOG_FILE"
    if [ $exit_code -eq 0 ]; then
        echo "✓ Success" | tee -a "$LOG_FILE"
    else
        echo "✗ Failed with exit code: $exit_code" | tee -a "$LOG_FILE"
    fi
    echo "Output saved to: $output_file" | tee -a "$LOG_FILE"
    echo "-----------------------------------------" | tee -a "$LOG_FILE"
}

# Main execution loop
for policy in "${POLICIES[@]}"; do
    for config in "${CONFIGS[@]}"; do
        run_benchmark "$policy" "$config" 
    done
done

echo "All stream benchmark runs completed at $(date)" | tee -a "$LOG_FILE"
echo "Summary: $CURRENT_RUN/$TOTAL_RUNS runs completed" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Results directory: $RESULTS_DIR" | tee -a "$LOG_FILE"
