#!/usr/bin/env bash

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
v2ray_host_script_dir=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
v2host="${v2ray_host_script_dir}/v2host.sh"
# release this variable in the end of file
unset -v v2ray_host_script_dir

# 安装原生的v2ray
v2ray()
{
    if [ "$1" = 'install' ] || [ "$1" = 'uninstall' ]; then
        sudo su -c 'bash <(curl -s -L https://git.io/v2ray.sh)'
    elif [ "`command v2ray -h 2>&1 | grep 'command not found'`" != '' ]; then
        local prompt='没有安装v2ray，是否继续安装？'
        local answer=$(bash -c 'read  -n 1 -p "'"$prompt"'? [Y/N] " c; echo $c'); echo
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            sudo su -c 'bash <(curl -s -L https://git.io/v2ray.sh)'
        fi
    else
        sudo v2ray $@
    fi
}

# v2ray 多合一脚本
v2host() {
    if [[ "$1" =~  ^(help|-h|--help|)$ ]]; then
        echo 'v2host help|h|-h|--help       : help'
        echo 'v2host install|upgrade|update : install/update the script'
        echo 'v2host                        : run v2ray 七合一脚本'
    elif [ ! -f h"${v2host}" ] || [[ "$1" =~ ^(install|update|upgrade)$ ]]; then
        wget https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh -O "${v2host}"
        sudo bash ${v2host}
    else
        sudo bash ${v2host}
    fi
}
