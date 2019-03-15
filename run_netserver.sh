
ulimit -l unlimited
# -f    Do not spawn chilren for each test, run serially.
# -D    Do not daemonize.
# -L name,family Use name to pick listen addr and family for family.
# -4    Do IPv4.
NETSERVER="netserver -D -f -L 192.168.10.141 -4"
LD_PRELOAD=libvma.so $NETSERVER
