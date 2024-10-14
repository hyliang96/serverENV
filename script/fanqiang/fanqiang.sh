
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
echo fanqiang.sh >&2

fq_tool=clash # clash, v2, ss

here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

tfq_start_() {
    local protocol="$1"
    local fq_port="$2"
    if [ "$(lsof -Pn -i:$fq_port)" != '' ]; then
        # 用polipo代理http(s)到socks5
        export http_proxy="$protocol://127.0.0.1:$fq_port"
        export HTTP_PROXY="${http_proxy}"
        export https_proxy="$protocol://127.0.0.1:$fq_port"
        export HTTPS_PROXY="${https_proxy}"
        export ftp_proxy="$protocol://127.0.0.1:$fq_port"
        export FTP_PROXY="${ftp_proxy}"
        export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com"
        export NO_PROXY="${no_proxy}"
        #no_proxy表示一些不需要代理的网址,比如内网之类的
        echo "终端已启用代理"
    else
        echo "端口$fq_port空置，终端未启用代理"
    fi
}

tfq_stop_() {
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset FTP_PROXY
    unset NO_PROXY
    echo "终端已结束代理"
}

tfq_status_() {
    echo "http_proxy=$http_proxy"
    echo "https_proxy=$https_proxy"
    echo "ftp_proxy=$ftp_proxy"
    echo "no_proxy=$no_proxy"
}

echo a >&2
. $here/clash_client/clash_client.sh  >&2
echo a0 >&2
. $here/shadowsocks_client/ss_client_alias.sh  >&2
echo a1 >&2
. $here/shadowsocks_host/ss_host_alias.sh  >&2
echo a2 >&2
. $here/v2ray_client/v2ray_client_alias.sh  >&2
echo a3 >&2
. $here/v2ray_host/v2ray_host_alias.sh  >&2
echo a+ >&2

# fq : 设置终端翻墙, 并开翻墙内核
# tfq: 仅设置终端翻墙

if [ "$fq_tool" = clash ]; then
    alias fq='clash'   # 用clash翻墙
    alias tfq_start="tfq_start_ http $clash_http_port"
elif [ "$fq_tool" = ss ]; then
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
    elif [ "$1" = status ]; then
        tfq_status_
    else
        echo 'tfq [start]: start 翻墙 in terminal.'
        echo 'tfq stop:    stop 翻墙 in terminal.'
    fi
}

echo b >&2
# 若当前有翻墙检测, 则开机登录时开启终端翻墙
if [ "$(v2 jch 2>/dev/null)" != '' ]; then
    echo b1 >&2
    tfq_start_ http $v2_http_port > /dev/null
elif [ "$(ss jch 2>/dev/null)" != '' ]; then
    echo b2 >&2
    tfq_start_ http $ss_http_port > /dev/null
fi
echo c >&2
unset -v here
