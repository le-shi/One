

+ 备份类型:
  - 冷备（cold backup）：需要关mysql服务，读写请求均不允许状态下进行； 
  - 温备（warm backup）： 服务在线，但仅支持读请求，不允许写请求； 
  - 热备（hot backup）：备份的同时，业务不受影响。

  **注：**
    - 1、这种类型的备份，取决于业务的需求，而不是备份工具
    - 2、MyISAM不支持热备，InnoDB支持热备，但是需要专门的工具

+ MySQL主从类型:
  - [一主一从](#一主一从)
  - [主主复制](#主主复制)
  - 一主多从
  - 多主一从(5.7)
  - 级联复制
  - 异步复制
  - 半同步复制

+ 备份策略:
  - 完全备份：full backup，一次备份全部.
  - 增量备份：incremental backup 上次完全备份或增量备份以来改变了的数据，不能单独使用，要借助完全备份，备份的频率取决于数据的更新频率.
  - 差异备份：differential backup 上次完全备份以来改变了的数据.

+ 建议的恢复策略：
  - 完全+增量+二进制日志 
  - 完全+差异+二进制日志

+ rds备份策略: **快照备份+全量物理备份**、**逻辑备份+单库逻辑备份**
+ 全量备份：可以使用mysqldump直接备份整个库或者是备份其中某一个库或者一个库中的某个表
+ 增量备份：增量备份是针对于数据库的bin-log日志进行备份的，需要开始数据库的bin-log日志。增量备份是在全量的基础上进行操作的。增量备份主要是靠mysql记录的bin-log日志。（可以把二进制日志保存成每天的一个文件）
+ [备份shell脚本](#备份shell脚本)
+ [监控项](#监控项)
**注意: 备份期间不要执行DDL操作，避免锁表导致备份失败**

**目标**: binlog备份oss+主备+恢复



### 一主一从
```bash
配置主从: 
# docker准备两个mysql服务，将主库的配置文件增加配置，然后启动服务
# mysql主从的重要属性，要保证主库和从库的server_id不同
server-id = 1
# 开启二进制日志功能
log-bin = log

# 主库操作
## 设置主从账号
grant replication slave on *.* to 'slave'@'%' identified by '123456';
## 刷权限
flush privileges;
## 查看主库状态，记住其中的日志文件和数值
show master status;
## 查看所有用户
SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;
# 备库操作
## 配置主库，注意其中的日志文件和数值要一一对应
CHANGE MASTER TO MASTER_HOST='mysql-master',master_port=3306,MASTER_USER='slave',MASTER_PASSWORD='123456',MASTER_LOG_FILE='log.000003',MASTER_LOG_POS=920;
## 查看slave状态(启动前俩NO, 启动后俩YES)
show slave status \G
## 启动slave
start slave;

# 同步历史数据
1. master开启binlog
2. 锁定：flush tables with read lock;
3. mysqldump导出master全库数据到slave，查出master当前状态并记住logFile和Position位置: mysqldump  -uroot -p --all-databases --routines --flush-privileges --single-transaction >> full_backup.sql; show master status;
4. 解锁：unlock tables;
5. slave配置主从，使用第三步的logFile和Position，启动slave
注意:
1. 先记录binlog位置，再fullbackup --有几率重复数据
2. 先fullbackup，再记录binlog位置 --有几率丢失数据

# 使用binlog恢复(使用binlog恢复基于全量备份)
## 通过pos点
### 先通过master查看binlog
mysql> show binlog events in 'bin.000001';
### 根据Pos点恢复
mysqlbinlog --start-position=154 --stop-position=1000 bin.000001 | mysql -uroot -p
## 通过时间
### 先通过mysqlbinlog查看binlog
mysqlbinlog bin.000001
### 根据时间点恢复
mysqlbinlog --start-datetime="2020-02-17 04:32:51" --stop-datetime="2020-02-17 04:38:54" bin.000001 | mysql -uroot -p
## binlog全量恢复
mysqlbinlog log.000001 | mysql -uroot -p

# 使用nginx配置四层反向代理
场景: 使用nginx模拟内网slb代理多个数据库
需要stream模块
需要放在http模块外面
如果使用docker需要重新挂载nginx.conf
events {
    ...
}
stream {
    upstream my_server {
        server mysql-master:3306;
        server mysql-slave:3306 backup;
    }
    server {
        listen 80;
        proxy_pass my_server;
        # 代理超时时间，默认60s
        proxy_timeout 18000s;
        # 代理连接超时时间，默认10s
        proxy_connect_timeout 2s;
    }
}
http {
    ...
}
```



### 主主复制
```bash
# docker准备两个mysql服务，配置文件增加配置，然后启动服务
# mysql主主的重要属性，要保证主1库和主2库的server_id不同
server-id = 1
# 开启二进制日志功能
log-bin = log
# 数据库只读状态(default: 0关闭)
read-only=0
# 中继日志命名
relay_log=mysql-relay-bin
# 从库更新 binlog 日志 
log-slave-updates=on
# 为了避免两台服务器同时做更新时自增长字段的值之间发生冲突
# 表ID自增列: 确定AUTO_INCREMENT列值的起点，也就是初始值
auto-increment-offset=1
# 表ID自增列: 控制列中的值的增量值，也就是步长
auto-increment-increment=2


# 首先做主1-主2的主从
# 主1库操作
## 进入数据库
docker exec -ti mysql-master-1 mysql -uroot -p
## 设置主从账号
grant replication slave on *.* to 'slave1'@'%' identified by '123456';
## 刷权限
flush privileges;
## 查看主1库状态，记住其中的日志文件和数值
show master status;
## 查看所有用户
SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;
# 主2库操作
## 配置主2库，注意其中的日志文件和数值要一一对应
CHANGE MASTER TO MASTER_HOST='mysql-master-1',master_port=3306,MASTER_USER='slave1',MASTER_PASSWORD='123456',MASTER_LOG_FILE='log.000003',MASTER_LOG_POS=600;
## 查看slave状态(启动前俩NO)
show slave status \G
# 然后做主2-主1的主从
# 主2库操作
## 进入数据库
docker exec -ti mysql-master-2 mysql -uroot -p
## 设置主从账号
grant replication slave on *.* to 'slave2'@'%' identified by '123456';
## 刷权限
flush privileges;
## 查看主2库状态，记住其中的日志文件和数值
show master status;
## 查看所有用户
SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysql.user;
# 主1库操作
## 配置主1库，注意其中的日志文件和数值要一一对应
CHANGE MASTER TO MASTER_HOST='mysql-master-2',master_port=3306,MASTER_USER='slave2',MASTER_PASSWORD='123456',MASTER_LOG_FILE='log.000003',MASTER_LOG_POS=600;
## 查看slave状态(启动前俩NO)
show slave status \G
# 启动同步，分别在主1，主2上执行
start slave;
# 查看状态(启动后两个库分别是俩YES)
show slave status \G
```

### 备份shell脚本
```bash
#!/bin/bash
# 00 00 * * *
# 备份前一天到今天00点的binlog并flush logs
# 通过传不同参数控制脚本执行哪个类型的备份[全备|增量]
# 全备基于mysqldump，增量基于binlog
# 适用于单机、主从、主主
# 支持压缩删源、上传oss、恢复
# mysql容器网络
NETWORK_NAME=mysql_default
# 定义镜像
IMAGE_NAME=mysql:5.7.30
# 定义容器名称
CONTAINER_NAME=mysql-master
# 周一凌晨进行全备
week_one=$(date +%w)
# 时间戳 年-月-日
date_time=$(date +%F)
# mysql数据目录
mysql_volume_path=/root/mysql/volume/mysql/data
# mysql数据备份目录
mysql_volume_bak_path=/root/mysql/volume/mysql/backup
# mysql master password
MYSQL_MASTER_PASSWORD=password

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
    cd ${mysql_volume_bak_path}
    yes | aliyun oss cp full_backup_${date_time}.tar.gz oss://mysqld-binlog
}
# append backup
append_backup(){
    binlog_file=$(docker run --rm -e MYSQL_ROOT_PASSWORD=123456 --network=${NETWORK_NAME} ${IMAGE_NAME} mysql -h ${CONTAINER_NAME} -uroot -p${MYSQL_MASTER_PASSWORD} -e 'show master status \G' | grep "File" | awk '{print $NF}')
    # 刷日志
    docker run --rm -e MYSQL_ROOT_PASSWORD=123456 --network=${NETWORK_NAME} ${IMAGE_NAME} mysql -h ${CONTAINER_NAME} -uroot -p${MYSQL_MASTER_PASSWORD} -e 'flush logs'
    # 将binlog归档压缩
    cd ${mysql_volume_path} && tar -zcf ${mysql_volume_bak_path}/append_backup_${date_time}_${binlog_file}.tar.gz ${binlog_file}
    cd ${mysql_volume_bak_path}
    aliyun oss cp append_backup_${date_time}_${binlog_file}.tar.gz oss://mysqld-binlog
}

action=${1}
case ${action} in
    full) full_backup ;;
    append) append_backup ;;
    *) echo "chooice [full|append]." ;;
esac
```

### 监控项
```yaml
# prometheus 

# mysql_slave_status_slave_io_running
# mysql_slave_status_slave_sql_running

  - alert: mysql_slave_status_slave_io_running
    expr: mysql_slave_status_slave_io_running != 1
    for: 5s
    labels:
      severity: red
      item: db_slave_io
    annotations:
      summary: "mysql master-master"
      description: "Current value: IO"

  - alert: mysql_slave_status_slave_sql_running
    expr: mysql_slave_status_slave_sql_running != 1
    for: 5s
    labels:
      severity: red
      item: db_slave_sql
    annotations:
      summary: "mysql master-master"
      description: "Current value: SQL"


```