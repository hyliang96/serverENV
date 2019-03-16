
dir=~/.cache/allgpustat
mkdir -p $dir
if [ "$(ls $dir)" != "" ]; then
    rm $dir/* -rf
fi

# for i in {1..$GPU_NUM}; do
for ((i=1; i<=$GPU_NUM; i++)); do
{
    # 跳过用不了的gpu
    if [ "`echo $INVALID_GPU | grep -w $i`" != "" ]; then
        continue
    fi
    # echo ssh g$i
    ssh g$i gpustat > $dir/g$i.gpustat
    echo "" >> $dir/g$i.gpustat
}&
done
wait

ls $dir/* | sort --version-sort | xargs -I {} cat {}
rm $dir -rf
