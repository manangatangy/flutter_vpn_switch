#!/bin/bash
# This script starts the vpn (this can't be done unless the firewall is off)
# The firewall rules that were previously set are listed in ./ufw-rules.txt
# and at https://sites.google.com/site/davidxweiss/raspberry-pi/firewalling
echo === starting vpn, enabling firewall, and starting proxy
sudo ufw disable
sudo /etc/init.d/openvpn restart
sudo ufw --force enable
##sudo service transmission-daemon start
sudo /etc/init.d/squid3 start
exit 0
