#! /bin/bash
if ls /etc/openvpn/*.conf > /dev/null ; then
    F="`ls /etc/openvpn/*.conf`"
    basename "$F" .conf
else
    exit 1
fi
