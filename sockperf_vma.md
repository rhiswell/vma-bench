## VMA benchmarks

### Setup

- Hosts: 192.168.1.140-141
- IB driver: 

```bash
$ ofed_info -s
MLNX_OFED_LINUX-4.4-2.0.7.0:
```

- Use IB mode

```bash
$ lspci | grep Mellanox
01:00.0 Network controller: Mellanox Technologies MT27500 Family [ConnectX-3]
$ connectx_port_config -d 01:00.0 -c ib,ib

ConnectX PCI devices :
|----------------------------|
| 1             0000:01:00.0 |
|----------------------------|

Before port change:
ib
eth


After port change:
ib
ib
```

- Assign IP to ib0: 192.168.10.140-141

```bash
$ ip addr add 192.168.10.141/24 dev ib0
$ ip link set ib0 up
$ ip addr show ib0
42: ib0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2044 qdisc mq state UP group default qlen 256
    link/infiniband a0:08:02:08:fe:80:00:00:00:00:00:00:7c:fe:90:03:00:16:4d:01 brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
    inet 192.168.10.141/24 scope global ib0
       valid_lft forever preferred_lft forever
    inet6 fe80::7efe:9003:16:4d01/64 scope link 
       valid_lft forever preferred_lft forever
```

### Latency := RTT/2

| VMA over IB (polling) | VMA over IB (interrupt) | No VMA (IPoIB?) |
| --------------------- | ----------------------- | --------------- |
| 1.354 us              | 12.907 us               | 22.448          |

- VMA over IB in polling mode

```bash
$ VMA_SPEC=latency LD_PRELOAD=libvma.so numactl --cpunodebind=0 taskset -c 1,2 \
$ 	sockperf sr -i 192.168.10.140 --tcp	# server
$ VMA_SPEC=latency LD_PRELOAD=libvma.so numactl --cpunodebind=0 taskset -c 1,2 \
$	sockperf pp --time 4 -m 14 -i 192.168.10.140 --tcp	# client
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=3.550 sec; SentMessages=1295155; ReceivedMessages=1295155
sockperf: ====> avg-latency=1.354 (std-dev=0.238)
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 1.354 usec
sockperf: Total 1295155 observations; each percentile contains 12951.55 observations
sockperf: ---> <MAX> observation =   90.530
sockperf: ---> percentile 99.999 =    8.998
sockperf: ---> percentile 99.990 =    7.469
sockperf: ---> percentile 99.900 =    6.328
sockperf: ---> percentile 99.000 =    1.690
sockperf: ---> percentile 90.000 =    1.429
sockperf: ---> percentile 75.000 =    1.350
sockperf: ---> percentile 50.000 =    1.327
sockperf: ---> percentile 25.000 =    1.309
sockperf: ---> <MIN> observation =    1.252
```

- VMA over IB in interrupt mode

```bash
$ VMA_RX_POLL=0 VMA_SELECT_POLL=0 VMA_SPEC=latency LD_PRELOAD=libvma.so \
$	numactl --cpunodebind=0 taskset -c 1,2 \
$	sockperf sr -i 192.168.10.140 --tcp	# server
$ VMA_RX_POLL=0 VMA_SELECT_POLL=0 VMA_SPEC=latency LD_PRELOAD=libvma.so \
$	numactl --cpunodebind=0 taskset -c 1,2 \
$	sockperf pp --time 4 -m 14 -i 192.168.10.140 --tcp	# client
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=3.550 sec; SentMessages=137196; ReceivedMessages=137196
sockperf: ====> avg-latency=12.907 (std-dev=1.372)
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 12.907 usec
sockperf: Total 137196 observations; each percentile contains 1371.96 observations
sockperf: ---> <MAX> observation =  107.357
sockperf: ---> percentile 99.999 =   89.237
sockperf: ---> percentile 99.990 =   81.805
sockperf: ---> percentile 99.900 =   18.884
sockperf: ---> percentile 99.000 =   14.902
sockperf: ---> percentile 90.000 =   14.112
sockperf: ---> percentile 75.000 =   13.554
sockperf: ---> percentile 50.000 =   12.883
sockperf: ---> percentile 25.000 =   12.288
sockperf: ---> <MIN> observation =    7.617
```

- Without VMA (IBoIP?)

```bash
$ numactl --cpunodebind=0 taskset -c 1,2 \
$	sockperf sr -i 192.168.10.140 --tcp	# server
$ numactl --cpunodebind=0 taskset -c 1,2 \
$	sockperf pp --time 4 -m 14 -i 192.168.10.140 --tcp	# client
sockperf: ========= Printing statistics for Server No: 0
sockperf: [Valid Duration] RunTime=3.550 sec; SentMessages=78928; ReceivedMessages=78928
sockperf: ====> avg-latency=22.448 (std-dev=2.804)
sockperf: # dropped messages = 0; # duplicated messages = 0; # out-of-order messages = 0
sockperf: Summary: Latency is 22.448 usec
sockperf: Total 78928 observations; each percentile contains 789.28 observations
sockperf: ---> <MAX> observation =   47.236
sockperf: ---> percentile 99.999 =   47.063
sockperf: ---> percentile 99.990 =   44.206
sockperf: ---> percentile 99.900 =   39.115
sockperf: ---> percentile 99.000 =   35.944
sockperf: ---> percentile 90.000 =   24.229
sockperf: ---> percentile 75.000 =   23.152
sockperf: ---> percentile 50.000 =   22.041
sockperf: ---> percentile 25.000 =   20.931
sockperf: ---> <MIN> observation =   18.235
```

## Refs

- https://github.com/Mellanox/libvma/blob/master/README.txt
- http://www.mellanox.com/page/software_vma?mtag=vma
- [Mellanox Messaging Accelerator (VMA), Installation Guide.](http://www.mellanox.com/related-docs/prod_acceleration_software/VMA_8_6_10_Installation_Guide.pdf)
- [Mellanox Messaging Accelerator (VMA) Library for Linux, User Manual.](http://www.mellanox.com/related-docs/prod_acceleration_software/VMA_8_6_10_User_Manual.pdf)



