
ulimit -l unlimited

# Polling mode
NETPERF="netperf -t TCP_RR -H 192.168.10.141 -T 2 -l 30"
VMA_SPEC=latency LD_PRELOAD=libvma.so $NETPERF

# Interrupt mode
#NETPERF="netperf -t TCP_RR -H 192.168.10.141 -T 2 -l 30"
#VMA_SPEC=latency VMA_RX_POLL=0 VMA_SELECT_POLL=0 LD_PRELOAD=libvma.so \
#	$NETPERF
    
