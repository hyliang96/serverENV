
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
echo fanqiang.sh >&2



# clash


# 开启clash的系统代理
function proxy_on() {
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
    export no_proxy=127.0.0.1,localhost
    export HTTP_PROXY=http://127.0.0.1:7890
    export HTTPS_PROXY=http://127.0.0.1:7890
    export NO_PROXY=127.0.0.1,localhost
    echo -e "\033[32m[√] 已开启代理\033[0m"
}
# 关闭clash的系统代理
function proxy_off(){
    unset http_proxy
    unset https_proxy
    unset no_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset NO_PROXY
    echo -e "\033[31m[×] 已关闭代理\033[0m"
}


fq_tool=clash # clash, v2, ss

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

echo a >&2
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
