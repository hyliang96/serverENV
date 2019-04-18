# ---------------------- 服务器台数 ------------------
# export GPU_NUM=24
# export CPU_NUM=4


c=($(echo juncluster{1..4}))
g=($(echo jungpu{1..24}))
gJ1=($(echo jungpu{1..13}))
gJ2=($(echo jungpu{14..24}))
J1=( "${c[@]}" "${gJ1[@]}" )
a=( "${c[@]}" "${g[@]}" )

server_sets=(c  g  gJ1  gJ2  a )


# 用不了的gpu
INVALID_GPU=()
export INVALID_GPU
# 用不了的cpu
INVALID_CPU=()
export INVALID_CPU


