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


do_get_system_name (){
    if [[ -f /etc/os-release ]]
    then
        system_version_num=$(awk -F 'VERSION_ID=' '/VERSION_ID=/ {print $2}' /etc/os-release | sed 's/"//g')
    else
        system_version_num=$(awk -F '(' '{print $1}' /etc/system-release | awk '{print $NF}')
    fi
    
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release 2>/dev/null; then
        system_version='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release 2>/dev/null; then
        system_version='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release 2>/dev/null; then
        system_version='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release 2>/dev/null; then
        system_version='Fedora'
        PM='yum'
    elif grep -Eqi "Rocky" /etc/issue || grep -Eq "Rocky" /etc/*-release 2>/dev/null; then
        system_version='Rocky'
        PM='dnf'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release 2>/dev/null; then
        system_version='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release 2>/dev/null; then
        system_version='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release 2>/dev/null; then
        system_version='Raspbian'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release 2>/dev/null; then
        system_version='Mint'
        PM='apt'
    elif grep -Eqi "Kylin" /etc/issue || grep -Eq "Kylin" /etc/*-release 2>/dev/null; then
        system_version='Kylin'
        PM='yum'
    elif grep -Eqi "iSoft" /etc/issue || grep -Eq "iSoft" /etc/*-release 2>/dev/null; then
        system_version='iSoft'
        PM='yum'
    else
        system_version='unknow'
        system_version_num='unknow'
    fi
}

cd $(dirname ${BASH_SOURCE[0]})
# -- 操作系统
# 查看CPU, 命令的结果是当前机器CPU的数量
info_cpu=$(grep -c 'process' /proc/cpuinfo)
# 查看内存, 命令的结果是当前机器内存
info_mem=$(awk '/MemTotal/{printf ("%.2f\n",$2/1024/1024)}' /proc/meminfo)
# 查看硬盘数, 命令的结果是当前机器硬盘数，没有lsblk命令就用fdisk代替
info_disk=$(lsblk --paths --nodeps 2>/dev/null | grep disk || fdisk -l | grep "^Disk /")
# 统计硬盘使用量, 命令的结果是当前机器硬盘使用量
info_disk_used=$(df -h | grep -Pv "tmpfs|overlay|shm|boot|snap|/dev$" | grep "dev")
# 查看内核版本
info_kernel=$(uname --kernel-release)
# 查看主机的硬件架构名称
info_system_machine=$(uname --machine)
# 查看主机操作系统版本, 如果主机操作系统版本是CentOS, 再查询详细版本是多少, 只需要填写详细版本
do_get_system_name
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
# CPU 型号
info_cpu_name=$(cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq | sed 's/^ //g')
# CPU id/序列号
info_cpu_id=$(echo $(${pre_dmidecode} -t processor | grep 'ID' | awk -F ':' '{print $2}' | head -n 1))
# 主板 id/序列号
info_serial_number=$($(${pre_dmidecode} -s system-serial-number)
# info_serial_number=$(echo $(${pre_dmidecode} | grep 'Serial Number' | awk -F ':' '{print $2}' | head -n 1))
# 设备类型
info_product_name=$(${pre_dmidecode} -s system-product-name)

echo """
- CPU(核): ${info_cpu}
- 内存(G): ${info_mem}
- 内核版本: ${info_kernel}
- 硬件架构: ${info_system_machine}
- 操作系统: ${info_system_version}
- 包管理: ${PM} - (${system_version} ${system_version_num})
- IP地址: ${info_ip_address}
- Mac地址: ${info_ip_mac}
- CPU型号: ${info_cpu_name}
- CPU序列号: ${info_cpu_id}
- 主板序列号: ${info_serial_number}
- 设备类型: ${info_product_name}
- 硬盘数: >
${info_disk}

- 硬盘使用: >
${info_disk_used}
"""