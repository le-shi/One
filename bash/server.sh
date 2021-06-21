#!/bin/bash
set -e
#jar path : /home/xxx/jar/{app1,app2,app3}
#Usage:
#  ./server app_id [start|status|stop|restart|slient-restart|logs]
# Ctrl+C == Exit
trap '' SIGTSTP

# boot服务所在目录
export jar_path=~/jar
# 服务名
export app_id=${1}
# 要执行的操作
export app_status=${2}
export suM=`ps -ef| grep -- "-jar ${app_id}" | grep -- '.jar' | grep -v grep |wc -l`
#
export db_ip=10.10.12.3
export db_user=zbx
export db_pass='zbx!@#QWE4'
# if All in One database
export db_name=${db_user}
export rc_ip=10.10.12.29
export sc_ip=${db_ip}
export zuul_ip=${db_ip}
export redis_ip=10.10.12.29
export redis_pass=14YVeC0PToxRIAs
export rabbitmq_ip=${db_ip}
# 区块链部署在哪,就写哪个机器的IP地址
export chain_ip=${redis_ip}
# admin部署在哪,就写哪个机器的IP地址
export admin_ip=${db_ip}
export admin_pass='admin!@#QWE4'
# 外部访问admin的地址
export admin_public_ip=https://访问IP:8443
# admin的title
export admin_title=中百信运行监控
# export admin_title='ZBX Operation monitoring'
export volume_path=~/volume
export flyway=false
export java_plus="java -Xms128m -Xmx2048m -Xss512k -Djava.security.egd=file:/dev/urandom"
export common_properties="--spring.cloud.config.uri=http://${sc_ip}:8762/ --spring.flyway.enabled=${flyway}"
# 附加admin参数
export common_properties_admin_one="--management.endpoints.web.exposure.include=* --management.endpoint.health.show-details=always --spring.boot.admin.client.username=admin --spring.boot.admin.client.password=${admin_pass}"
# 附加admin参数指向IP参数
export common_properties_admin_two="--spring.boot.admin.client.url=http://${admin_ip}:8080"
# admin从eureka获取服务列表
export common_properties_plus_one="${common_properties} ${common_properties_admin_one}"
# 自己向admin注册
export common_properties_plus_two="${common_properties_plus_one} ${common_properties_admin_two}"

do_choose_command(){
    case $1 in
        sc)
            nohup ${java_plus} -jar *.jar ${common_properties_admin_one} --eureka.client.service-url.defaultZone=http://${rc_ip}:8761/eureka/ --spring.cloud.config.server.native.search-locations=${volume_path}/config 2>&1 >> ${app_id}.log &
        ;;
        rc)
            nohup ${java_plus} -jar *.jar ${common_properties} 2>&1 >> ${app_id}.log &
        ;;
        web)
            nohup ${java_plus} -jar *.jar ${common_properties_plus_two} 2>&1 >> ${app_id}.log &
        ;;
        ws)
            nohup ${java_plus} -jar *.jar ${common_properties} --spring.redis.host=${redis_ip} --spring.redis.password=${redis_pass} --spring.rabbitmq.addresses=amqp://${rabbitmq_ip}:5672 2>&1 >> ${app_id}.log &
        ;;
        auth|flow|uc|atta|zuul)
            nohup ${java_plus} -jar *.jar ${common_properties_plus_one} 2>&1 >> ${app_id}.log &
        ;;
        helper|bid|infor|ntr|utrb)
            nohup ${java_plus} -jar *.jar ${common_properties_plus_one} --eureka.client.service-url.defaultZone=http://${rc_ip}:8761/eureka/ 2>&1 >> ${app_id}.log &
        ;;
        mc|ew|ztb|me)
            nohup ${java_plus} -jar *.jar ${common_properties_plus_one} --eureka.client.service-url.defaultZone=http://${rc_ip}:8761/eureka/ --spring.cloud.config.profile=config 2>&1 >> ${app_id}.log &
        ;;
        chain)
            nohup ${java_plus} -jar *.jar --spring.application.name=chain --eureka.instance.hostname=${chain_ip} ${common_properties_plus_one} 2>&1 >> ${app_id}.log &
        ;;
        admin)
            nohup ${java_plus} -jar *.jar --spring.application.name=admin --spring.boot.admin.ui.title="${admin_title}" --spring.boot.admin.ui.brand="<img src=\"assets/img/icon-spring-boot-admin.svg\"><span>${admin_title}</span>" --spring.security.user.name=admin --spring.security.user.password=${admin_pass} --eureka.instance.metadata-map.user.name=admin --eureka.instance.metadata-map.user.password=${admin_pass} --eureka.client.service-url.defaultZone=http://${rc_ip}:8761/eureka/ --spring.boot.admin.ui.public-url=${admin_public_ip}/stats --eureka.client.register-with-eureka=false --eureka.client.fetch-registry=true 2>&1 >> ${app_id}.log &
        ;;
    esac
}

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

ntr_replace(){
    if [[ ${app_id} == "ntr" ]];then
        cd ${jar_path}/${app_id}
        # 替换ntr里面的infor.
        set -x
        jar xf ntr*.jar
        sed -i 's/infor\.//g' BOOT-INF/classes/mybatis/mapper/AdhocMapper.xml
        jar cfM0 $(ls *.jar) org/ BOOT-INF/ META-INF/
        set +x
        rm -rf org/ BOOT-INF/ META-INF/

        restart_server
    else
        echo "server not is [ntr]."
        exit 0
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
        echo "Usage: $0 jar [start|status|stop|restart|slient-restart|logs|replace(ntr)]"
    ;;
esac
