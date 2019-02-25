#!/bin/bash
cat << EOF
[ ok ] squid3 is running.
Status: active

To                         Action      From
--                         ------      ----
192.168.0.0/16 on eth0     ALLOW       192.168.0.0/16
10.0.0.0/8 1024:65535/udp  ALLOW       Anywhere
10.0.0.0/8 1024:65535/tcp  ALLOW       Anywhere

192.168.0.0/16             ALLOW OUT   192.168.0.0/16 on eth0
Anywhere                   ALLOW OUT   10.0.0.0/8

[ ok ] VPN '`./pass_vpn_current.sh`' is running.

EOF
sleep 3

