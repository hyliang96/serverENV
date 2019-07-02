

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

# alias _allsshmfs="all J23 'umount -l /home/haoyu/mfs; su -l haoyu -c \"sshmfs\"'"
# alias allsshmfs="sudo su -c '. $here/load_all.sh; _allsshmfs'"
# alias test="sudo su -c 'source $here/load_all.sh; all'"
# alias allsshmfs="all J23 'sshmfs'"

unset here
