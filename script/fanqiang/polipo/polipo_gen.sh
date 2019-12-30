#!/bin/bash

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

ss_port="$1"
polipo_port="$2"

mkdir -p ${localENV}/log/polipo

cat >  ${here}/.polipo << EOF
proxyAddress = "127.0.0.1"
proxyPort = $polipo_port

allowedClients = 127.0.0.1
allowedPorts = 1-65535

socksParentProxy = "127.0.0.1:$ss_port"
socksProxyType = socks5

daemonise = true
logSyslog = true

logFile = $localENV/log/polipo/log
pidFile = $localENV/log/polipo/pid
EOF

# release this variable in the end of file
# unset -v ss_port
# unset -v polipo_port
unset -v here

