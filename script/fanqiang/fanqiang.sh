# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

. $here/shadowsocks_client/ss_client_alias.sh  >&2
. $here/shadowsocks_host/ss_host_alias.sh  >&2
. $here/v2ray_client/v2ray_client_alias.sh  >&2
. $here/v2ray_host/v2ray_host_alias.sh  >&2


# alias fq='ss'   # 用shadowsock翻墙
alias fq='v2'     # 用v2ray翻墙

unset -v here
