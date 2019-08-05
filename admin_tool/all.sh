#!/bin/bash

# ---------------------------------------
# 加载配置文件
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/all_config.sh
. $here/utils.sh


# ---------------------------------------
# 参数解析
# 参数预处理
TEMP=$(getopt \
    -o      nsu \
    --long  no-prompt,send,checkuid \
    -n      '参数解析错误' \
    -- "$@")
# 写法
    #   -o     短参数 不需要分隔符
    #   --long 长参数 用','分隔
    #   ``无选项  `:`必有选项  `::` 可由选项
if [ $? != 0 ] ; then echo "格式化的参数解析错误，正在退出" >&2 ; exit 1 ; fi
eval set -- "$TEMP" # 将复制给 $1, $2, ...

# 初始化参数
no_prompt=false
send=false
checkuid=false

# 处理参数
while true ; do case "$1" in
    # 无选项
    -n|--no-prompt)  no_prompt=true  ; shift ;;
    -s|--send)       send=true; shift ;;
    -u|--checkuid)   no_prompt=true; checkuid=true; shift ;;
    # '--'后是 余参数
    --) shift ; break ;;
    # 处理参数的代码错误
    *) echo "参数处理错误" ; exit 1 ;;
esac ; done

# ---------------------------------------
# 服务器组名
if [ "$checkuid" = true ]; then
    server_set=$1; shift
elif [ "$send" = true ]; then
    server_set_path="${@:$#}"
    set -- "${@:1:$(($# - 1))}"
    server_set="${server_set_path%%:*}"  # 第一个':'左侧
    server_path="${server_set_path#*:}" # 第一个':'右侧
else
    server_set=$1; shift
fi



# 检查server_set是否有效
valid_server=false
for i in ${server_sets[@]}; do
    if [ "$i" = "$server_set" ]; then
        valid_server=true
        break
    fi
done
if [ "$valid_server" = false ]; then
    #  服务器列表生成
    eval "servers=($server_set)"
    if ! [ "$(is_array servers)" = true ]; then
        echo 'invalid server_set' >&2
        echo "Usage: all <server_set_name> '<command>'"
        echo "Usage: all 'server1 server2 server3' '<command>'"
        echo "Usage: all 'server{1..3} server{10..13}' '<command>'"
        return
    fi
else
    #  服务器列表生成
    eval "servers=(\${$server_set[@]})"
fi



# ---------------------------------------
# 命令生成
if [ "$checkuid" = true ]; then
    uid=$1
elif [ "$send" = true ]; then
    :
else
    cmds=''
    for arg do
        if [ "$no_prompt" = true ]; then
            cmds="${cmds} $arg; echo;"
        else
            echo -E "$arg"
            i_print=${arg//\$/\"\\\$\"}
            cmds="${cmds} echo -E \"# $i_print\"; $arg; echo;"
        fi
    done
fi


# ---------------------------------------
# 临时文件夹
dir=~/.cache/all
mkdir -p $dir
if [ "$(ls $dir)" != "" ]; then
    rm $dir/* -rf
fi


if [ "$host_group" = 'JUN1' ]; then
# 在gpu1-13，cluster1-4
    ssh_config=$here/config_JUN1
elif [ "$host_group" = 'JUN2' ]; then
# 在gpu14-24
    ssh_config=$here/config_JUN2
fi

# # ---------------------------------------
# # 检查每台服务器可连接
# touch $dir/reachable_servers
# for server in ${servers[@]}; do
# {
#     temp="$(ssh -o ConnectTimeout=1 $server 'echo reachable_server' 2>&1)"
#     if [[ "$temp" =~ 'reachable_server' ]]; then
#         echo "$server" >> $dir/reachable_servers
#     else
#         echo "$server Can Not Connet: $temp" >&2
#     fi
# } &
# done
# wait

# IFS_old=$IFS
# IFS=$'\r\n'
# servers=($(<$dir/reachable_servers))
# IFS=$IFS_old





# 初始化：servers和unfinished_output
for server in ${servers[@]}; do
    echo $server >> $dir/servers
    echo -n "$server " >> $dir/unfinished_output
done
if [ "$checkuid" = true ]; then
    available=1
fi
finish=0

watch -n 1 -t "cat $dir/unfinished_output && ls $dir/*.feedback 2> /dev/null | sort --version-sort | xargs -I {} cat {}" &

# 退出进程
exit_func()
{
    # 杀死所有子进程
    pkill -P $$
    # 输出uid是否可用
    if [ "$checkuid" = true ]; then
        if [ "$available" = '1' ]; then
            echo "uid $uid is available"
        else
            echo "uid $uid is not available"
        fi
    fi
    # 输出ssh返回的结果
    local files=($dir/*.feedback) 2> /dev/null
    [ -f "${files[1]}" ] && { ls $dir/*.feedback | sort --version-sort | xargs -I {} cat {} }
    # 未完成的
    if [ "$finish" = 1 ]; then
        echo -n 'unfinished servers:'
        cat $dir/unfinished_output
    fi
    # 删除临时文件夹
    rm $dir -rf
    # 退出程序
    exit
}

function ctrl_c() {
    exit_func
}

trap ctrl_c SIGINT

# 主循环
for server in ${servers[@]}; do
{
    if ! [ "$no_prompt" = true ]; then
        echo "====== $server ======" >> $dir/$server.feedback
    fi

    if [ "$checkuid" = true ]; then
        result="$(ssh $server id $uid 2>&1)"
        if ! [[ "$result" =~ 'no such user' ]]; then
            echo "$server: $result" >> $dir/$server.feedback 2>&1
            available=0
        fi
    elif [ "$send" = true ]; then
        # echo "rsync -aHhzP -e \"ssh -F $ssh_config\" $@ $server:$server_path "
        # command rsync -aHhzP -e "ssh -F $ssh_config" $@ $server:$server_path >> $dir/$server.feedback 2>&1
        echo "rsync -aHhzP -e \"ssh -o 'StrictHostKeyChecking no'\"  $@ $server:$server_path "
        command rsync -aHhzP -e "ssh -o 'StrictHostKeyChecking no'" $@ $server:$server_path >> $dir/$server.feedback 2>&1
    # command表示系统原版rsync命令
    else
        ssh -o 'StrictHostKeyChecking no' $server "$cmds" >> $dir/$server.feedback 2>&1
        # ssh -F $ssh_config $server "$cmds" >> $dir/$server.feedback 2>&1
        # ssh -F $ssh_config -o 'StrictHostKeyChecking no' $server "$cmds" >> $dir/$server.feedback 2>&1
    fi

    #-- collect unfinished servers --
    echo "$server" >> $dir/finished
    # 计算差集 servers - finished
    unfinished="`sort $dir/servers $dir/finished | uniq -u`"
    # unfinished中换行符换为空格
    unfinished="${unfinished//
/ }"
    # unfinished_output 文件仅一行，为未返回结果的服务器名，已排序
    echo $unfinished > $dir/unfinished_output

} &
done

# exit when all servers return result
while true; do
    if [ "`cat $dir/unfinished_output`"  = '' ]; then
        finish=1
        exit_func
    fi
done

wait

exit_func

