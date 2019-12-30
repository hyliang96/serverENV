#!/usr/bin/bash

vps_dir="$HOME/.shadowsocks"
ss_script="${BASH_SOURCE[0]-$0}"

ss_port=1080
polipo_port=8124

# ssr
alias sslocal="python3 $serverENV/app/shadowsocksr/shadowsocks/local.py"
# ss
# which sslocal, get: /home/haoyu/ENV/localENV/anaconda3/bin/sslocal

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

# 关闭开全局http,https,socks5 翻墙
ss_stop()
{
    echo '--------- ss stop --------'
    if [ -f $localENV/log/shadowsocks/pid ]; then
        eval $(ss_jch | awk NR!=1 | sed -r 's/(\S+\s+){10}//' | sed 's/ -d start/ -d stop/')
        # sslocal -d stop --pid-file $localENV/log/shadowsocks/pid
    fi
    if [ "$(ps aux | grep $USER | grep polipo | grep -v grep)" != '' ]; then
        killall polipo
    fi
    [ -f $localENV/log/polipo/pid ] && rm $localENV/log/polipo/pid
    # 取消 export的环境变量
    tfq_stop_
}
# 列出本机可用的VPN的名字（自己起名，即 ~/.shadowsocks/xxxx.json 中的 xxxx）
ss_ls()
{
    echo shadowsocks servers:
    ls $vps_dir | grep .json  | sed 's/.json//g'
}

polipo_gen() {
    mkdir -p ${localENV}/log/polipo

    cat >  ${HOME}/.polipo <<- EOF
proxyAddress = "127.0.0.1"
proxyPort = $polipo_port

allowedClients = 127.0.0.1
allowedPorts = 1-65535

socksParentProxy = "127.0.0.1:$ss_port"
socksProxyType = socks5

daemonise = true
logSyslog = true

logFile = $localENV/log/polipo/log
pidFile = $localENV/log/polipo/pid
EOF
}



# 开、重启全局http,https,socks5 翻墙
# ss VPN名，默认是default
ss_start()
{
    # 解析
    if [ $# -eq 0 ];    then
        local server=default
    else
        local server=$1
    fi

    local server_config="$vps_dir/$server.json"
    if [ -f "$server_config" ]; then
        echo "opening shadowsocks server: $server"
    else
        echo "file not found: $server_config" >&2
        return
    fi

    # 关闭原来的
    ss_stop
    echo '--------- ss start -------'
    sleep 1

    # 打开
    mkdir -p $localENV/log/shadowsocks
    sslocal -c $server_config \
        --pid-file $localENV/log/shadowsocks/pid \
        --log-file $localENV/log/shadowsocks/log \
        -d start  # 开成守护进程（不仅仅是后台进程），即系统关机/重启时才结束的进程

    # 用polipo代理http(s)到socks5
    polipo_gen
    # bash $serverENV/script/fanqiang/polipo/polipo_gen.sh  $ss_port $polipo_port
    polipo
    # 导出环境变量
    tfq_start_ $polipo_port
}

ss_jch()
{
    local pattern="$(alias sslocal | sed "s/^sslocal='//" | sed "s/'$//")"
    [ "$pattern" = '' ] && pattern='sslocal'
    local title="$(ps aux | awk NR==1)"
    local content="$(ps aux | awk NR!=1 | grep --color -v grep | grep --color -v 'ps aux' | grep --color -v 'awk NR!=1' | grep "$pattern" )"
    [ "$content" != '' ] && echo "$title" && echo "$content" | grep --color "$pattern"
}

ss()
{
    if [ "$1" = 'stop' ]; then
        shift
        ss_stop
    elif [ "$1" = 'start' ]; then
        shift
        ss_start $@
    elif [ "$1" = 'ls' ]; then
        shift
        ss_ls
    elif [ "$1" = 'jch' ] || [ "$1" = status ]; then
        shift
        ss_jch
    else
        echo '`ss start [<vps_name>]` open shadowsocks client; dafault vps_name="default"'
        echo '`ss stop`               stop shadowsocks client'
        echo '`ss ls`                 list all vps_name'
        echo '`ss jch|status`         show all sslocal process'
        echo '`$vps_dir`              dir to save all vps'
        echo '`$ss_script`            dir to fanqiang.sh script'
    fi

}

