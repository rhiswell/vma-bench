
ulimit -l unlimited

LIBVMA="libvma.so"
NETPERF="netperf -t TCP_STREAM -f g -H 192.168.10.141 -T 2 -l 10 --"
PERF="/usr/lib/linux-tools/4.4.0-140-generic/perf record -F 99 -e cycles --call-graph dwarf --"

tsks=()
tsks[${#tsks[@]}]="netperf_tcpstrm_64B"
tsks[${#tsks[@]}]="netperf_tcpstrm_4KB"
tsks[${#tsks[@]}]="netperf_tcpstrm_1MB"

declare -A msg_size
msg_size+=( ["netperf_tcpstrm_64B"]="$((2**6))" )
msg_size+=( ["netperf_tcpstrm_4KB"]="$((2**12))" )
msg_size+=( ["netperf_tcpstrm_1MB"]="$((2**20))" )

for tsk in ${tsks[@]}; do
    echo -e "\n\$LD_PRELOAD=$LIBVMA $PERF $NETPERF -m ${msg_size[$tsk]}\n"
    LD_PRELOAD=$LIBVMA $PERF $NETPERF -m ${msg_size[$tsk]}
    ./gen_fg.sh $tsk
done

