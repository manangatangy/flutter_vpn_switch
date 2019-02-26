The vpnswitch subproject consists of;
- standalone executable (source: vpnswitcher.go), which
  - listens on port 8080
  - executes various *.sh bash scripts that drive the ovpn client
- the golang binary can be built on the target rpi
- it takes optional args
  - vpnswitcher -pass (to run the test scripts that return ok)
  - vpnswitcher -fail (to run the test scripts that return fail)
  - with no args, the vpnswitcher runs the actual ovpn client
- to build this exe, you should do
  - cd $GOPATH/src
  - ln -s ...flutter_vpn_switch/vpnswitch vpnswitch
  - go build