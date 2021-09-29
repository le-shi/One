#!/bin/bash
# 支持 Centos7.x RadHat5.x,6.x Mint20.x Ubuntu20.x,18.x

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
# 查看硬盘数, 命令的结果是当前机器硬盘数，没有lsblk命令就用fdisk代替
info_disk=$(lsblk -a 2>/dev/null | grep disk || fdisk -l | grep "^Disk")
# 统计硬盘使用量, 命令的结果是当前机器硬盘使用量
info_disk_used=$(df -h | grep -Pv "tmpfs|overlay|shm|boot|snap" | grep dev)
# 查看内核版本
info_kernel=$(uname --kernel-release)
# 查看主机的硬件架构名称
info_system_machine=$(uname --machine)
# 查看主机操作系统版本, 如果主机操作系统版本是CentOS, 再查询详细版本是多少, 只需要填写详细版本
info_system_version=$(grep -i 'PRETTY_NAME' /etc/*release 2>/dev/null | awk -F '=' '{print $2}' | sed 's/"//g')
if [[ $(echo ${info_system_version} | grep -i 'centos') || -e /etc/redhat-release ]];then
    info_system_version=$(cat /etc/redhat-release)
elif [[ -e /etc/system-release ]];then
    info_system_version=$(cat /etc/system-release)    
fi
# 获取IP地址，如果hostname不支持--all-ip-address参数(例如: 红帽6.5)，就使用ip命令
info_ip_address=$(hostname --all-ip-address 2>/dev/null || ip a | grep -w inet | grep -v 127.0.0.1 | cut -d '/' -f1 | sed -e 's/inet//g' -e "s/ //g" | tr "\n" " ")
# 获取Mac地址
info_ip_mac=$(for i in ${info_ip_address[@]}; do ip a | grep "$i" -B 1 | grep link | awk '{print $2}'; done)
info_ip_mac=$(echo ${info_ip_mac} | sed 's/\n/ /g')
# 检查系统有没有安装 dmidecode
if [[ $(type dmidecode 2>/dev/null) ]];
then
   # 如果已经安装，使用已安装的
   pre_dmidecode=$(type dmidecode | cut -d '(' -f2 | sed 's/)//')
else
  # 如果没有安装，使用静态的
  case ${info_system_machine} in
    aarch64) pre_dmidecode=./dmidecode-aarch64
    ;;
    x86_64) pre_dmidecode=./dmidecode-amd64
    ;;
  esac
fi
# CPU id/序列号
info_cpu_id=$(echo $(${pre_dmidecode} -t processor | grep 'ID' | awk -F ':' '{print $2}' | head -n 1))
# 主板 id/序列号
info_serial_number=$(echo $(${pre_dmidecode} | grep 'Serial Number' | awk -F ':' '{print $2}' | head -n 1))

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