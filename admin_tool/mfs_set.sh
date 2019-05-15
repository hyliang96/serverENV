#!/usr/bin/env bash

# ---------------------------------------
# 加载配置文件
# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)
. $here/all_config.sh



mfsstart()
{
    if [ "$host_group" = 'JUN1' ]; then
        sudo mfsmount /mfs -H mfsmaster && ls /home/$USER/mfs/
    elif [ "$host_group" = 'JUN2' ]; then
        sudo sshfs  $mfs_source:/mfs /mfs -o allow_other,default_permissions
    fi
    echo 'ls /mfs | head -n 10'
    echo $(ls /mfs | head -n 10)
}



