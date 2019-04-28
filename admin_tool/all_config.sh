#!/usr/bin/env bash

# ---------------------- 服务器编组设置------------------
# 顺序编组
# 编组名=(前缀{起始数字..结束数字}后缀)
c=(juncluster{1..4})
g=(jungpu{1..24})
gJ1=(jungpu{1..13})
gJ2=(jungpu{14..24})

# 复合编组
# 编组名=( "${子编组1[@]}" "${子编组2[@]}" "${子编组3[@]}" )
J1=( "${c[@]}" "${gJ1[@]}" )
a=( "${c[@]}" "${g[@]}" )

# 有效编组：即只有写在此处的编组才会被 `all` 命令使用
server_sets=(c  g  gJ1  gJ2 J1  a )


# # 用不了的gpu
# INVALID_GPU=()
# export INVALID_GPU
# # 用不了的cpu
# INVALID_CPU=()
# export INVALID_CPU


