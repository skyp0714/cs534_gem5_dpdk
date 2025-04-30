#!/bin/bash

# Created by: SrikarVanavasam
# Date: 2025-04-15 04:56:34

# Set up logging
LOG_FILE="benchmark_runs_$(date +%Y%m%d_%H%M%S).log"
RESULTS_DIR="benchmark_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

echo "Starting benchmark runs at $(date)" | tee -a "$LOG_FILE"
echo "Results will be saved in $RESULTS_DIR" | tee -a "$LOG_FILE"

# Benchmark scripts
BENCHMARKS=(
    "automotive_basicmath.sh"
    "automotive_bitcount.sh"
    "automotive_qsort.sh"
    "automotive_susan.sh"
    "consumer_jpeg.sh"
    "consumer_lame.sh"
    "consumer_mad.sh"
    "consumer_typeset.sh"
    "network_dijkstra.sh"
    "network_patricia.sh"
    "office_ghostscript.sh"
    "office_ispell.sh"
    "office_rsynth.sh"
    "office_stringsearch.sh"
    "security_blowfish.sh"
    "security_pgp.sh"
    "security_rijndael.sh"
    "security_sha.sh"
    "stream.sh"
    "telecomm_CRC32.sh"
    "telecomm_FFT.sh"
    "telecomm_adpcm.sh"
    "telecomm_gsm.sh"
)

# Replacement policies
POLICIES=(
    "LFURP"
    "RRIPRP"
    "RandomRP"
    "LRURP"
    "SecondChanceRP"
)

TOTAL_RUNS=${#BENCHMARKS[@]}
CURRENT_RUN=0

# Function to run a single benchmark with a policy
run_benchmark() {
    local benchmark=$1
    local output_file="$RESULTS_DIR/${benchmark%.*}.out"
    
    CURRENT_RUN=$((CURRENT_RUN + 1))
    echo "[$CURRENT_RUN/$TOTAL_RUNS] Running benchmark: $benchmark" | tee -a "$LOG_FILE"
    echo "Started at: $(date)" | tee -a "$LOG_FILE"
    
    # Run the command and capture output
    {
        time ./run-scripts/cs534_main.sh \
            --num-nics 1 \
            --script "$benchmark" \
	    --take-checkpoint &
    } > "$output_file" 2>&1
    
    #--replacement "$policy"
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
for benchmark in "${BENCHMARKS[@]}"; do
    #for policy in "${POLICIES[@]}"; do
        echo "running guest script $benchmark"
        run_benchmark "$benchmark"
    #done
done

echo "All benchmark runs completed at $(date)" | tee -a "$LOG_FILE"
echo "Summary: $CURRENT_RUN/$TOTAL_RUNS runs completed" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "Results directory: $RESULTS_DIR" | tee -a "$LOG_FILE"
