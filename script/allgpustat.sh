
dir=~/.cache/allgpustat
mkdir -p $dir
rm $dir/* -rf

# for i in {1..$GPU_NUM}; do
for ((i=1; i<=$GPU_NUM; i++)); do
{
	echo ssh g$i
	ssh g$i gpustat > $dir/g$i.gpustat
	echo "" >> $dir/g$i.gpustat	
}&
done
wait

ls $dir/* | sort --version-sort | xargs -I {} cat {}
rm $dir -rf