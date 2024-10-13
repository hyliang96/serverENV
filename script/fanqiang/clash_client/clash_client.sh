#!/usr/bin/bash


# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`


clash_dir="$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)/../clash-for-linux"
clash_script="${BASH_SOURCE[0]-$0}"

clash_http_port=7890

_clash_stop() {
    echo '----------- clash stop ----------'
    bash ${clash_dir}/shutdown.sh
    # 取消 export的环境变量
    tfq_stop_
}

_clash_start() {
    local PID_NUM=$(ps -ef | grep [c]lash-linux-a | wc -l)
    if [ $PID_NUM -eq 0 ]; then
        bash ${clash_dir}/start.sh
    else
        bash ${clash_dir}/restart.sh
    fi
    tfq_start_ http $clash_http_port
}

_clash_jch() {
    local title="$(/bin/ps aux | awk NR==1)"
    local content="$(/bin/ps aux | awk NR!=1 | grep --color -v grep | grep --color -v '/bin/ps aux' | grep --color -v 'awk NR!=1' | grep --color clash-linux-a )"
    [ "$content" != '' ] && echo "$title" && echo "$content" | grep --color clash-linux-a
}

clash() {
    if [ $# -eq 0 ]; then
        clash help
    elif [ "$1" = 'install' ] || [ "$1" = 'update' ] ; then
        shift
        #
    elif ! [ -x $v2ray_path ]; then
        shift
        # echo "executable file no found: $v2ray_path" >&2
        # echo 'run `v2 install` to (re)install '"${v2ray_core}" >&2
    elif [ "$1" = 'stop' ]; then
        shift
        _clash_stop
    elif [ "$1" = 'start' ]; then
        shift
        _clash_start
    elif [ "$1" = 'ls' ]; then
        shift
        # _v2_ls
    elif [ "$1" = 'jch' ] || [ "$1" = 'status' ]; then
        shift
        _clash_jch
    elif [ "$1" = 'log' ]; then
        shift
        # _v2_log
    else
        echo 'clash client command line interface'
        echo
        # echo '`v2 install|update`     install or update '"${v2ray-core}"
        echo '`clash start`           (re)start clash client'
        echo '`clash stop`            stop clash client'
        # echo '`v2 ls`                 list all vps_name'
        # echo '`v2 jch|status`         show all sslocal process'
        # echo '`v2 log`                show log'
        echo
        echo '`$v2ray_config_dir`     dir to save all '"${v2ray-core}"' config'
        echo '`$clash_dir`            path to this clash client dir'
        echo '`$clash_script`         dir to this script'
    fi

}
