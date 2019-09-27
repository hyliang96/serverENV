#!/usr/bin/env bash

v2ra_yhost()
{
    if [ "$1" = 'install' ] || [ "$1" = 'uninstall' ]; then
        sudo bash <(curl -s -L https://git.io/v2ray.sh)
    fi
}
