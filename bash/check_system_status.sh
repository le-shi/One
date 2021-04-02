#!/bin/bash

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

# 比如cpu、内存、硬盘、线程
cd $(dirname ${BASH_SOURCE[0]})
# -- 操作系统
# 查看CPU, 命令的结果是当前机器CPU的数量
info_cpu=$(grep -c 'process' /proc/cpuinfo)
# 查看CPU使用
info_cpu_used=$(top -n 1 | grep -v grep | grep -- "%Cpu(s)" | awk '{print $2}')
# 查看内存, 命令的结果是当前机器内存
info_mem=$(awk '/MemTotal/{printf ("%.2f\n",$2/1024/1024)}' /proc/meminfo)
# 查看内存使用
info_mem_used=$(free -m | sed -n '2p' | awk '{printf ("%.2f%\n",$3/$2*100)}')
# 查看硬盘数, 命令的结果是当前机器硬盘数
info_disk=$(lsblk -a | grep disk)
# 统计硬盘使用量, 命令的结果是当前机器硬盘使用量
info_disk_used=$(df -Ph | grep -Pv "tmpfs|overlay|shm|boot|snap|^udev")
# 统计硬盘inode使用量
info_disk_inode_used=$(df -Pi | grep -Pv "tmpfs|overlay|shm|boot|snap|^udev")
# IP地址
info_ip_address=$(hostname --all-ip-address)
# Linux进程统计 - 当前用户最大进程上限
info_current_user_processes_limit=$(ulimit -u)
# Linux进程统计 - 当前用户打开的进程
info_current_user_processes_open=$(ps -ef | grep ${USER} | grep -v grep | wc -l)
# 内网网络通信 - 见最下面输出
# 网络带宽情况 rx入 tx出
echo "$(date +%FT%T) [INFO] Network R/T Info ..."
do_count_net(){
    max=10
    info_net_rx_old=$(cat /proc/net/dev | grep -Ev "^veth|docker|lo|Receive|packets|virb|wlp|enp|team|-|vxlan" | awk '{print $2}')
    info_net_tx_old=$(cat /proc/net/dev | grep -Ev "^veth|docker|lo|Receive|packets|virb|wlp|enp|team|-|vxlan" | awk '{print $10}')
    for int in $(seq 1 ${max})
    do
        sleep 1
        info_net_rx_new=$(cat /proc/net/dev | grep -Ev "^veth|docker|lo|Receive|packets|virb|wlp|enp|team|-|vxlan" | awk '{print $2}')
        info_net_tx_new=$(cat /proc/net/dev | grep -Ev "^veth|docker|lo|Receive|packets|virb|wlp|enp|team|-|vxlan" | awk '{print $10}')
        if [[ ${int} -ge 10 ]];then
            echo -e "\t[${int}/${max}] \t入: $(echo "${info_net_rx_new} ${info_net_rx_old}" | awk '{printf $1-$2}') \t\t\t\t出: $(echo "${info_net_tx_new} ${info_net_tx_old}" | awk '{printf $1-$2}')"
        else
            echo -e "\t[${int}/${max}] \t\t入: $(echo "${info_net_rx_new} ${info_net_rx_old}" | awk '{printf $1-$2}') \t\t\t\t出: $(echo "${info_net_tx_new} ${info_net_tx_old}" | awk '{printf $1-$2}')"
        fi
        info_net_rx_old=${info_net_rx_new}
        info_net_tx_old=${info_net_tx_new}
    done
}

# jvm内存使用状态、kill -3
echo "$(date +%FT%T) [INFO] Jvm Info ..."
do_jvm_action(){
    # Jdk路径 服务 1
    # 线程 BLOCKED RUNNABLE 数量 1
    # gc平均(总)耗时 1
    # 堆 内存当前大小，最大值 1
    # class zbxsoft 内存 top10
    # jstack  > _2021-02-03.dump
    info_jvm_list=($(jps -lv | grep -v Jps | awk -F '-D' '{print $(NF-2)}' | awk -F '/' '{print $NF}'))
    echo -e "\tRunning [${#info_jvm_list[*]}]\n"
    # info_jvm_dir_list=$(jps -lv | grep -v Jps | awk -F '-D' '{print $(NF-2)}' | awk -F '=' '{print $2}')
    for jvm in ${info_jvm_list[@]};
    do
        jdk=$(ps -ef | grep java | grep ${jvm}/conf | grep -v grep | awk '{print $8}')
        jvm_pid=$(ps -ef | grep java | grep ${jvm}/conf | grep -v grep | awk '{print $2}')
        thread_runn=$(jstack ${jvm_pid} | grep -c RUNNABLE)
        thread_block=$(jstack ${jvm_pid} | grep -c BLOCKED)
        gc_time=$(jstat -gcutil ${jvm_pid} 2>/dev/null | tail -n 1 | awk '{print $NF}')
        heap_memory_max=$(jstat -gccapacity ${jvm_pid} 2>/dev/null | tail -n 1 | awk '{printf ($2+$8)/1024"MB"}')
        heap_memory_current=$(jstat -gc ${jvm_pid} 2>/dev/null | tail -n 1 | awk '{printf ($6+$8)/1024"MB"}')
        heap_thread=$(jstack ${jvm_pid} 2>/dev/null | grep -c thread)
        echo -e "\t服务名/Service: \t\t${jvm} \n\tJava/Jdk: \t\t\t${jdk} \n\t线程/Thread: \t\t\t活跃的/Active: ${heap_thread} \n\t\t\t\t\t\t\t\t\tzbxsoft: RUNNABLE[${thread_runn}] BLOCKED[${thread_block}] \n\tGc时长/GcTime: \t\t\t${gc_time}秒 \n\t堆内存/HeapMem: \t\t最大/Max: ${heap_memory_max} \t当前/Current: ${heap_memory_current}\n\n"
        jstack ${jvm_pid} 2>/dev/null > ${jvm}_$(date +%F).dump
    done
}

echo "$(date +%FT%T) [INFO] Jvm Dir Size ..."
do_check_jvm_dir(){
    info_jvm_dir_list=$(jps -lv | grep -v Jps | awk -F '-D' '{print $(NF-2)}' | awk -F '=' '{print $2}')
    for jvm_dir in ${info_jvm_dir_list[@]};
    do
        info_logs_dir_size=$jvm_dir/logs
        # 日志目录大小
        echo -e "\t$(du -sh ${info_logs_dir_size})"
        # # 日志文件最大的前三名
        # echo -e "\t日志文件最大的前三名"
        # dir_size="$(ls -1hSs ${info_logs_dir_size} | head | tail -n 9 | head -n 3)"
        # echo -e "\t${dir_size}"
        # echo
    done
}

do_check_top_jvm_pid(){
    # top 找出cpu最高的pid
    jvm_process=$(top -bi -n 1 | sed -n '7,12'p | awk '{print $1,$9,$NF}' | sed -n '2'p | grep java)
    if [[ -n ${jvm_process} ]];then
        jvm_pid=$(echo ${jvm_process} | awk '{print $1}')
        jvm_cpu=$(echo ${jvm_process} | awk '{print $2}')
        java_name=$(jps -lv | grep -v Jps | grep -w ${jvm_pid} | awk -F '-D' '{print $(NF-2)}' | awk -F '/' '{print $NF}')
        pid_log=${jvm_pid}.log

        echo -e "\tName: ${java_name}, Pid: ${jvm_pid}, Cpu: ${jvm_cpu}, PidLog: ${pid_log}"
        # top -Hp <pid>看最高的线程ids
        thread_ids=$(top -bHp ${jvm_pid} -n 1 | sed -n '8,12'p | grep -w -v ${jvm_pid}| awk '{print $1}')
        # 取线程id转成16进制
        for thread in ${thread_ids[@]}
        do
            # 10 to 16 
            sixteen=$(echo ${thread} | awk '{printf ("%x\n", $0)}')
            thread_ids_sixteen+="${sixteen} "
            # 16 to 10
            # echo 3c6d | awk '{print strtonum("0x"$0)}'
        done            
        # jstack -l pid > pid.log
        jstack -l ${jvm_pid} > ${pid_log}
        # vim pid.log 找16进制的线程id。
        for thread_sixteen in ${thread_ids_sixteen[@]}
        do
            echo -e "\n\tThread Id: ${thread_sixteen}\n \t\t$(grep -nw "nid=0x${thread_sixteen}" ${pid_log})"
        done
    else
        echo "pass"
    fi

}

# apache进程数
info_apache_process=$(ps -ef | grep -v grep | grep httpd -c)
# ip地址访问量排行统计
apache_logs_dir=/home/apache2/logs
if [[ -d ${apache_logs_dir} ]];
then
    # IP地址访问量排行统计
    info_ip_access_top=$(awk '{print $1}' ${apache_logs_dir}/*access$(date +%F)* | sort | uniq -c | sort -nr | head -n ${line:-10})
    # 无效请求地址访问量排行统计
    info_ip_bad_access_top=$(awk '{print $1, $9}' ${apache_logs_dir}/*access$(date +%F)* | sort | uniq -c | sort -nr | head -n ${line:-10} | grep -v " 200")
    # apache最后10s每秒请求行数, 使用seq+sort+date显示10秒前的时间，然后匹配日志文件，计数
    info_ip_last_foo_second=$(for sec in $(seq 1 ${second:-10} | sort -rn);do curr_date_time=$(date -d "-${sec} second" +%H:%M:%S); count_request=$(grep -c "$(date -d "-${sec} second" +%H:%M:%S)" ${apache_logs_dir}/*access$(date +%F)*);echo -e "\t$(date +%F)T${curr_date_time} \t${count_request}" ;done)
fi
# 数据库连接池进程情况
info_database_process=$(ps aux | grep -v grep | grep -E -c "mysql|oracle")



echo -e """
- CPU(核/Core): \t\t合计/Total: ${info_cpu}(按百分比${info_cpu}00%) \t已使用/Used: ${info_cpu_used:-0}%

- 内存(G)/Memory: \t\t合计/Total: ${info_mem}G \t\t已使用/Used: ${info_mem_used}

- 当前用户进程数/Processes: \t上限/Max: ${info_current_user_processes_limit} \t\t已使用/Used: ${info_current_user_processes_open}

- IP地址/IPaddress: \t\t${info_ip_address}

- 硬盘容量使用/Disk: >
    ${info_disk_used}

- 硬盘inode使用/Inode: >
    ${info_disk_inode_used}

- 内网网络通信/Network>
    $(do_check_nc 127.0.0.1 22 tcp local_sshd)

- 内网网络带宽情况(bytes):
$(do_count_net)

- Jvm>
$(do_jvm_action)

- 日志目录大小/LogsSize>
$(do_check_jvm_dir)

- 占用CPU最高的Jvm>
$(do_check_top_jvm_pid)

- Apache进程数/Processes: 合计/Total: ${info_apache_process}

- Apache最后10s的请求数/Apache Requests(Last 10 Seconds)>
${info_ip_last_foo_second:-pass}

- IP地址访问量排行统计(Top 10 access)> 
${info_ip_access_top:-pass}

- 无效访问量排行统计(Top 10 invalid)> 
${info_ip_bad_access_top:-pass}

- TCP连接数>
$(ss -napt | awk '{print $1}' | grep -v State | sort | uniq -c | sort -rn)

- 数据库/Database: 合计/Total: ${info_database_process}
"""



