#!/bin/bash
cat <<EOF
## there's no failure mode here - must check status to be sure ##
=== starting vpn, enabling firewall, and starting proxy
Firewall stopped and disabled on system startup
[ ok ] Stopping virtual private network daemon:.
[ ok ] Starting virtual private network daemon: US_California.
Firewall is active and enabled on system startup
[ ok ] Starting Squid HTTP Proxy 3.x: squid3.

EOF
exit 0
