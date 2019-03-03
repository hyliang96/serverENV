#!/usr/bin/env bash

# 所用安装方法
# 秋水逸冰 一键安装ss服务端
# https://teddysun.com/486.html

# install shadowsocks server
s3download()
{
    cd $server_script
    if ! [ -f ./shadowsocks-all.sh ]; then
        wget --no-check-certificate -O shadowsocks-all.sh https://raw.githubusercontent.com/teddysun/shadowsocks_install/master/shadowsocks-all.sh
    fi
    chmod +x shadowsocks-all.sh
}

s3install()
{
    s3download
    cd $server_script
    echo
    echo -----------------------------------------------------------------------
    echo 'what you need to do next'
    echo ' * select "chacha20"  as protocol'
    echo ' * set a password for this ss account'
    echo ' * select a large (5-digit) port'
    echo ' * When It Show "HIT: <WebLink>", and stucks; just press ENTER for times'
    echo '   当出现五行"HIT: <网址>"时，会卡住，只需多按几次回车即可'
    echo -----------------------------------------------------------------------
    sudo ./shadowsocks-all.sh 2>&1 | tee shadowsocks-all.log
    echo -----------------------------------------------------------------------
    echo Usage:
    echo '    s3 [start | stop | restart | status ]'
}

s3uninstall()
{
    s3download
    cd $server_script
    sudo ./shadowsocks-all.sh uninstall
}

# 查看ss的进程
alias jchs3="ps aux | grep  ssserver | grep -v grep"
# ss的配置文件
s3c=/etc/shadowsocks-python/config.json
# ss的运行日志
s3l=/var/log/shadowsocks.log
# ss安装的日志
s3il=/root/shadowsocks-all.log
# 本脚本
s3a=$serverENV/script/my_sshost.sh
# ss服务端运行脚本
s3s=/etc/init.d/shadowsocks-python
# 运行参数[start | stop | restart | status]

s3()
{
    if [ $# -eq 0 ]; then
        echo 'Usage : s3 [ start | stop | restart | status | help | (un)install ]'
    elif [ "$1" = "help" ]; then
        echo 'Usage : s3 [ start | stop | restart | status | help | (un)install ]'
        echo '`jchs3`:  查看ss server的教程'
        echo '$s3c:  ss server的配置文件'
        echo '$s3l:  ss server的运行日志'
        echo '$s3il: ss server安装的日志'
        echo '$s3a:  ss server的alias文件'
        echo '$s3s:  ss server的运行脚本'
        echo 'when `s3` is running, it will requires you for sudo'
        echo 'but dont `sudo s3`, because s3 function will not be loaded by sudo'
    elif [ "$1" = "install" ]; then
        s3install
    elif [ "$1" = "uninstall" ]; then
        s3uninstall
    else
        sudo $s3s $*
    fi
}
