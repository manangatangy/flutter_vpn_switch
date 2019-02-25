The vpntest subproject consists of;
- standalone executable (source: vpnswitcher.go) command line app
- first parameter is the server's ip address
- second parameters to specify the command:
  - stop
  - start
  - status
  - current
  - list
  - ping ping-target-ip
  - switch new-location
- to build this exe, you should do
  - cd $GOPATH/src
  - ln -s ...flutter_vpn_switch/vpntest vpntest
  - go build

