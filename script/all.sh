#!/bin/bash

# 参数解析
cpuonly=false
gpuonly=false

while getopts "cgh" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        c)
            cpuonly=true
            ;;
        g)
            gpuonly=true
            ;;
        h)
            echo "bash all.sh [-c] [-g] ['command1' ['command2' ['command3' ... ]]]
            -c: 只遍历cpu服务器
            -g: 只遍历gpu服务器
            -c -g 互斥，不可同时写
            无 -c 与 -g，则gpu，cpu服务器都遍历
            注意command_i两侧是单引号，不是双引号，不然会解析出错"
            exit 1
            ;;
        ?)  #当有不认识的选项的时候arg为?
            echo "unkonw argument"
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if $cpuonly && $gpuonly ; then
    echo "-c 与 -g 互斥"
    exit 1
fi


# 命令生成
cmds=''
for i in $*; do
    echo $i
    cmds="${cmds} echo '# $i'; $i; echo;"
done

#  服务器列表生成
gpu_servers=()
for ((i=1; i<=$GPU_NUM; i++)); do
    # 跳过用不了的gpu
    if [ "$(echo $INVALID_GPU | grep -w $i)" = "" ]; then
        gpu_servers+=("g$i")
    fi
done


cpu_servers=()
for ((i=1; i<=$CPU_NUM; i++)); do
    cpu_servers+=("c$i")
done
all_servers=("${cpu_servers[@]}" "${gpu_servers[@]}" )


if $cpuonly ; then
    servers=("${cpu_servers[@]}")
elif $gpuonly ; then
    servers=("${gpu_servers[@]}")
else
    servers=("${all_servers[@]}")
fi

# 临时文件夹
dir=~/.cache/all
mkdir -p $dir
if [ "$(ls $dir)" != "" ]; then
    rm $dir/* -rf
fi

# 并行遍历个服务器
for server in "${servers[@]}"; do
{
    # echo "ssh $server"
    echo "====== $server ======" >> $dir/$server.feedback
    ssh $server "$cmds" >> $dir/$server.feedback
} &
done
wait

# 输出ssh返回的结果
ls $dir/* | sort --version-sort | xargs -I {} cat {}
# 删除临时文件夹
rm $dir -rf
