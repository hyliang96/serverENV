#!/usr/bin/env bash

# install shadowsocks server
sssinstall()
{
    cd /home/$USER
    wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
    chmod +x shadowsocks-all.sh
    echo
    echo -----------------------------------------------------------------------
    echo 'what you need to do next'
    echo ' * select "chacha20"  as protocol'
    echo ' * set a password for this ss account'
    echo ' * other arguments just as defaut'
    echo -----------------------------------------------------------------------

    sudo /shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log
    echo -----------------------------------------------------------------------
    echo Usage:
    echo '    ss [start | stop | restart | status]'
}

# ss server
# 运行ss：参数[start | stop | restart | status]
alias sss="/etc/init.d/shadowsocks-python"
# 查看ss的教程
alias jchsss="ps aux | grep  ssserver | grep -v grep"
# ss的配置文件
alias sssconfig='/etc/shadowsocks-python/config.json'
# ss的运行日志
ssslog='/var/log/shadowsocks.log'
# ss安装的日志
sssinstall_log='/root/shadowsocks-all.log'

