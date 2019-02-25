#! /bin/bash

# If the new conf doesnt exist, leave the current one running.
NEWCONF=$1
rm *.conf
touch ${NEWCONF}.conf
echo "[ ok ] vpn config switched"
