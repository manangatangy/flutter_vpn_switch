#! /bin/bash
# If the new conf doesnt exist, leave the current one running.
NEWCONF=$1
if test -f /etc/openvpn/archive/${1}.conf ; then 
	rm /etc/openvpn/*.conf
	cp /etc/openvpn/archive/${1}.conf /etc/openvpn/
	echo "[ ok ] vpn config switched"
else 
	echo "[FAIL] location file $1 doesn't exist"
fi
