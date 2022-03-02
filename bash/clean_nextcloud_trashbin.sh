#!/bin/bash
# 清理 nextcloud 回收站的文件
set -eu -o pipefail

# 目录位置
export next_trashbin_path=/home/volume/nextcloud/html/data
# 保留时长，单位: 天(n*24h)
export retain_time=360

function do_cleanup(){
	cd ${next_trashbin_path}

	for next_user in $(ls -1 | grep -Ev "files_external|audit.log|index.html|nextcloud.log*|nohup.out|appdata_*")
	do
		echo "=== $(date +%FT%T.%N) === ${next_user}:clean starting..."
		find ${next_user}/files_trashbin/files/ -mindepth 1 -mtime +${retain_time} -print0 -exec rm -frv {} \;
		echo "=== $(date +%FT%T.%N) === ${next_user}:clean done."
	done
}

do_cleanup >> record-clean_nextcloud_trashbin-$(date +%FT%T).log 2>&1
