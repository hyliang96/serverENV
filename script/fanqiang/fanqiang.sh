# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

. $here/shadowsocks_client/ss_client_alias.sh || echo "$here/shadowsocks_client/ss_client_alias.sh not found!"
. $here/shadowsocks_host/ss_host_alias.sh || echo "$here/shadowsocks_host/ss_host_alias.sh not found!"

unset -a here
