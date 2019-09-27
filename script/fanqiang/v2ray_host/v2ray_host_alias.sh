#!/usr/bin/env bash

v2ray_host()
{

    if [ "$1" = 'install' ] || [ "$1" = 'uninstall' ]; then
        sudo su -c 'bash <(curl -s -L https://git.io/v2ray.sh)'
    else
        echo "\`v2ray_host [ (un)install | help ]\`"
    fi
}
