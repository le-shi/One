#!/bin/bash
# 脚本的功能：将官网下载的tomcat压缩包，转换成统一标准的tomcat
# 1. bin目录下的文件添加执行权限
# 2. 关闭shutdown端口

# 用法: 脚本名，服务名，端口号，生成路径(默认是当前路径)
# 批量转 ./srcipt.sh tomcat_list
# 单个转 ./script.sh tom1 18080

# tomcat_list内容例子
# app1 18080
# app2 28080
# app3 38080
# app4 48080 /tmp

TOMCAT_VERSION=apache-tomcat-8.5.55
if [[ $# == 0 ]];then
    echo """Usage: 
1. $0 [tomcat_name] [tomcat_port] [tomcat_path]
    tomcat_path(default value: .)
2. $0 file
    file:
        app1 port1 path1
        app2 port2 path2
        ...
"""
    exit 1
fi

# 处理一个Tomcat
do_clone_single_tomcat(){
    # 需要新的名字和新的HTTP端口
    tomcat_name=${1}
    tomcat_port=${2}
    tomcat_path=${3:-.}
    tomcat_url=${tomcat_path}/${tomcat_name}

    # 校验参数
    if [[ -z ${tomcat_name} || -z ${tomcat_port} ]];then
        echo "Usage: $0 [tomcat_name] [tomcat_port] [tomcat_path]"
        exit 1
    fi

    # 检查是否已存在
    if [[ -d ${tomcat_url} ]];then
        echo "Tomcat: [${tomcat_name}] exists!"
    else
        # 校验有没有 ${TOMCAT_VERSION}
        if [[ ! -d ${TOMCAT_VERSION} ]];then
            if [[ -f ${TOMCAT_VERSION}.zip ]];then
                unzip -q ${TOMCAT_VERSION}.zip
            else
                echo "[${TOMCAT_VERSION}.zip] not exist!!"
                exit 1
            fi
        fi

        # 刷权限
        chmod +x ${TOMCAT_VERSION}/bin/*.sh
        # 关闭shutdown端口
        sed -i 's/8005/-1/g' ${TOMCAT_VERSION}/conf/server.xml

        # 开始克隆
        cp -r ${TOMCAT_VERSION} ${tomcat_url}
        sed -i "s/8080/${tomcat_port}/g" ${tomcat_url}/conf/server.xml

        echo "Tomcat: [${tomcat_name}], Port: [${tomcat_port}], Path: [${tomcat_url}]"
    fi
}

# 读取列表，处理Tomcat
do_clone_list_tomcat(){
    list_file=${1}
    while read app;do
        tomcat_name=$(echo ${app}|awk '{print $1}')
        tomcat_port=$(echo ${app}|awk '{print $2}')
        tomcat_path=$(echo ${app}|awk '{print $3}')

        do_clone_single_tomcat ${tomcat_name} ${tomcat_port} ${tomcat_path}
    done <${list_file}
}

arg1=$1
arg2=$2
arg3=$3

if [[ -f ${arg1} ]];then
    if [[ -r ${arg1} ]];then
        do_clone_list_tomcat ${arg1}
    fi
else
    do_clone_single_tomcat ${arg1} ${arg2} ${arg3}
fi
