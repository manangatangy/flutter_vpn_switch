#!/bin/bash
echo ==== stopping proxy, vpn, and disabling firewall ===
sudo /etc/init.d/squid3 stop
##sudo service transmission-daemon stop
sudo /etc/init.d/openvpn stop
sudo ufw disable
exit 0
