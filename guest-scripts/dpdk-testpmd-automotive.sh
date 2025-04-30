ip link set dev eth0 down
modprobe uio_pci_generic
dpdk-devbind.py -b uio_pci_generic 00:02.0
echo 2048 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
# { sleep 25; m5 checkpoint; } &
dpdk-testpmd -l 0-1 -n 4 -- --nb-cores=1 --coremask=0x02 --forward-mode=macswap --forward-mode=rxptx --proc_times=10 --txd=1024 --rxd=1024 &

# Allow some time for the DPDK application to initialize
# sleep 30

# Trigger checkpoint if desired
# m5 checkpoint

# Launch your additional application (for instance, basicmath)
cd /bin_package/MiBench_ARM/automotive/basicmath
./runme_small.sh