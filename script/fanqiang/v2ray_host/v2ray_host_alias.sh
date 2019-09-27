#!/usr/bin/env bash

v2ray()
{
    if [ "$1" = 'install' ] || [ "$1" = 'uninstall' ] || [ "`command v2ray -h 2&>1`" = '' ]; then
        sudo su -c 'bash <(curl -s -L https://git.io/v2ray.sh)'
    else
        sudo v2ray $@
    fi
}
