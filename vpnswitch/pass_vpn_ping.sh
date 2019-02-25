#!/bin/bash
cat <<EOF
PING $1 (216.58.203.100): 56 data bytes
64 bytes from 216.58.203.100: icmp_seq=0 ttl=54 time=14.315 ms
64 bytes from 216.58.203.100: icmp_seq=1 ttl=54 time=17.819 ms
64 bytes from 216.58.203.100: icmp_seq=2 ttl=54 time=17.013 ms
64 bytes from 216.58.203.100: icmp_seq=3 ttl=54 time=15.160 ms
64 bytes from 216.58.203.100: icmp_seq=4 ttl=54 time=15.225 ms

--- www.google.com ping statistics ---
5 packets transmitted, 5 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 14.315/15.906/17.819/1.299 ms
EOF
sleep 3
exit 0
