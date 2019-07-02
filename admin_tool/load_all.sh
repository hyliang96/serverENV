

# get absoltae path to the dir this is in, work in bash, zsh
# if you want transfer symbolic link to true path, just change `pwd` to `pwd -P`
here=$(cd "$(dirname "${BASH_SOURCE[0]-$0}")"; pwd)

alias all="$SHELL $here/all.sh"

alias send="$SHELL $here/all.sh --send"

allgpu()
{
    local server_set=
    if [ $# -eq 0 ]; then
        server_set=g
    else
        server_set="$1"
    fi
    all "$server_set" --no-prompt 'gpustat'
}

. $here/adduser_command.sh

. $here/mfs_set.sh


_allmfsstart()
{
    all J1 ". $here/load_all.sh; mfsstart"
}
alias allmfsstart="sudo su -c '. $here/load_all.sh; _allmfsstart'"

_allsshmfs()
{
    all J23 'umount -l /home/haoyu/mfs; su -l haoyu -c \"sshmfs\"'
}
alias allsshmfs="sudo su -c '. $here/load_all.sh; _allsshmfs'"
# 注意，不可把 _allsshmfs 写成一个 alias，必需写成function
# 这是因为 su -c 'xxxx' 是非交互式登录，故未经专门设置则不支持alias，只支持function

unset here
