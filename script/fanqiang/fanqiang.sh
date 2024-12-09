
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`


here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

fq_tool=clash # clash, v2, ss

tfq_start_() {
    local protocol="$1"
    local fq_port="$2"
    if [ "$(lsof -Pn -i:${fq_port})" != '' ]; then
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
        echo "终端系统代理已启用代理"
    else
        echo "端口${fq_port}空置，终端系统代理未启用代理"
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
    echo "终系统代理端已结束代理"
}

tfq_status_() {
    echo "默认代理工具\$fq_tool=${fq_tool}"
    echo
    echo "http_proxy=$http_proxy"
    echo "https_proxy=$https_proxy"
    echo "ftp_proxy=$ftp_proxy"
    echo "no_proxy=$no_proxy"
    echo
    echo "HTTP_PROXY=$HTTP_PROXY"
    echo "HTTPS_PROXY=$HTTPS_PROXY"
    echo "FTP_PROXY=$FTP_PROXY"
    echo "NO_PROXY=$NO_PROXY"
}

. $here/clash_client/clash_client.sh  >&2
. $here/shadowsocks_client/ss_client_alias.sh  >&2
. $here/shadowsocks_host/ss_host_alias.sh  >&2
. $here/v2ray_client/v2ray_client_alias.sh  >&2
. $here/v2ray_host/v2ray_host_alias.sh  >&2

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
        echo 'tfq [start]       开启终端代理'
        echo 'tfq stop          关闭终端代理'
        echo 'tfq staus         查看终端代理的端口设置'
        echo
        echo 'tfq 终端开始代理, 对curl, w3m有效，对ping无效'
        echo 'w3m www.google.com 与 w3m www.google.hk 只能显示搜索入口主页, 无法显示搜索结果页'
        echo 'w3m www.google.jp 则都能显示'
    fi
}

# 若当前有翻墙检测, 则开机登录时开启终端翻墙
if [ "$(v2 jch 2>/dev/null)" != '' ]; then
    tfq_start_ http $v2_http_port > /dev/null
elif [ "$(ss jch 2>/dev/null)" != '' ]; then
    tfq_start_ http $ss_http_port > /dev/null
fi
unset -v here
