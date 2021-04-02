#!/bin/bash
# 使用crontab，脚本会每10秒清理宿主机无用、停止的容器和镜像
# 日志会达到100M大小时切割并压缩删除源文件，以当前脚本执行时间追加命令

# 定时任务
# * * * * * /root/clean_containers.sh >> /root/cc.log


# 间隔时间
st=10
# 日志最大大小(单位: kb)
log_bytes=100000
# 日志名
log_name=cc.log

for num in $(seq 0 5)
do
	echo "=== $(date +%F_%T) ==="
	docker system prune -f
	sleep ${st}
done

cd $(dirname $0)
file_size=$(ls -s ${log_name})
file_rotate_date=$(date +%F_%H.%M.%S)
# 文件大于100M，做切割处理
if [[ $(echo ${file_size} | awk '{print $1}') -ge ${log_bytes} ]]
then
	cp ${log_name}{,.${file_rotate_date}}
        echo -n "" > ${log_name}
        tar -zcf ${log_name}.${file_rotate_date}.tar.gz ${log_name}.${file_rotate_date} --remove-files
fi
