#! /bin/sh
sudo /etc/init.d/squid3 status
sudo ufw status
sudo /etc/init.d/openvpn status
##sudo service transmission-daemon status
exit 0

