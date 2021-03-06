#!/bin/bash
set -e
# Centos 7.x
# Usage: ./script.sh or ./script.sh [Options]
# default install docker, docker-compose, docker swarm network, templates, zbxUI
# Options:
#   clean   清理docker, docker-compose, docker swarm network, docker image, docker container, 为了安全着想，不会清理数据目录

#
# Set Colors
#

bold=$(tput bold)
underline=$(tput sgr 0 1)
reset=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 76)
white=$(tput setaf 7)
tan=$(tput setaf 202)
blue=$(tput setaf 25)

#
# Headers and Logging
#

underline() { printf "${underline}${bold}%s${reset}\n" "$@"
}
h1() { printf "\n${underline}${bold}${blue}%s${reset}\n" "$@"
}
h2() { printf "\n${underline}${bold}${white}%s${reset}\n" "$@"
}
debug() { printf "${white}%s${reset}\n" "$@"
}
info() { printf "${white}➜ %s${reset}\n" "$@"
}
info_un() { printf "${white}➜ %s${reset}" "$@"
}
info_un2() { printf "${white}%s${reset}" "$@"
}
info_nu() { printf "${green}%s${reset}\n" "$@"
}
info_nu2() { printf "${green}%s${reset}" "$@"
}
info_rnu() { printf "${red}%s${reset}\n" "$@"
}
success() { printf "${green}✔ %s${reset}\n" "$@"
}
error() { printf "${red}✖ %s${reset}\n" "$@"
}
warn() { printf "${tan}➜ %s${reset}\n" "$@"
}
bold() { printf "${bold}%s${reset}\n" "$@"
}
note() { printf "\n${underline}${bold}${blue}Note:${reset} ${blue}%s${reset}\n" "$@"
}

wgetSet(){
  wget -Nc -nv -t 3 ${@}
  # wget --timestamping --continue  --no-verbose --tries=3 ${1}
}


do_system_optimize(){
    # selinux、firewalld、ipv4转发、tcp端口范围、系统,用户,进程文件打开数、tcp接收(发送)缓存区大小、单进程VMA限制
    # [job name] exp: ev, cur: cv, res: success
    ## selinux
    info_un "[selinux] exp: Disabled, "
    selinux_status=$(getenforce 2>/dev/null)
    info_un2 "cur: ${selinux_status:--}, res: "
    if [[ ${selinux_status} == "Enforcing" ]]
    then
        setenforce 0
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
        [[ $? == 0 ]] && info_nu "success"
    elif [[ ${selinux_status} == "Disabled" ]]
    then
        info_nu "It is expected, not modified"
    else
        info_nu "selinux not found!"
    fi

    ## firewalld
    info_un "[firewalld] exp: inactive, "
    firewalld_status=$(systemctl is-active firewalld || true)
    info_un2 "cur: ${firewalld_status}, res: "
    if [[ ${firewalld_status} == "active" ]] 
    then
        systemctl stop firewalld
        [[ $? == 0 ]] && info_nu "success"
        if [[ $(systemctl is-enabled firewalld) == "enabled" ]]
        then
            systemctl disable firewalld
        fi
    elif [[ ${firewalld_status} == "inactive" ]]
    then
        info_nu "It is expected, not modified"
    elif [[ ${firewalld_status} == "unknown" ]]
    then
        info_nu "firewalld service not installed"
    fi

    ## 开启ipv4转发 as /proc/sys/net/ipv4/ip_forward
    info_un "[net.ipv4.ip_forward] exp: 1, "
    net_ipv4_ip_forward_status=$(sysctl -n net.ipv4.ip_forward)
    info_un2 "cur: ${net_ipv4_ip_forward_status}, res: "
    if [[ ${net_ipv4_ip_forward_status} == 0 ]]
    then
        sysctl -w -q net.ipv4.ip_forward=1
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## 调整tcp端口打开范围 as /proc/sys/net/ipv4/ip_local_port_range
    info_un "[net.ipv4.ip_local_port_range] exp: 1024 65535, "
    net_ipv4_ip_local_port_range=$(sysctl -n net.ipv4.ip_local_port_range)
    net_ipv4_ip_local_port_range=$(echo ${net_ipv4_ip_local_port_range} | tr "\t" " ")
    info_un2 "cur: ${net_ipv4_ip_local_port_range}, res: "
    if [[ "${net_ipv4_ip_local_port_range}" != "1024 65535" ]]
    then
        sysctl -w -q net.ipv4.ip_local_port_range="1024 65535"
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## 调整系统可打开文件的最大数量 as /proc/sys/fs/file-max
    info_un "[fs.file-max] exp: 65536, "
    fs_file_max=$(sysctl -n fs.file-max)
    info_un2 "cur: ${fs_file_max}, res: "
    if [[ "${fs_file_max}" -lt 65536 ]]
    then
        sysctl -w -q fs.file-max=65536
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## 调整用户可打开文件的最大数量: ulimit -n
    info_un "[ulimit -n] exp: 65535, "
    ulimit_n_status=$(ulimit -n)
    info_un2 "cur: ${ulimit_n_status}, res: "
    if [[ ${ulimit_n_status} -lt 65535 ]]
    then
        if [[ $(grep -Pc "\* soft nofile 65535|\* hard nofile 65535" /etc/security/limits.conf) -lt 2 ]]
        then
            sed -i '$i* soft nofile 65535\n* hard nofile 65535' /etc/security/limits.conf
            [[ $? == 0 ]] && info_nu2 "success, "
        fi
        info_nu "Reconnect to SSH and automatically load the ulimit"
    else
        info_nu "It is expected, not modified"
    fi

    ## 调整单个进程可打开文件的最大数量: /proc/sys/fs/nr_open
    info_un "[fs.nr_open] exp: 65536, "
    fs_file_max=$(sysctl -n fs.nr_open)
    info_un2 "cur: ${fs_file_max}, res: "
    if [[ "${fs_file_max}" -lt 65536 ]]
    then
        sysctl -w -q fs.nr_open=65536
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## tcp接收缓存区大小,缓存从对端接收的数据,后续会被应用程序读取,单位是字节 as /proc/sys/net/ipv4/tcp_rmem
    ### 最小(默认4K) 默认(默认87380字节) 最大(不会覆盖net.core.rmem_max)
    info_un "[net.ipv4.tcp_rmem] exp: 4096 87380 6291456, "
    net_ipv4_tcp_rmem=$(sysctl -n net.ipv4.tcp_rmem)
    net_ipv4_tcp_rmem=$(echo ${net_ipv4_tcp_rmem} | tr "\t" " ")
    info_un2 "cur: ${net_ipv4_tcp_rmem}, res: "
    if [[ "${net_ipv4_tcp_rmem}" != "4096 87380 6291456" ]]
    then
        sysctl -w -q net.ipv4.tcp_rmem="4096 87380 6291456"
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## tcp发送缓存区大小,缓存应用程序的数据,有序列号被应答确认的数据会从发送缓冲区删除掉,单位是字节 as /proc/sys/net/ipv4/tcp_wmem
    ### 最小(默认4K) 默认(最大16K,自动调整) 最大(不会覆盖net.core.wmem_max)
    info_un "[net.ipv4.tcp_wmem] exp: 4096 16384 4194304, "
    net_ipv4_tcp_wmem=$(sysctl -n net.ipv4.tcp_wmem)
    net_ipv4_tcp_wmem=$(echo ${net_ipv4_tcp_wmem} | tr "\t" " ")
    info_un2 "cur: ${net_ipv4_tcp_wmem}, res: "
    if [[ "${net_ipv4_tcp_wmem}" != "4096 16384 4194304" ]]
    then
        sysctl -w -q net.ipv4.tcp_wmem="4096 16384 4194304"
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

    ## 单进程VMA限制 as /proc/sys/vm/max_map_count
    info_un "[vm.max_map_count] exp: 262144, "
    vm_max_map_count=$(sysctl -n vm.max_map_count)
    info_un2 "cur: ${vm_max_map_count}, res: "
    if [[ "${vm_max_map_count}" -lt 262144 ]]
    then
        sysctl -w -q vm.max_map_count=262144
        [[ $? == 0 ]] && info_nu "success"
    else
        info_nu "It is expected, not modified"
    fi

}

# do_system_optimize