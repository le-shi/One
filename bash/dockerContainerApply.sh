#!/bin/bash
set -e
# - 挂载`.env` `docker-compose.yaml` `docker-compose`
# - 目标的名字XXX，版本YYY
# - 版本变量规范: `IMAGE_VERSION_XXX`
# - 镜像地址规范: `cr.zbxsoft.com/zbx/xxx:${IMAGE_VERSION_XXX}`

# 1. 开始之前写个文件当锁，检查配置文件是不是正确的，备个份，开始操作 || 返回结束信息
# 2. 替换版本号
#    1. 判断.env有没有`IMAGE_VERSION_XXX`
#       1. 有: sed 's/IMAGE_VERSION_XXX=old/IMAGE_VERSION_XXX=new/g' .env
#       2. 有，没用|没有: 替换docker-compose.yaml里的版本号 sed 's|cr.zbxsoft.com/zbx/xxx|cr.zbxsoft.com/zbx/xxx:YYY|g' docker-compose.yaml
#          1. 找到镜像名的配置，看看有没有版本号 grep -Pw 'sc:' docker-compose.yaml |grep "image:" | awk -F "image: " '{print $2}' | grep ':'
#             1. 有: 取 ":" 前面的，拼接新版本号，复写
#             2. 没有: 原名字拼接新版本号，复写
# 3. 校验配置文件语法 docker-compose config
# 4. 重启 docker-compose pull XXX && docker-compose up -d XXX
# 5. 返回成功信息


# Fixed: ERROR: TLS configuration is invalid - make sure your DOCKER_TLS_VERIFY and DOCKER_CERT_PATH are set correctly.
# You might need to run `eval "$(docker-machine env default)"`
unset DOCKER_TLS_VERIFY
unset DOCKER_CERT_PATH

# 服务名
app_name=$1
# 服务版本
app_version=$2
# env文件中服务版本变量名字
env_version_set=IMAGE_VERSION_${app_name}
env_version_set=$(echo ${env_version_set} | tr [:lower:] [:upper:])
# 操作目录，处理docker-compose.yaml和.env所在的目录
action_dir=${ACTION_DIR:-/home}
# 锁定文件，避免多人同时操作
lock_file=/tmp/sc_apply.lock
# 备份文件，操作之前备份一下
back_file=apply-backup-$(date +%FT%H-%M-%S.%N)
# env 文件位置
env_file=.env
# docker-compose.yaml 文件位置
compose_file=docker-compose.yaml
# docker-compose 可执行二进制文件位置
compose_binary=$(which docker-compose)

# 通用输出
common_echo(){
    echo "$*"
}

# 判断命令是否正常退出
if_commond_exit(){
    ${*} 2>&1 > /dev/null
    local res=${?}
    if [[ ! ${res} == 0 ]];then
        return 1
    else
        return 0
    fi
}

# 检查有没有锁，有的话退出，没有继续
check_lock(){
    if [[ -f ${lock_file} ]]; then
        common_echo "当前有更新在执行，请稍后再试!"
        exit 1
    else
        trap "rm -f ${lock_file}" SIGKILL SIGHUP SIGINT SIGTERM SIGTSTP EXIT
    fi
}

check_env(){
    # 统计文件行数
    count_max_line=$(awk END'{print NR}' ${env_file})
    # 检查有没有变量，没有就添加
    if [[ ! $(grep "${env_version_set}=" ${env_file}) ]]; then
        sed -i "${count_max_line}a ${env_version_set}=${app_version}" ${env_file}
    else
        # 获取.env的`IMAGE_VERSION_XXX`
        env_name=$(grep "${env_version_set}=" ${env_file})
        # 获取.env的`IMAGE_VERSION_XXX`所在行号
        env_line_number=$(grep -n "${env_version_set}=" ${env_file} | awk -F ':' '{print $1}')
        # .env的新名字
        env_new_name=${env_version_set}=${app_version}
        if [[ ! ${env_name} == ${env_new_name} ]]; then
            sed -i "${env_line_number}s/${env_name}/${env_new_name}/g" ${env_file}
        else
            :
            # 调试输出
            # echo "pass. env"
        fi
    fi
}

# 检查docker-compose.yaml，有变量，略过；无变量，添加
check_compose(){
    # 找镜像名所在行
    find_image=$(grep -En "image: (.*)${app_name}" ${compose_file} | grep -Ev "#|^$")
    # 截取行号
    image_line_number=$(echo ${find_image} | awk -F ':' '/image:/{print $1}')
    # 截取镜像地址
    image_name=$(echo ${find_image} | awk -F 'image: ' '/image:/{print $2}')
    # 如果镜像名存在版本号(有:存在)，判断是不是变量的形式；不存在版本号，复写
    if [[ $(echo ${image_name} | grep -c ":") ]]; then
        image_new_name=$(echo ${image_name} | awk -F ':' '{print $1}')
    else
        image_new_name=${image_name}
    fi
    # 镜像规范地址
    image_common_name=${image_new_name}:\$\{${env_version_set}\}
    # 对比镜像地址,不标准就执行标准
    if [[ ! ${image_name} == ${image_common_name} ]]; then
        sed -i "${image_line_number}s|${image_name}|${image_common_name}|g" ${compose_file}
    else
        :
        # 调试输出
        # echo "pass. compose"
    fi
}

if [[ $# -lt 2 ]];then
  common_echo "需要参数 [服务名] 和 [版本号]. You need to enter the service name and version number."
  exit 1
  elif [[ $(echo ${*} | grep -ic 'undefined') -eq 1 ]];then
  common_echo "非法输入.> undefined"
fi

# 检查锁
check_lock
# 切换到操作目录
cd ${action_dir}
# 创建锁文件
touch ${lock_file}
# 检查当前是正确的, 才能继续
if [[ ! $(if_commond_exit ${compose_binary} -f ${compose_file} config) ]]; then
    cp ${env_file}{,.${back_file}}
    cp ${compose_file}{,.${back_file}}
    cp -r .docker /opt/ || true
else
    common_echo "docker-compose 语法有错误，请进行检查1 [docker-compose config]"
    exit 2
fi

# 标准化env
check_env
# 标准化docker-compose.yaml
check_compose
# 校验配置文件语法
if [[ $(if_commond_exit ${compose_binary} -f ${compose_file} config) ]]; then
    common_echo "docker-compose 语法有错误，请进行检查2 [docker-compose config]"
    exit 2
fi
# 重启 -- 拉取镜像
if [[ ! $(if_commond_exit ${compose_binary} -f ${compose_file} pull ${app_name}) ]]; then
    common_echo "docker-compose 拉取镜像有错误，请进行检查 [网络连通性|认证信息]"
    exit 2
fi
# 重启 -- 使用新镜像启动
if [[ ! $(if_commond_exit ${compose_binary} -f ${compose_file} up -d ${app_name}) ]]; then
    common_echo "docker-compose 重新启动有错误，请进行检查 [docker ps -a]"
    exit 2
fi
# happy
# echo "新版本${app_version}已经创建，正在启动..."
# 输出容器ID
curl -s --unix-socket /var/run/docker.sock "http://localhost/v1.39/containers/${app_name}/json" | jq 'if .Id == null then .message else .Id end' | sed 's/"//g'
