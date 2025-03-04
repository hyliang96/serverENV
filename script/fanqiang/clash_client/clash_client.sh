#!/usr/bin/bash


# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`


clash_dir="$(realpath $(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)/../clash-for-linux)"
clash_subscript="$clash_dir/.env"
clash_config="$clash_dir/conf/config.yaml"
clash_log_dir="$clash_dir/logs"
clash_script="${BASH_SOURCE[0]-$0}"

clash_http_port=17890
# 7890

_clash_install() {
    local repo="git@github.com:wnlen/clash-for-linux.git"
    # local repo="https://hub.fastgit.org/wanhebin/clash-for-linux.git"
    mkdir -p "${clash_dir}_backup"
    local clash_back_dir="${clash_dir}_backup/clash-for-linux-backup_at_$(date +%F-%T)"
    [ -d "$clash_dir" ] && mv "$clash_dir" "$clash_back_dir" && echo "原clash-for-linux已备份到$clash_back_dir"
    echo
    echo "安装到: ${clash_dir}"
    git clone "$repo" "$clash_dir"
    rm "${clash_dir}/.env"
    ln -s "$serverENV/serverENV_private/.clash/.env" "${clash_dir}/.env"
    echo "clash-for-linux安装完成"
}

_clash_stop() {
    echo '----------- clash stop ----------'
    bash ${clash_dir}/shutdown.sh
    # 取消 export的环境变量
    tfq_stop_
}

_clash_start() {
    local PID_NUM=$(ps -f -u $(whoami) | grep [c]lash-linux-a | wc -l)
    if [ $PID_NUM -eq 0 ]; then
        bash ${clash_dir}/start.sh
    else
        bash ${clash_dir}/restart.sh
    fi
    sleep 1 # 等待clash开始接入 $clash_http_port 端口
    tfq_start_ http $clash_http_port
}

_clash_jch() {
    local title="$(/bin/ps aux | awk NR==1)"
    local content="$(/bin/ps aux | awk NR!=1 | grep --color -v grep | grep --color -v '/bin/ps aux' | grep --color -v 'awk NR!=1' | grep --color clash-linux-a )"
    [ "$content" != '' ] && echo "$title" && echo "$content" | grep --color clash-linux-a
}

_clash_log() {
    echo "ls $clash_log_dir/"
    ls "$clash_log_dir/"
    local log_file=$(bash -c "cd ${clash_log_dir};"' read -e -p "select log file: " log; echo $log')
    echo log_file=$log_file
    echo "less $clash_log_dir/$log_file"
    less "$clash_log_dir/$log_file"
}

clash() {
    if [ $# -eq 0 ]; then
        clash help
    elif [ "$1" = 'install' ] || [ "$1" = 'update' ] ; then
        shift
        _clash_install
    elif ! [ -f "${clash_dir}/start.sh" ]; then
        shift
        echo "file no found: $clash_dir/start.sh" >&2
        echo 'run `clash install` to (re)install clash client' >&2
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
        _clash_log
    else
        echo 'clash client command line interface'
        echo
        echo '`clash install|update`    install or update clash client'
        echo '`clash start`             (re)start clash client'
        echo '`clash stop`              stop clash client'
        echo ' clash stop; clash start  stop clash -> update suscripted configs -> start clash'
        echo ' clash start              stop clash (if it is on) -> start clash, without updating suscripted configs'
        echo '`clash jch|status`        show all clash process'
        echo '`clash log`               show log'
        echo
        echo '`$clash_subscript`        path of clash subscription config file'
        echo '`$clash_config`           path of clash config file'
        echo '`$clash_log_dir`          dir of clash logs'
        echo '`$clash_dir`              dir of this clash client'
        echo '`$clash_script`           path of this script'
    fi

}
