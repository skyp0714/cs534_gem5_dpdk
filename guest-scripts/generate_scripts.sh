#!/bin/bash

# Base script template using heredoc syntax
cat > template.txt << 'EOT'
echo "Successfully Boot Linux!"
ip link set dev eth0 down
modprobe uio_pci_generic
dpdk-devbind.py -b uio_pci_generic 00:02.0
echo 2048 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo "Starting DPDK application..."
dpdk-testpmd -l 0-1 -n 4 -- --nb-cores=1 --coremask=0x02 --forward-mode=macswap --forward-mode=rxptx --proc_times=10 --txd=1024 --rxd=1024 --stats-period=1 &

# Allow some time for the DPDK application to initialize
sleep 30

echo "Starting benchmark..."

# Run BENCHMARK_NAME benchmark
cd BENCHMARK_PATH
taskset -c 2 ./RUNME_SCRIPT

m5 checkpoint

echo "Test done. Exiting gem5..."
m5 exit

EOT

# Base directory for MiBench
MIBENCH_DIR="/bin_package/MiBench_ARM"

# Categories and their benchmarks
declare -A BENCHMARKS
BENCHMARKS["automotive"]="basicmath bitcount qsort susan"
BENCHMARKS["consumer"]="jpeg lame mad typeset"
BENCHMARKS["network"]="dijkstra patricia"
BENCHMARKS["office"]="ghostscript ispell rsynth stringsearch"
BENCHMARKS["security"]="blowfish pgp rijndael sha"
BENCHMARKS["telecomm"]="CRC32 FFT adpcm gsm"

# Generate scripts for each benchmark
for category in "${!BENCHMARKS[@]}"; do
    for benchmark in ${BENCHMARKS[$category]}; do
        script_name="${category}_${benchmark}.sh"
        benchmark_path="$MIBENCH_DIR/$category/$benchmark"
        
        # Handle special case for pgp which has runme.sh instead of runme_small.sh
        if [ "$benchmark" == "pgp" ]; then
            runme_script="runme.sh"
        else
            runme_script="runme_small.sh"
        fi
        
        # Create script content
        sed "s|BENCHMARK_NAME|$benchmark|g; s|BENCHMARK_PATH|$benchmark_path|g; s|RUNME_SCRIPT|$runme_script|g" template.txt > "$script_name"
        
        # Make executable
        # chmod +x "$script_name"
        echo "Created $script_name"
    done
done

# Generate script for Stream benchmark
cat > stream.sh << 'EOT'
echo "Successfully Boot Linux!"
ip link set dev eth0 down
modprobe uio_pci_generic
dpdk-devbind.py -b uio_pci_generic 00:02.0
echo 2048 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo "Starting DPDK application..."
# { sleep 25; m5 checkpoint; } &
dpdk-testpmd -l 0-1 -n 4 -- --nb-cores=1 --coremask=0x02 --forward-mode=macswap --forward-mode=rxptx --proc_times=10 --txd=1024 --rxd=1024 --stats-period=1 &

# Allow some time for the DPDK application to initialize
sleep 30
echo "Starting benchmark..."

# Run Stream benchmark
cd /bin_package/stream_ARM
taskset -c 2 ./stream
m5 checkpoint
echo "Test done. Exiting gem5..."
m5 exit
EOT

# chmod +x "stream.sh"
echo "Created stream.sh"

# Clean up template
rm template.txt

echo "All benchmark scripts have been generated."
