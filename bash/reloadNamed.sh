#!/bin/bash

# 修改zone文件后，一键重启 named(主DNS) 服务让dns记录生效并通知从DNS(在不检查序列号的情况下重新传输单个区域)更新变更记录
# Usage:
# ./reloadNamed.sh baidu.com

domain_name=${1}
domain_file=/var/named/${domain_name}.zone

if [[ -z ${domain_name} ]]
then
  echo
  echo "[WARN] Please Input Domain Name."
  echo
  exit 1
fi

# 判断文件存在
if [[ -f ${domain_file} ]]
then
  echo
  echo "[INFO] Checking Named zone..."
  echo
else
  echo
  echo "[ERROR] file not exists: ${domain_file}"
  echo
  exit 2
fi

# 检查语法
named-checkzone ${domain_name} ${domain_file}
if [[ $? == 0 ]]
then
  # 语法正确，执行重启
  echo
  echo "[INFO] Restarting Named..."
  echo
  service named restart
  echo
  echo "[INFO] Done."
else
  # 语法错误，提示并退出
  echo
  echo "[ERROR] named zone [${domain_name}] check the failure: ${domain_file}"
  echo
  exit 3
fi

# 前提: 需要主->从的ssh免密
# 适用于不改变 serial number 的情况下，手动让从DNS更新；反之，从DNS会自动更新
# ssh 从DNS_IP "rndc retransfer ${domain_name}"
