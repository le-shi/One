#!/bin/bash
# nc -z -v [-u] ip port [tcp or -|udp] name

# Next
# ser: 所有的服务
# host: 所有的虚拟机
# all-host: 所有的虚拟机和物理机
# all: 所有的虚拟机和物理机和服务

tcp_hint=0
http_hint=0
success_count=0
error_count=0
reset=$(tput sgr0)
red=$(tput setaf 1)
green=$(tput setaf 76)

success() { 
    let success_count++
    printf "${green}✔ %s${reset}\n" "$@"
}
error() { 
    let error_count++
    printf "${red}✖ %s${reset}\n" "$@"
}
# tcp/udp:: nc测试端口开放性，不能作为可用性的判断依据
do_check_nc() {
    # Use: do_check_nc ip port [tcp or -|udp] name
    IP=${1}
    PORT=${2}
    TYPE=${3}
    NAME=${4}
    
    # 追求格式统一
    # expr length ${NAME} OR ${#NAME} --计算变量长度
    if [[ $(expr length ${NAME}) -gt 14 ]]
    then
        local tbl="\t"
    elif [[ ${#NAME} -gt 6 ]]
    then
        local tbl="\t\t"
    else
        local tbl="\t\t\t"
    fi
    echo -ne "${NAME} ${tbl}"
    # 校验tcp or udp
    case ${TYPE} in
        udp)
        MSG=$(nc -w 3 -z -v -u ${IP} ${PORT} 2>&1)
        ;;
        tcp|-)
        MSG=$(nc -w 3 -z -v ${IP} ${PORT} 2>&1)
        ;;
    esac
    [[ $? == 0 ]] && success "${MSG}" || error "${MSG}"
    let tcp_hint++
}
# http:: 服务可用性
do_check_curl(){
    # curl -I update.zbxsoft.com:7563/file/install/install-base.tar.gz
    echo
}
# exit_action
do_exit_action(){
    trap SIGQUIT SIGKILL
    # 没有失败的探针，error_count输出为自定义字符
    if [[ ${error_count} == 0 ]]
    then
        error_count="-"
    else
        error_count="${red}${error_count}${reset}"
    fi
    printf "\nnc-Test Sum: ${green}${tcp_hint}${reset}, Success Count: ${green}${success_count}${reset}, Error Count: ${error_count}\n"
    printf "The success rate: "; awk 'BEGIN{printf "%.1f%%\n",('${success_count}'/'${tcp_hint}')*100}'
}


do_check_nc baidu.com 80 tcp baidu_web
do_check_nc baidu.com 80 - baidu_web
do_check_nc 0.asia.pool.ntp.org 80 udp ntp_server

# exit_action
do_exit_action

echo "3秒后自动退出..."
sleep 3