#! /bin/sh
for F in /etc/openvpn/archive/*.conf ; do basename $F .conf ; done
