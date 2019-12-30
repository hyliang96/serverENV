#!/usr/bin/bash

v2ray_config_dir="$HOME/.v2ray"
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
v2_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
v2ray_path_up="$v2_script_dir/.."
v2ray_path="$v2_script_dir/../v2ray/v2ray"
v2_script="${BASH_SOURCE[0]-$0}"
v2_log_dir="$localENV/log/v2ray"

v2_socks5_port=1080
v2_http_port=1087
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

_v2_install()
{
    local v2ray_dir="$v2ray_path_up/v2ray"
    local new_version=$(curl --silent https://api.github.com/repos/v2ray/v2ray-core/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')

    if [ -d "$v2ray_dir" ]; then
        local version="$($v2ray_path --version | grep -Eo 'V2Ray [0-9]+(.[0-9]+)+' | sed 's/V2Ray //')"

        answer=$(bash -c "read  -n 1 -p '已有v2ray-core-$version，是否更新为$new_version ? [Y|N]' c; echo \$c"); echo

        if [ "$answer" != 'y' ] && [ "$answer" != 'Y' ]; then
            echo "不更新，退出"
            return
        fi

        mkdir -p $v2ray_path_up/v2ray_back
        local back_dir="$v2ray_path_up/v2ray_back/v2ray-v$version-back_at_$(date +%F-%T)"
        mv $v2ray_dir $back_dir
        echo "原v2ray-core已备份到$back_dir"
    fi

    echo "下载v2ray-core-$new_version"
    curl -L https://github.com/v2ray/v2ray-core/releases/latest/download/v2ray-linux-64.zip > $v2ray_path_up/v2ray-linux-64.zip
    echo "解压v2ray-core-$new_version"
    unzip -q $v2ray_path_up/v2ray-linux-64.zip -d $v2ray_dir
    echo "清空安装包"
    [ -f  $v2ray_path_up/v2ray-linux-64.zip ] && rm $v2ray_path_up/v2ray-linux-64.zip

    echo "安装到: $v2ray_path"
    echo "更新后版本："
    $v2ray_path --version
}


# 关闭开全局http,https,socks5 翻墙
_v2_stop()
{
    echo '--------- v2 stop --------'
    if [ "$(_v2_jch)" != '' ]; then
        killall $v2ray_path
        echo "closed previous v2ray process"
    fi
    # 取消 export的环境变量
    tfq_stop_
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
    echo '--------- v2 start -------'
    mkdir -p $v2_log_dir
    ( (
        $v2ray_path -config $v2ray_config_dir/$server.json
    ) & ) > $v2_log_dir/log 2>&1
    echo "opened v2ray process"
    echo "log: v2_log_dir"

    # 用polipo代理http(s)到socks5
    tfq_start_ http $v2_http_port
    #no_proxy表示一些不需要代理的网址,比如内网之类的
}

_v2_jch()
{
    local title="$(ps aux | awk NR==1)"
    local content="$(ps aux | awk NR!=1 | grep --color -v grep | grep --color -v 'ps aux' | grep --color -v 'awk NR!=1' | grep --color $v2ray_path )"
    [ "$content" != '' ] && echo "$title" && echo "$content" | grep --color $v2ray_path
}

_v2_status()
{
    cat $v2_log_dir/log
}

v2()
{
    if [ $# -eq 0 ]; then
        v2 help
    elif [ "$1" = 'install' ] || [ "$1" = 'update' ] ; then
        shift
        _v2_install
    elif ! [ -x $v2ray_path ]; then
        shift
        echo "executable file no found: $v2ray_path" >&2
        echo 'run `v2 install` to (re)install v2ray' >&2
    elif [ "$1" = 'stop' ]; then
        shift
        _v2_stop
    elif [ "$1" = 'start' ]; then
        shift
        _v2_start $@
    elif [ "$1" = 'ls' ]; then
        shift
        _v2_ls
    elif [ "$1" = 'jch' ] || [ "$1" = 'status' ]; then
        shift
        _v2_jch
    elif [ "$1" = 'status' ]; then
        shift
        _v2_status
    else
        echo 'v2ray client command line interface'
        echo
        echo '`v2 install|update`     install or update v2ray-core'
        echo '`v2 start [<vps_name>]` (re)open v2ray client; dafault vps_name="default"'
        echo '`v2 stop`               stop v2ray client'
        echo '`v2 ls`                 list all vps_name'
        echo '`v2 jch|status`         show all sslocal process'
        echo
        echo '`$v2ray_config_dir`     dir to save all v2ray config'
        echo '`$v2ray_dir`            path to this v2ray bin'
        echo '`$v2_script`            dir to this script'
    fi
}


unset -v v2_script_dir
