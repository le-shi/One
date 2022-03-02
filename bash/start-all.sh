#!/bin/bash
set -e

# 获取执行路径
action_path=$(dirname ${0:-.})
# 加载环境变量
source ${action_path}/server.sh >/dev/null 2>&1 || true
# 定义自定义_ip
export uc_ip=${rc_ip}
export auth_ip=${rc_ip}
# 定义超时时间10分钟
export time_out=600
# 服务列表文件
service_list=${action_path}/services.txt

wait_for_base(){
    wait_hostname=${1}
    wait-for-it.sh ${wait_hostname} --timeout=${time_out}
}

wait_for_service(){
    # 定义局部变量，服务名
    local service=${1}
    case ${service} in
        sc)
            # 判断基础服务成功启动并且可以连接
            # 等数据库
            wait_for_base ${db_ip}:${db_port:-3306}
            # 等缓存
            wait_for_base ${redis_ip}:${redis_port:-6379}
            # 等队列
            wait_for_base ${rabbitmq_ip}:${rabbitmq_port:-5672}
        ;;
        rc)
            wait_for_base ${sc_ip}:8762
        ;;
        uc)
            wait_for_base ${rc_ip}:8761
        ;;
        zuul|auth)
            wait_for_base ${rc_ip}:8761
            wait_for_base ${uc_ip}:7007
        ;;
        web)
            wait_for_base ${rc_ip}:8761
            wait_for_base ${zuul_ip}:2011
            wait_for_base ${auth_ip}:7080
        ;;
        atta|flow|bid|ew|helper|infor|mc|me|ntr|ws|ztb)
            wait_for_base ${rc_ip}:8761
            wait_for_base ${zuul_ip}:2011
        ;;
        *)
            echo "[ERROR] Invalid service name [${service}]!!"
            exit 4
        ;;
    esac
    # 启动服务
    server.sh ${service} start
    
    case ${service} in
        auth)
            wait_for_base ${auth_ip:-0.0.0.0}:7080
            curl ${auth_ip:-0.0.0.0}:7080/root/refresh/app
            echo
        ;;
        zuul)
            wait_for_base ${zuul_ip:-0.0.0.0}:2011
            curl ${zuul_ip:-0.0.0.0}:2011/root
            echo
        ;;
        ntr)
            wait_for_base 0.0.0.0:31084
            curl 0.0.0.0:31084/workday/refresh
            echo
        ;;
        helper)
            wait_for_base 0.0.0.0:31096
            curl -XPOST 0.0.0.0:31096/workday/$(date +%Y -d 'next year')
            echo
        ;;
        *) :
        ;;
    esac
}


# 开始工作
if [[ ! -f ${service_list} ]]
then
    echo "[ERROR] File: ${service_list} does not exist"
    exit 1
fi

for i_service in $(grep -Ev "#|^$" ${service_list})
do
    echo "[INFO] Action: start, Service: ${i_service}"
    wait_for_service ${i_service}
    echo
done
