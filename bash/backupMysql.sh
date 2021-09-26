#!/bin/bash
# 定义备份时间
DUMP_DAY=$(date +%F_%H_%M_%S)
DUMP_TIME=${DUMP_DAY}
# 定义网络名称
NETWORK_NAME=db_network
# 定义镜像
IMAGE_NAME=mysql:5.7.34
# 定义容器名称
CONTAINER_NAME=(mysql)
# 定义备份数据库的密码
CONTAINER_MYSQL_ROOT_PASSWORD=5tgb^YHN
# 定义保存目录路径
DUMP_DIRECTORY=/home/volume/mysql/backup
# 定义脚本文件路径
DUMP_SHELL=/tmp/dump.sh
# 定义本地备份历史保留时长(天)
BACKUP_KEEP_DAY=180
# 定义备份命令
## --single-transaction 此选项将事务隔离模式设置为， REPEATABLE READ并START TRANSACTION在转储数据之前将SQL语句发送到服务器。它仅对诸如之类的事务表很有用InnoDB，因为这样，它在START TRANSACTION发布时就转储数据库的一致状态， 而不会阻塞任何应用程序。该--single-transaction选项和该 --lock-tables选项是互斥的
## --quick 此选项对于转储大型表很有用
## --hex-blob 使用十六进制表示法转储二进制列（例如， 'abc'变为 0x616263）。受影响的数据类型是 BINARY， VARBINARY， BLOB类型， BIT所有的空间数据类型，和其他非二进制数据类型与使用时 binary 的字符集
## --no-data 不要写任何表行信息（即，不要转储表内容）。如果只想转储CREATE TABLE表的语句（例如，通过加载转储文件来创建表的空副本），这将很有用
## --compact 产生更紧凑的输出
## --compatible=name 产生与其他数据库系统或更旧的MySQL服务器更兼容的输出. 值name可以是 ansi，mysql323， mysql40，postgresql， oracle，mssql， db2，maxdb， no_key_options， no_table_options，或 no_field_options。要使用多个值，请用逗号分隔。 此选项不保证与其他服务器的兼容性。它仅启用当前可用于使转储输出更兼容的那些SQL模式值。例如，--compatible=oracle不将数据类型映射到Oracle类型或不使用Oracle注释语法。
COMMON_DUMP_CMD="/usr/bin/mysqldump -uroot -p\"${CONTAINER_MYSQL_ROOT_PASSWORD}\" --skip-lock-tables --hex-blob"

# 检查网络是否存在
if [ $(docker network ls | grep -c ${NETWORK_NAME}) == 0 ];then echo "network ${NETWORK_NAME} not exists";  exit;else  echo "network ${NETWORK_NAME} is Ok, In backup...";fi

# 检查目录是否存在
[ -d ${DUMP_DIRECTORY}/${DUMP_DAY} ] || mkdir -p ${DUMP_DIRECTORY}/${DUMP_DAY}
echo
echo "Backup Directory: ${DUMP_DIRECTORY}/${DUMP_DAY}"
[ -d ${DUMP_SHELL} ] && rmdir ${DUMP_SHELL}
echo -n "" > ${DUMP_SHELL}

# 索引数据库名称，过滤的库("Database|sys|mysql|information_schema|performance_schema|test|dict")
DATABASE_NAME=($(docker run --rm -e MYSQL_ROOT_PASSWORD=123456 -v ${DUMP_DIRECTORY}/${DUMP_DAY}/:/tmp/mysql/ -v ${DUMP_SHELL}:/tmp/dump.sh --network=${NETWORK_NAME} --name dump_mysql ${IMAGE_NAME} mysql -h ${CONTAINER_NAME} -uroot -p"${CONTAINER_MYSQL_ROOT_PASSWORD}" -e "show databases;" 2> /dev/null | grep -Ewv "Database|sys|mysql|information_schema|performance_schema|test"))

# 定义导出库方法
dumpDatabase (){
  ACTION=${1}
  case ${ACTION} in
    # 备份指定数据库数据
    dump)
      echo "Dump: ${da_name}"
      echo "${COMMON_DUMP_CMD} -h ${co_name} ${da_name} > /tmp/mysql/${da_name}_${DUMP_TIME}.sql" >> ${DUMP_SHELL}
    ;;
    # 备份指定数据库表结构
    database)
      echo "Database: ${da_name}"
      echo "${COMMON_DUMP_CMD} -h ${co_name} --no-data ${da_name} > /tmp/mysql/${da_name}_${DUMP_TIME}.txt" >> ${DUMP_SHELL}
    ;;
    *) :;;
  esac
}

echo -n "" > ${DUMP_SHELL}
chmod +x ${DUMP_SHELL}
for co_name in ${CONTAINER_NAME[@]}
do
  for da_name in ${DATABASE_NAME[@]}
  do
#    echo "/usr/bin/mysqldump -h ${co_name} -uroot -p"${CONTAINER_MYSQL_ROOT_PASSWORD}" ${da_name} > /tmp/mysql/${da_name}_${DUMP_TIME}.sql" >> ${DUMP_SHELL}
     dumpDatabase dump
     dumpDatabase database
  done
done

# 统计磁盘使用, 如果使用空间超过80%, 本地将保留最近7天的备份；如果设置的值小于7，会略过当前操作
if [[ ${BACKUP_KEEP_DAY} -gt 7 ]]
then
  dump_dir_used=$(df ${DUMP_DIRECTORY} --output=pcent | tail -n 1 | awk -F '%' '{print $1}' | sed 's/ //g')

  if [[ ${dump_dir_used} -gt 80 ]]
  then
    BACKUP_KEEP_DAY=7
  fi
fi

find ${DUMP_DIRECTORY}/ -mtime +${BACKUP_KEEP_DAY} -exec rm -f {} \;
res1=$?
# 执行备份命令
echo "Dump doing..."
docker run --rm -e MYSQL_ROOT_PASSWORD=123456 -v ${DUMP_DIRECTORY}/${DUMP_DAY}/:/tmp/mysql/ -v ${DUMP_SHELL}:/tmp/dump.sh --network=${NETWORK_NAME} --name dump_mysql ${IMAGE_NAME}  ./tmp/dump.sh 2>/dev/null
res2=$?
# # 清理空目录
# find ${DUMP_DIRECTORY}/ -type d -size 6c -exec rmdir {} \;
if [ ${res1} == 0 -a ${res2} == 0 ];then
  echo 
  cd ${DUMP_DIRECTORY}
  set -x
  tar -zcf ${DUMP_DAY}.tar.gz ${DUMP_DAY} --remove-files
  set +x
  echo "Done."
fi

### Cron ###
# 00 00 * * * /home/files/backupMysql.sh
### Cron ###

### A long-distance backup ###
# rsync -az ${DUMP_DIRECTORY} user@ip:/path/to/backup
### A long-distance backup ###
