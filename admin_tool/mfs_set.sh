#!/usr/bin/env bash

# 检测服务器的类型、所属局域网
host_id=$(hostname | tr -cd '[0-9]')
if [ "$(hostname | tr -d '[0-9]')" = 'jungpu' ]; then
    host_type='gpu'
    if [ $host_id -le 13 ]; then
        host_group='JUN1'   # 在jungpu1-13，juncluster1-4
    else
        host_group='JUN2'   # 在jungpu>=14
        mfs_source='jungpu'"`expr $host_id - 13`"
        # jungpuxx 的/mfs用sshfs挂载 jungpu(xx-13) 的 /mfs
    fi
else
    host_type='cpu'
    host_group='JUN1'
fi

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



