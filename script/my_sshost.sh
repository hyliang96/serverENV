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
    echo -----------------------------------------------------------------------
    echo '安装方法:'
    echo " * 请安装shadowsocksR（即ssr）"
    echo ' * set a password for this ss account'
    echo ' * select a large (5-digit) port'
    echo ' * 选加密方式：'
    echo ' * 方案一：速度达 5-10MB/s'
    echo '    cipher method 选 "none", protocol 选 "auth_chain_b", obfs 选 "plain"'
    echo ' * 方案二：'
    echo '    cipher method 选"chacha20"， protocol 选 "origin", obfs 选 "plain" '
    echo ' * 当出现五行"HIT: <网址>"时，会卡住，只需多按几次回车即可'
    echo -----------------------------------------------------------------------
    echo -n "请复制本说明到备忘录，然后按任意键继续，之后这些信息会消失："
    local answer
    read -n 1 answer
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
# ss的类型: python, r, go, libev
ss_type='r'
# ss的配置文件
s3c=/etc/shadowsocks-$ss_type/config.json
# ss的运行日志
s3l=/var/log/shadowsocks.log
# ss安装的日志
s3il=/root/shadowsocks-all.log
# 本脚本
s3a=$serverENV/script/my_sshost.sh
# ss服务端运行脚本
s3s=/etc/init.d/shadowsocks-$ss_type
# 运行参数[start | stop | restart | status]

s3()
{
    if [ $# -eq 0 ]; then
        echo 'Usage : s3 [ start | stop | restart | status | help | (un)install ]'
    elif [ "$1" = "help" ] || [ "$1" = "h" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "-help" ]; then
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
