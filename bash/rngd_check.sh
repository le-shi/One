#!/bin/bash
set -xue
set -o pipefail
# 查看熵池大小，如果结果小于3000需要安装熵池服务扩展
entropy_avail=$(cat /proc/sys/kernel/random/entropy_avail)
if [[ ${entropy_avail} -lt 3000 ]];then
    echo "Begin Installing..."
    # 一般情况下，以上两种情况会同时存在
    # 安装熵池服务扩展(使用root用户)
    yum install -y -q rng-tools
    if [[ $? -eq 0 ]];then
        systemctl start rngd
        systemctl enable rngd
        new_entropy_avail=$(cat /proc/sys/kernel/random/entropy_avail)
        echo "Install Success"
    else
        echo "Install Error.[$?]"
    fi
else
    echo "${entropy_avail}, OK"
fi