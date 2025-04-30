echo "Successfully Boot Linux!"
ip link set dev eth0 down
modprobe uio_pci_generic
dpdk-devbind.py -b uio_pci_generic 00:02.0
echo 2048 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
echo "Starting DPDK application..."
dpdk-testpmd -l 0-1 -n 4 -- --nb-cores=1 --coremask=0x02 --forward-mode=macswap --forward-mode=rxptx --proc_times=10 --txd=1024 --rxd=1024 --stats-period=1 &

# Allow some time for the DPDK application to initialize
sleep 5
echo "5 sec past"
sleep 5
echo "10 sec past"
sleep 5
echo "15 sec past"
sleep 5
echo "20 sec past"
sleep 5
echo "25 sec past"
sleep 5
echo "30 sec past"

echo "Starting benchmark..."

# Run rijndael benchmark
cd /bin_package/MiBench_ARM/security/rijndael
taskset -c 2 ./runme_small.sh

m5 checkpoint

echo "Test done. Exiting gem5..."
m5 exit

