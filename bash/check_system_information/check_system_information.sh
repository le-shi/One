#!/bin/bash

# 使用root用户执行
if [[ $USER == "root" ]];then
  :
  #root用户建普通用户
else
  echo "Do so using root."
  exit 1
fi

cd $(dirname ${BASH_SOURCE[0]})
# -- 操作系统
# 查看CPU, 命令的结果是当前机器CPU的数量
info_cpu=$(grep -c 'process' /proc/cpuinfo)
# 查看内存, 命令的结果是当前机器内存
info_mem=$(awk '/MemTotal/{printf ("%.2f\n",$2/1024/1024)}' /proc/meminfo)
# 查看硬盘数, 命令的结果是当前机器硬盘数
info_disk=$(lsblk -a | grep disk)
# 统计硬盘使用量, 命令的结果是当前机器硬盘使用量
info_disk_used=$(df -h | grep -Pv "tmpfs|overlay|shm|boot|snap" | grep dev)
# 查看内核版本
info_kernel=$(uname --kernel-release)
# 查看主机的硬件架构名称
info_system_machine=$(uname --machine)
# 查看主机操作系统版本, 如果主机操作系统版本是CentOS, 再查询详细版本是多少, 只需要填写详细版本
info_system_version=$(grep -i 'PRETTY_NAME' /etc/*release | awk -F '=' '{print $2}' | sed 's/"//g')
if [[ $(echo ${info_system_version} | grep -i 'centos') ]];then
    info_system_version=$(cat /etc/redhat-release)
fi
# IP地址
info_ip_address=$(hostname --all-ip-address)
# Mac地址
info_ip_mac=$(for i in ${info_ip_address[@]}; do ip a | grep "$i" -B 1 | grep link | awk '{print $2}'; done)
info_ip_mac=$(echo ${info_ip_mac} | sed 's/\n/ /g')
case ${info_system_machine} in
  aarch64) dmidecode=dmidecode-aarch64
  ;;
  x86_64) dmidecode=dmidecode-amd64
  ;;
esac
# CPU id/序列号
info_cpu_id=$(echo $(./${dmidecode} -t processor | grep 'ID' | awk -F ':' '{print $2}' | head -n 1))
# 主板 id/序列号
info_serial_number=$(echo $(./${dmidecode} | grep 'Serial Number' | awk -F ':' '{print $2}' | head -n 1))

echo """
- CPU(核): ${info_cpu}
- 内存(G): ${info_mem}
- 内核版本: ${info_kernel}
- 硬件架构: ${info_system_machine}
- 操作系统: ${info_system_version}
- IP地址: ${info_ip_address}
- Mac地址: ${info_ip_mac}
- CPU序列号: ${info_cpu_id}
- 主板序列号: ${info_serial_number}
- 硬盘数: >
${info_disk}

- 硬盘使用: >
${info_disk_used}
"""