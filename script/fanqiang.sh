#!/usr/bin/bash

vps_dir="~/.shadowsocks"
ss_script="${BASH_SOURCE[0]-$0}"
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

# 关闭开全局http,https,socks5 翻墙
ss_stop()
{
    killall sslocal
    killall polipo
    [ -f $localENV/log/polipo/pid ] && rm $localENV/log/polipo/pid
    # 取消 export的环境变量
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
}
# 列出本机可用的VPN的名字（自己起名，即 ~/.shadowsocks/xxxx.json 中的 xxxx）
ss_ls()
{
    echo shadowsocks servers:
    ls $vps_dir | grep .json  | sed 's/.json//g'
}
# 开、重启全局http,https,socks5 翻墙
# ss VPN名，默认是default
ss_start()
{
    # 关闭原来的
    s_stop
    sleep 1
    # 解析
    if [ $# -eq 0 ];    then
        echo default server
        local server=default
    else
        echo server $1
        local server=$1
    fi
    echo opening shadowsocks server: $server
    # 打开
    mkdir -p $localENV/log/shadowsocks
    sslocal -c $vps_dir/$server.json \
        --pid-file $localENV/log/shadowsocks/pid \
        --log-file $localENV/log/shadowsocks/log \
        -d start  # 开成守护进程（不仅仅是后台进程），即系统关机/重启时才结束的进程

    . $serverENV/app_config/.polipo_gen.sh
    polipo
    # 用polipo代理http(s)到socks5
    export http_proxy="http://127.0.0.1:8124"
    export https_proxy="http://127.0.0.1:8124"
    export ftp_proxy="http://127.0.0.1:8124"
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com"
    #no_proxy表示一些不需要代理的网址,比如内网之类的
}

ss()
{
    if [ "$1" = 'stop' ]; then
        shift
        ss_stop $@
    elif [ "$1" = 'start' ]; then
        shift
        ss_start $@
    elif [ "$1" = 'ls' ]; then
        shift
        ss_ls
    else
        echo '`ss start [<vps_name>]` open shadowsocks client; dafault vps_name="default"'
        echo '`ss stop`               stop shadowsocks client'
        echo '`ss ls`                 list all vps_name'
        echo '`$vps_dir`              dir to save all vps'
        echo '`$ss_script`            dir to fanqiang.sh script'
    fi

}

