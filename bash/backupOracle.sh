#!/bin/bash  

export ORACLE_BASE=/data/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin$PATH:$ORACLE_HOME/bin
export ORACLE_SID=orcl
[[ ${NLS_LANG} ]] || export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

export BACK_DIR=/home/oracle/back
export BAKUPTIME=`date +%F_%H%M%S`
mkdir -p $BACK_DIR

echo "Starting bakup..."
echo "Bakup file path $BACK_DIR/$BAKUPTIME.dmp"  
exp username/password file=$BACK_DIR/back_$BAKUPTIME.dmp log=$BACK_DIR/back_$BAKUPTIME.log

tar -Pzcf $BACK_DIR/back_$BAKUPTIME.dmp.tar.gz $BACK_DIR/back_$BAKUPTIME.{dmp,log} --remove-files

echo "Delete the file bakup before 90 days..."
#find $BACK_DIR -mtime +90 -exec rm -rf {} \;
echo "Delete the file bakup successfully. "

echo "Bakup completed."

rsync -az $BACK_DIR/back_$BAKUPTIME.dmp.tar.gz root@192.168.220.30:/home/volume/nextcloud/html/data/caiwu/u8/oracle_dmp/
###
#crontab -u oracle -e
#* 3 * * * /home/oracle/backupOracle.sh
#即每天凌晨3点进行备份
#如需每天备份多次，可设置不同时间段备份：
#例如：* 3,13,18 * * * /home/bakup/backupOracle.sh，即每天3点、13点、18点进行备份。
#说明：文件备份目录，用户oracle必须有更改权限，否则无法备份。
