#!/bin/bash
set -e
#jar path : /home/xxx/jar/{app1,app2,app3}
#Usage:
#  ./server app_id [start|status|stop|restart|slient-restart|logs]
# Ctrl+C == Exit
trap '' SIGTSTP

# 服务所在目录
export jar_path=~/jar
# 服务名
export app_id=${1}
# 要执行的操作
export app_status=${2}
export suM=`ps -ef| grep -- "-jar ${app_id}" | grep -- '.jar' | grep -v grep |wc -l`
tail_log_server (){
    # server_status in status_server
    status_server
    if [[ ${server_status} == "up" ]];then
        set -x
        tail -f ${jar_path}/${app_id}/${app_id}.log
        set +x
    elif [[ ${server_status} == "down" ]];then
        set -x
        tail ${jar_path}/${app_id}/${app_id}.log
        set +x
    fi
}

stop_server (){
    pid=$(jps -l | grep -v Jps | grep -w "${app_id}" | grep -v grep | awk '{print $1}')
    if [[ ${app_status} == "stop" ]];then
        KILL_ARGS=9
    elif [[ ${app_status} == "quit" ]];then
        KILL_ARGS=15
    fi
    if [ ! -n "$pid" ]; then
        echo -e "\033[33mserver ${app_id} not running.\033[0m"
    else
        pid_k=$(jps -l | grep -v Jps | grep -w "${app_id}" | awk '{print $1}' | xargs kill -${KILL_ARGS:-9})
        echo -e -n "Stopped server \033[1m\033[32m${app_id}\033[0m"
        echo -e -n " : \033[1m\033[32m${app_id}\033[0m has be killed, "
        echo -e -n "PID is { \033[1m\033[32m${pid}\033[0m }, "
        echo -e "kill process count \033[1m\033[32m${suM}\033[0m"
    fi
}

start_server (){
    cd ${jar_path}/${app_id}
    do_choose_command ${app_id}
    pid=$(jps -l | grep -v Jps | grep -w "${app_id}" | grep -v grep | awk '{print $1}')
    echo -e -n "Started server \033[1m\033[32m${app_id}\033[0m"
    echo -e " : PID is { \033[1m\033[32m${pid}\033[0m }. "
}

restart_server (){
    stop_server
    start_server
    
    echo -e '请按\033[32;1m[回车]\033[0m键继续查看日志或使用[\033[32;1mCtrl+c\033[0m]退出.......'
    read
    tail_log_server
}

silent_restart_server (){
    stop_server
    start_server
}

status_server (){
    server_pid=$(jps -l | grep -v Jps | grep -w "${app_id}" | grep -v grep | awk '{print $1}')
    if [[ -n ${server_pid} ]];then
        runningTime=$(ps -eo pid,etime | grep -w "${server_pid}" | awk '{print $2}')
        echo -e "Server: \033[32m${app_id}\033[0m | Pid: \033[32m${server_pid}\033[0m | Run Time \033[32m${runningTime}\033[0m"
        server_status=up
    else
        echo -e "\033[33mserver ${app_id} not running \033[0m" | tr '\n' ','
        echo " Usage: $0 ${app_id} [start|status|stop|restart]"
        server_status=down
    fi
}

check_start (){
    if [[ ${suM} -ge 1 ]];then
        echo -e "Server \033[1m\033[32m[${app_id}]\033[0m is started."
    else
        start_server ${app_id}
    fi
}

if [[ ! -d ${jar_path}/${app_id} ]];then
    echo  "Server [${app_id}] not exites" | tr '\n' ','
    ls_dir=$(ls -l ${jar_path} | grep "^d" | awk '{print $NF}')
    echo "Please choose [${ls_dir}]" | tr '\n' ','
    echo "Exit."
    exit 2
else
    jar_server=$(ps -ef | grep -- "-jar ${app_id}" | grep -- '.jar' | grep -v grep | awk '{print $1}' | uniq)
    if [[ ${suM} -lt 1 || ($2 = "restart") || ($2 = "slient-restart") ]];then
        :
    else
        if [[ $USER != ${jar_server} ]];then
            echo "Please su [${jar_server}]."
            exit 3
        fi
    fi
fi

case ${app_status} in
    quit)
        stop_server
    ;;
    stop)
        stop_server
    ;;
    start)
        check_start
    ;;
    restart)
        restart_server
    ;;
    slient-restart)
        silent_restart_server
    ;;
    status)
        status_server
    ;;
    logs)
        tail_log_server
    ;;
    replace)
        ntr_replace
    ;;
    *)
        echo "Usage: $0 jar [start|status|stop|restart|slient-restart|logs]"
    ;;
esac
