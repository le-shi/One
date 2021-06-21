#!/bin/bash  

export ORACLE_BASE=/data/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin$PATH:$ORACLE_HOME/bin
export ORACLE_SID=orcl
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
# [[ ${NLS_LANG} ]] || export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

export BACK_DIR=/home/oracle/oracle_backup
export BAKUPTIME=`date +%FT%H-%M-%S`
export BACKUP_EXPIRED_DAY=180
mkdir -p $BACK_DIR

do_backup_database(){
    BACK_USER=${1}
    BACK_PASS=${2}
    BACK_FILE_NAME=backup_${BACK_USER}_$BAKUPTIME
    echo "Starting bakup..."
    echo "Bakup file path $BACK_DIR/$BAKUPTIME.dmp"
    exp ${BACK_USER}/${BACK_PASS} file=$BACK_DIR/${BACK_FILE_NAME}.dmp log=$BACK_DIR/${BACK_FILE_NAME}.log

    tar -Pzcf $BACK_DIR/${BACK_FILE_NAME}.tar.gz $BACK_DIR/${BACK_FILE_NAME}.{dmp,log} --remove-files
    echo
    echo "Bakup completed."
    echo
    echo "Delete the file bakup before ${BACKUP_EXPIRED_DAY} days..."
    find $BACK_DIR -mtime +${BACKUP_EXPIRED_DAY} -exec rm -f {} \;
    echo "Delete the file bakup successfully. "
    echo
}

# 任务执行列表
do_backup_database username password


### Cron ###
# 前提: 文件备份目录，用户oracle必须有读写权限，否则无法备份。
# crontab -u oracle -l
# 如需每天定时备份，可参考(每天凌晨3点00分进行备份)：
# 00 3 * * * /home/oracle/backupOracle.sh
# 如需每天备份多次，可设置不同时间段备份(每天3点、13点、18点的00分进行备份)：
# 00 3,13,18 * * * /home/oracle/backupOracle.sh
### Cron ###

### A long-distance backup ###
# rsync -az ${BACK_DIR} user@ip:/path/to/backup
### A long-distance backup ###