#!/usr/bin/bash
echo A >&2
v2ray_config_dir="$HOME/.v2ray"
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`

v2ray_core='xray' # 'xray' 'v2ray'

v2ray_dir_up="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)/.."
v2ray_dir="$v2ray_dir_up/${v2ray_core}"
v2ray_path="${v2ray_dir}/${v2ray_core}"
v2_script="${BASH_SOURCE[0]-$0}"
v2_log_dir="$localENV/log/v2ray"

v2_socks5_port=1080
v2_http_port=1087
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
# here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
echo A1 >&2
_v2_install()
{
    if [ "${v2ray_core}" = v2ray ]; then
        local repo='https://github.com/v2fly/v2ray-core'
    elif [ "${v2ray_core}" = xray ]; then
        local repo='https://github.com/XTLS/Xray-core'
    fi

    local newest_version_url="${repo}/releases/latest"
    local newest_version=$(curl --silent ${newest_version_url} 2>/dev/null| sed -E 's|.+tag/v([0-9.]+)".+|\1|')
    if [ "${newest_version}" = '' ]; then
        echo "Failed to connect to ${newest_version_url}"
        return
    fi

    if [ -d "$v2ray_dir" ] && [ -f "${v2ray_path}" ] ; then
        local now_version="$($v2ray_path --version | grep -iEo "${v2ray_core} [0-9]+(.[0-9]+)+" | grep -oE '([0-9]+\.)+[0-9]+')"
        if [ "${now_version}" = '' ]; then
            echo "Failed to get current ${v2ray_core} version by `${v2ray_core} --version`"
        else
            echo "Current version is v${now_version}"
        fi
        echo "Newest version is v${newest_version}"
    fi

    if [  -f "${v2ray_path}"  ] && [ "${now_version}" != '' ] && \
        [ "$(echo ${now_version}$'\n'${newest_version} | sort --version-sort | tail -n 1)" = ${now_version} ]; then
        echo "Not to update ${v2ray_core}" >&2
        return
    fi

    if  [ "${now_version}" != '' ]; then
        local answer=$(bash -c "read  -n 1 -p '已有${v2ray_core} v$now_version，是否更新为 v$newest_version ? [Y|N]' c; echo \$c"); echo
        if [ "$answer" != 'y' ] && [ "$answer" != 'Y' ]; then
            echo "不更新，退出"
            return
        fi
    fi
    echo "Installing newest ${v2ray_core} v${newest_version}"
    echo

    local v2ray_back_dir=$v2ray_dir_up/${v2ray_core}_back
    mkdir -p ${v2ray_back_dir}
    local back_dir="${v2ray_back_dir}/${v2ray_core}-v${now_version}-backup_at_$(date +%F-%T)"
    [ -d $v2ray_dir ] && mv $v2ray_dir $back_dir && echo "原${v2ray_core}已备份到$back_dir"
    local zip_file=$v2ray_dir_up/${v2ray_core}-linux-64.zip
    [ -f ${zip_file} ] && rm ${zip_file}

    echo "下载${v2ray_core}-v${newest_version}"
    curl -L ${repo}/releases/download/v${newest_version}/${v2ray_core}-linux-64.zip > ${zip_file}
    echo "解压${v2ray_core}-v${newest_version}"
    unzip -q ${zip_file} -d $v2ray_dir
    chmod +x "$v2ray_path"
    echo "安装到: $v2ray_path"

    if [ -d "$v2ray_dir" ] && [ -f "${v2ray_path}" ] ; then
        local now_version="$($v2ray_path --version | grep -iEo "${v2ray_core} [0-9]+(.[0-9]+)+" | grep -oE '([0-9]+\.)+[0-9]+')"
    fi
    if [ "${now_version}" = "${newest_version}" ]; then
        echo "清空安装包"
        [ -f  ${zip_file} ] && rm ${zip_file}
        echo
        echo '安装成功'
        echo "更新后版本："
        $v2ray_path --version
    else
        echo "${v2ray_core}-v${newest_version} 安装失败"
        echo "保留安装包以debug: ${zip_file}"
    fi
}

# 关闭开全局http,https,socks5 翻墙
_v2_stop()
{
    echo '--------- v2 stop --------'
    if [ "$(_v2_jch)" != '' ]; then
        killall $v2ray_path
        echo "closed previous ${v2ray_core} process"
    fi
    # 取消 export的环境变量
    tfq_stop_
}
# 列出本机可用的VPN的名字（自己起名，即 ~/.v2ray/xxxx.json 中的 xxxx）
_v2_ls()
{
    echo "under dir: $v2ray_config_dir"
    echo "${v2ray_core} servers:"
    ls $v2ray_config_dir | grep .json  | sed 's/.json//g'
}
# 开、重启全局http,https,socks5 翻墙
# v2 VPN名，默认是default
_v2_start()
{
    # 解析
    if [ $# -eq 0 ];    then
        echo default server
        local server=default
    else
        echo server $1
        local server=$1
    fi
    echo using ${v2ray_core} config: $server
    # 检查配置文件是否存在
    if ! [ -f $v2ray_config_dir/$server.json ]; then
        echo "not found v2ray client config: $v2ray_config_dir/$server.json"
        return
    fi
    # 关闭原来的
    _v2_stop
    # sleep 1

    # 打开
    echo '--------- v2 start -------'
    mkdir -p $v2_log_dir
    ( (
        $v2ray_path -config $v2ray_config_dir/$server.json
    ) & ) > $v2_log_dir/log 2>&1
    echo "opened ${v2ray_core} process"
    echo "log: $v2_log_dir"

    # 用polipo代理http(s)到socks5
    tfq_start_ http $v2_http_port
    #no_proxy表示一些不需要代理的网址,比如内网之类的
}
echo A2 >&2
# 自动补全
if [ "$(/bin/ps -p $$ | tail -n1 | awk '{printf $4}' | sed -E 's/^\-//')" = zsh ]; then
    __v2_start() {
        local cur cword words  # 定义变量，cur表示当前光标下的单词
        read -cn cword  # 所有指令集
        read -Ac words  # 当前指令的索引值
        cur="$words[$cword-1]" # 当前指令值
        if [ "$cur" = start ]; then
            reply=($(ls $v2ray_config_dir | grep .json  | sed 's/.json//g'))
        fi
    }
    compctl -K __v2_start v2
elif [ "$(/bin/ps -p $$ | tail -n1 | awk '{printf $4}' | sed -E 's/^\-//')" = bash ]; then
    __v2_start() {
        local cur prev words cword
        COMPREPLY=()  # 为数组，名字必须是COMPREPLY，在给COMPREPLY赋值之前，最好将它重置清空，避免被其它补全函数干扰
        cur=${COMP_WORDS[1]}

        if [ "${cur}" = start ]; then
            COMPREPLY=($(ls $v2ray_config_dir | grep .json  | sed 's/.json//g'))
        fi
    }
    complete -F __v2_start v2
fi


echo A3 >&2
_v2_jch()
{
    local title="$(/bin/ps aux | awk NR==1)"
    local content="$(/bin/ps aux | awk NR!=1 | grep --color -v grep | grep --color -v '/bin/ps aux' | grep --color -v 'awk NR!=1' | grep --color $v2ray_path )"
    [ "$content" != '' ] && echo "$title" && echo "$content" | grep --color $v2ray_path
}

_v2_log()
{
    cat $v2_log_dir/log | less
}

v2()
{
    if [ $# -eq 0 ]; then
        v2 help
    elif [ "$1" = 'install' ] || [ "$1" = 'update' ] ; then
        shift
        _v2_install
    elif ! [ -x $v2ray_path ]; then
        shift
        echo "executable file no found: $v2ray_path" >&2
        echo 'run `v2 install` to (re)install '"${v2ray_core}" >&2
    elif [ "$1" = 'stop' ]; then
        shift
        _v2_stop
    elif [ "$1" = 'start' ]; then
        shift
        _v2_start $@
    elif [ "$1" = 'ls' ]; then
        shift
        _v2_ls
    elif [ "$1" = 'jch' ] || [ "$1" = 'status' ]; then
        shift
        _v2_jch
    elif [ "$1" = 'log' ]; then
        shift
        _v2_log
    else
        echo 'v2ray client command line interface'
        echo
        echo '`v2 install|update`     install or update '"${v2ray-core}"
        echo '`v2 start [<vps_name>]` (re)open '"${v2ray-core}"' client; dafault vps_name="default"'
        echo '`v2 stop`               stop '"${v2ray-core}"' client'
        echo '`v2 ls`                 list all vps_name'
        echo '`v2 jch|status`         show all sslocal process'
        echo '`v2 log`                show log'
        echo
        echo '`$v2ray_config_dir`     dir to save all '"${v2ray-core}"' config'
        echo '`$v2ray_dir`            path to this '"${v2ray-core}"' bin'
        echo '`$v2_script`            dir to this script'
    fi
}


echo A4 >&2
