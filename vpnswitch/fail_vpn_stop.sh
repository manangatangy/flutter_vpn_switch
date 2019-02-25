#!/bin/bash
cat <<EOF
## there's no failure mode here - must check status to be sure ##
==== stopping proxy, vpn, and disabling firewall ===
[ ok ] Stopping Squid HTTP Proxy 3.x: squid3[....]  
[ ok ] Stopping virtual private network daemon: US_California.
Firewall stopped and disabled on system startup

EOF
exit 0
