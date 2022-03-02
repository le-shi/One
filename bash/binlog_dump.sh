#!/bin/bash
# 00 00 * * *
# 备份前一天到今天00点的binlog并flush logs
# 通过传不同参数控制脚本执行哪个类型的备份[全备|增量]
# 全备基于mysqldump，增量基于binlog
# 适用于单机、主从、主主
# 支持压缩删源、上传oss、恢复
# mysql容器网络
NETWORK_NAME=zbx
# 定义镜像
IMAGE_NAME=mysql:5.7.30
# 定义容器名称
CONTAINER_NAME=mysql-master
# 周一凌晨进行全备
week_one=$(date +%w)
# 时间戳 年-月-日
date_time=$(date +%F)
# mysql数据目录
mysql_volume_path=/mnt/volume/mysql_cluster/data
# mysql数据备份目录
mysql_volume_bak_path=/home/volume/mysql_backup
# mysql master password
MYSQL_MASTER_PASSWORD=123465

# 检查网络是否存在
if [ $(docker network ls | grep -c ${NETWORK_NAME}) == 0 ];then echo "network ${NETWORK_NAME} not exists";  exit;else  echo "network ${NETWORK_NAME} is Ok,waiting...";fi
# 创建备份目录
mkdir -p ${mysql_volume_bak_path}

# full backup
full_backup(){
    # 备份全库
    docker run --rm -e MYSQL_ROOT_PASSWORD=123456 -v ${mysql_volume_bak_path}:/tmp/mysql/ --network=${NETWORK_NAME} ${IMAGE_NAME} mysqldump -h ${CONTAINER_NAME} -uroot -p${MYSQL_MASTER_PASSWORD} --all-databases --flush-logs --routines --flush-privileges --single-transaction >> ${mysql_volume_bak_path}/full_backup_${date_time}.sql
    # 归档压缩处理
    cd ${mysql_volume_bak_path}
    tar -zcf full_backup_${date_time}.tar.gz full_backup_${date_time}.sql --remove-files
    # cd ${mysql_volume_bak_path}
    # yes | aliyun oss cp full_backup_${date_time}.tar.gz oss://mysqld-binlog
}
# append backup
append_backup(){
    binlog_file=$(docker run --rm -e MYSQL_ROOT_PASSWORD=123456 --network=${NETWORK_NAME} ${IMAGE_NAME} mysql -h ${CONTAINER_NAME} -uroot -p${MYSQL_MASTER_PASSWORD} -e 'show master status \G' | grep "File" | awk '{print $NF}')
    # 刷日志
    docker run --rm -e MYSQL_ROOT_PASSWORD=123456 --network=${NETWORK_NAME} ${IMAGE_NAME} mysql -h ${CONTAINER_NAME} -uroot -p${MYSQL_MASTER_PASSWORD} -e 'flush logs'
    # 将binlog归档压缩
    cd ${mysql_volume_path} && tar -zcf ${mysql_volume_bak_path}/append_backup_${date_time}_${binlog_file}.tar.gz ${binlog_file}
    cd ${mysql_volume_bak_path}
    # aliyun oss cp append_backup_${date_time}_${binlog_file}.tar.gz oss://mysqld-binlog
}

action=${1}
case ${action} in
    full) full_backup ;;
    append) append_backup ;;
    *) echo "chooice [full|append]." ;;
esac

