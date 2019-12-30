# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`

fq_tool=v2 # v2, ss

here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

tfq_start_() {
    local protocol="$1"
    local fq_port="$2"
    # 用polipo代理http(s)到socks5
    export http_proxy="$protocol://127.0.0.1:$fq_port"
    export https_proxy="$protocol://127.0.0.1:$fq_port"
    export ftp_proxy="$protocol://127.0.0.1:$fq_port"
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com"
    #no_proxy表示一些不需要代理的网址,比如内网之类的
    echo "终端已翻墙"
}

tfq_stop_() {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
    echo "终端已结束翻墙"
}

. $here/shadowsocks_client/ss_client_alias.sh  >&2
. $here/shadowsocks_host/ss_host_alias.sh  >&2
. $here/v2ray_client/v2ray_client_alias.sh  >&2
. $here/v2ray_host/v2ray_host_alias.sh  >&2


if [ "$fq_tool" = ss ]; then
    alias fq='ss'   # 用shadowsock翻墙
    alias tfq_start="tfq_start_ http $ss_http_port"
elif [ "$fq_tool" = v2 ]; then
    alias fq='v2'     # 用v2ray翻墙
    alias tfq_start="tfq_start_ http $v2_http_port"
else
    echo "$fq_tool can't be recognized" >&2
fi

tfq() {
    if [ "$1" = start ] || [ $# -eq 0 ]; then
        tfq_start
    elif [ "$1" = stop ]; then
        tfq_stop_
    else
        echo 'tfq [start]: start 翻墙 in terminal.'
        echo 'tfq stop:    stop 翻墙 in terminal.'
    fi
}


# 若当前有翻墙检测, 则开机登录时开启终端翻墙
if [ "$(fq jch 2>/dev/null)" != '' ]; then
    tfq start > /dev/null
fi

unset -v here
