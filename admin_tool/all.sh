#!/bin/bash

# 加载配置文件
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/all_config.sh

# 服务器组名
server_set=$1; shift

# 检查server_set是否有效
valid_server=false
for i in ${server_sets[@]}; do
    if [ "$i" = "$server_set" ]; then
        valid_server=true
        break
    fi
done
if [ "$valid_server" = false ]; then
    echo 'invalid server_set name' >&2
    return
fi

# 参数解析

if [ "$1" = '--no-prompt' ]; then
    shift
    no_prompt=true
else
    no_prompt=false
fi

# 命令生成
cmds=''
for i in "$@"; do
    if [ "$no_prompt" = true ]; then
        cmds="${cmds} $i; echo;"
    else
        echo -E "$i"
        i_print=${i//\$/\"\\\$\"}
        cmds="${cmds} echo -E \"# $i_print\"; $i; echo;"
    fi
done

#  服务器列表生成
eval "servers=(\${$server_set[@]})"

# 临时文件夹
dir=~/.cache/all
mkdir -p $dir
if [ "$(ls $dir)" != "" ]; then
    rm $dir/* -rf
fi

# 并行遍历个服务器
for server in ${servers[@]}; do
{
    # echo "ssh $server"
    if ! [ "$no_prompt" = true ]; then
        echo "====== $server ======" >> $dir/$server.feedback
    fi
    ssh $server "$cmds" >> $dir/$server.feedback 2>&1
} &
done
wait

# 输出ssh返回的结果
ls $dir/* | sort --version-sort | xargs -I {} cat {}
# 删除临时文件夹
rm $dir -rf
