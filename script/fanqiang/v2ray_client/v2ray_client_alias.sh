#!/usr/bin/bash

v2ray_config_dir="$HOME/.v2ray"
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
v2_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
v2ray_path="$v2_script_dir/../v2ray/v2ray"
v2_script="${BASH_SOURCE[0]-$0}"
v2_log_dir="$localENV/log/v2ray"
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

# 关闭开全局http,https,socks5 翻墙
_v2_stop()
{
    killall $v2ray_path
    echo "closed previous v2ray process"

    # 取消 export的环境变量
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset no_proxy
}
# 列出本机可用的VPN的名字（自己起名，即 ~/.v2ray/xxxx.json 中的 xxxx）
_v2_ls()
{
    echo "under dir: $v2ray_config_dir"
    echo "v2ray servers:"
    ls $v2ray_config_dir | grep .json  | sed 's/.json//g'
}
# 开、重启全局http,https,socks5 翻墙
# v2 VPN名，默认是default
_v2_start()
{
    # 解析
    if [ $# -eq 0 ];    then
        echo default server
        local server=default
    else
        echo server $1
        local server=$1
    fi
    echo using v2ray config: $server
    # 检查配置文件是否存在
    if ! [ -f $v2ray_config_dir/$server.json ]; then
        echo "not found v2ray client config: $v2ray_config_dir/$server.json"
        return
    fi
    # 关闭原来的
    _v2_stop
    # sleep 1

    # 打开
    mkdir -p $v2_log_dir
    ( (
        $v2ray_path -config $v2ray_config_dir/$server.json
    ) & ) > $v2_log_dir/log 2>&1
    echo "opened v2ray process"
    echo "log: v2_log_dir"

    # 用polipo代理http(s)到socks5
    export http_proxy="http://127.0.0.1:1087"
    export https_proxy="http://127.0.0.1:1087"
    export ftp_proxy="http://127.0.0.1:1087"
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com"
    #no_proxy表示一些不需要代理的网址,比如内网之类的
    echo "终端已翻墙"
}

_v2_jch()
{
    ps aux | awk NR==1
    ps aux | awk NR!=1 | grep --color -v grep | grep --color -v 'ps aux' | grep --color -v 'awk NR!=1' | grep --color $v2ray_path
}

_v2_status()
{
    cat $v2_log_dir/log
}

v2()
{
    if [ "$1" = 'stop' ]; then
        shift
        _v2_stop
    elif [ "$1" = 'start' ]; then
        shift
        _v2_start $@
    elif [ "$1" = 'ls' ]; then
        shift
        _v2_ls
    elif [ "$1" = 'jch' ]; then
        shift
        _v2_jch
    elif [ "$1" = 'status' ]; then
        shift
        _v2_status
    else
        echo 'v2ray client command line interface'
        echo
        echo '`v2 start [<vps_name>]` (re)open v2ray client; dafault vps_name="default"'
        echo '`v2 stop`               stop v2ray client'
        echo '`v2 ls`                 list all vps_name'
        echo '`v2 jch`                show all sslocal process'
        echo 
        echo '`$v2ray_config_dir`     dir to save all v2ray config'
        echo '`$v2ray_dir`            path to this v2ray bin'
        echo '`$v2_script`            dir to this script'
    fi
}


unset -v v2_script_dir
