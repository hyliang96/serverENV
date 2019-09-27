#!/usr/bin/env bash

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
