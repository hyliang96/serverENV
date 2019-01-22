#!/usr/bin/bash

# 关闭开全局http,https,socks5 翻墙
ssk()
{
	killall sslocal
	killall polipo
	if [ -f /home/haoyu/ENV/localENV/log/polipo/pid ]
	then
		rm /home/haoyu/ENV/localENV/log/polipo/pid
	fi
	# 取消 export的环境变量
	unset http_proxy
	unset https_proxy
	unset ftp_proxy
	unset no_proxy
}
# 列出本机可用的VPN的名字（自己起名，即 ~/.shadowsocks/xxxx.json 中的 xxxx）
ssls()
{
	echo shadowsocks servers:
	ls ~/.shadowsocks | grep .json  | sed 's/.json//g'
}
# 开、重启全局http,https,socks5 翻墙
# ss VPN名，默认是liang
ss()
{
	# 关闭原来的
	ssk
	sleep 1
	# 解析
	if [ $#=0 ];	then
		echo default server
		server=liang
	else
		echo server $1
		server=$1
	fi
	echo opening shadowsocks server: $server
	# 打开
	sslocal -c ~/.shadowsocks/$server.json \
		--pid-file /home/haoyu/ENV/localENV/log/shadowsocks/pid \
		--log-file /home/haoyu/ENV/localENV/log/shadowsocks/log \
		-d start  # 开成守护进程（不仅仅是后台进程），即系统关机/重启时才结束的进程
	polipo
	# 用polipo代理http(s)到socks5
	export http_proxy="http://127.0.0.1:8124"
	export https_proxy="http://127.0.0.1:8124"
	export ftp_proxy="http://127.0.0.1:8124"
	export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com,.souche.com" 
	#no_proxy表示一些不需要代理的网址,比如内网之类的
}


