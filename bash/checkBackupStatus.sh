#!/bin/bash
set -eu -o pipefail
# 备份机检查策略: 通过文件的变更时间确定备份状态

root_path=/home/volume/nextcloud/html/data

do_check_files_update_backup(){
    echo
    echo '[BEGIN] Find Begin Time: '$(date +%F_%T -d "-${time_number} ${data_time_type}") +++ Time Range: [${time_number} ${data_time_type}]
    echo "--- --- ---"
    
    dst_path=${1}
    sync_frequency=${2}
    sync_node_frequency=${3}
    title=$(echo ${dst_path} | awk -F '/' '{print $(NF-1)}')
    flag=$(echo ${dst_path} | awk -F '/' '{print $NF}')
    echo "环境: ${title} 目标: ${flag} +++ 同步: ${sync_frequency} +++ 机器备份: ${sync_node_frequency}"
    # 将文件数信息存到文件里
    find ${root_path}/${dst_path} -m${time_type} -${time_number} -type f -exec ls -lh {} \; > /tmp/do_check_files_update_backup_${title}_${flag}.temp 2>&1
    echo "The file number: $(wc -l /tmp/do_check_files_update_backup_${title}_${flag}.temp | awk '{print $1}')"
    cat /tmp/do_check_files_update_backup_${title}_${flag}.temp
    echo
    echo '[END] Find End Time: '$(date +%F_%T)
    echo
}

time_number=${1}
time_type=${2}
case ${time_type} in
  day|d)
  data_time_type=days
  time_type=time
  ;;
  *)
  data_time_type=min
  time_type=min
  time_number=${time_number:-120}
  ;;
esac

main(){
# 检测网站备份
# do_check_files_update_backup 账号名称/files/目录名称/ "备份频率" "备份内容"

}


record_log=record_check_backup_$(date +%FT%H-%M-%S)_for_last_${time_number}_${data_time_type}.log

echo -en """Check record is being saved to "${record_log}"\nPlease wait..."""
main > ${record_log}
rm -rf /tmp/do_check_files_update_backup_*.temp
echo 'Done.'
