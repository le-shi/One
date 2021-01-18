#!/bin/bash
# 定时处理
# 大小处理
# oss
# 处理后压缩删源

# 假设任务每5分钟执行一次，脚步开始运行，处理一次日志不退出，内部循环每10s一次，判断日志大小，脚步运行到290s时，kill掉自己，等待定时任务下次执行

# 获取主机名
host_name=$(hostname)
# 定义docker数据目录
docker_var_path=/var/lib/docker
# 定义docker日志目录
docker_log_path=containers
# 定义docker日志缓存目录
docker_log_temp_path=docker_log_dir
# 定义时间戳_2020-02-06_13-39-13
log_tar_timestamp=$(date +%F_%H-%M-%S)
# 定义日志操作类型，time为每次执行脚本时执行(crontab)，size为脚本内循环执行
type=time

# 定义日志处理方法
log_rodate(){
    # 查出当前的容器数
    container_list=$(ls ${docker_log_path})
    # 截取容器ID前12位和docker container ls校验，拿到容器名
    for container in ${container_list[@]};do
        container_log_name=${docker_log_path}/${container}/${container}-json.log
        container_sid=${container:0:12}
        container_name=$(docker container ls --filter id=${container_sid} --format '{{.Names}}')
        if [[ ${type} == "time" ]];then
            # 获取日志文件行数，文件判空处理
            if test -s ${container_log_name}; then
                container_log_line=$(wc -l ${container_log_name} | awk '{print $1}')
            else
                continue
            fi
        elif [[ ${type} == "size" ]];then
            ## 判断日志大小,处理日志
            container_log_size=$(ls -l ${container_log_name} | awk '{print $5}')
            # 文件大于4M
            if [[ 4000000 -le ${container_log_size} ]]; then
                container_log_line=$(wc -l ${container_log_name} | awk '{print $1}')
            else
                continue
            fi
        fi
        # 将总行数之前的日志输出到待处理日志文件中(保证输出过程中新日志的保留)，删除刚刚的总行数，保留新产生的日志
        mkdir -p ${docker_log_temp_path}
        # sed的方式会改变文件的Inode，导致服务需要重启才能往文件里写日志
        # sed -n "1,${container_log_line}p" ${container_log_name} >> ${docker_log_temp_path}/${container_name}_${log_tar_timestamp}-json.log
        # sed -i "1,${container_log_line}d" ${container_log_name}
        # cp的方式可能会丢失cp和echo之间的日志
        cp ${container_log_name} >> ${docker_log_temp_path}/${container_name}_${log_tar_timestamp}-json.log
        echo -n "" > ${container_log_name}
        # 拼装日志归档名称，将待处理日志文件归档，删除源文件
        tar -zcf ${docker_log_temp_path}/${container_name}_${num:-0}_${log_tar_timestamp}.tar.gz ${docker_log_temp_path}/${container_name}_${log_tar_timestamp}-json.log --remove-files
    done
}


## 切换到数据目录
cd ${docker_var_path}
log_rodate

## 循环开始
#日志类型切换为按size切割
type=size
num=1
while((num < 29));
do
    ## 睡眠时间
    sleep 10
    log_rodate
    ## 自增数
    let num=${num}+1
done

## 拼装oss文件名，上传oss
tar -zcf /tmp/${host_name}_docker_log_${log_tar_timestamp}.tar.gz ${docker_log_temp_path}/*${log_tar_timestamp}.tar.gz --remove-files
yes | aliyun oss cp /tmp/${host_name}_docker_log_${log_tar_timestamp}.tar.gz oss://data-dump/