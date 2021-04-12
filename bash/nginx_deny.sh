#!/bin/bash

# 预检查配置文件路径、配置文件语法(修改前的)，检查添加规则后的配置，支持IP和URL
# 添加配置，加载配置

# IP的方式 不能写域名
# URL的方式 是模糊匹配 /aaa/a /aaa/b 如果写 script.sh url aaa 那么包含aaa的都不能访问

# 当前脚本仅适用于docker环境的nginx
# 使用方法:
# 1. 在/home/volume/nginx/config/vhost.conf配置文件中server段，添加include /etc/nginx/conf.d/*.deny;
# 2. 检查nginx语法: docker exec nginx nginx -t
# 3. 测试封禁IP: srcipt.sh ip 测试IP  --通过测试IP的机器访问这台nginx，会提示"403 Forbidden"
# 4. 测试封禁URL: srcipt.sh url /path/to  --通过任意机器访问这台nginx的/path/to路径，会提示脚本中定义的return的状态码
# 5. (异常封禁的解决方法)如果封禁ip或url时写错了参数，请手动编辑配置文件temp.deny，删除错误记录，然后调整参数重新执行脚本
# 6. (解禁)如果想去掉某条封禁记录(ip或者url)，请自行编辑配置文件temp.deny，删除需要删除的记录，然后重新加载nginx配置文件

nginx_conf_dir=/home/volume/nginx/config
deny_conf=temp.deny

if [[ $# -lt 2 ]]; then
    echo "Usage: [$0 url /path/to] or [$0 ip x.x.x.x]"
    exit 1
else
    if [[ -d ${nginx_conf_dir} ]];then
        :
    else
        echo "> nginx配置文件路径不存在，请检查nginx配置文件路径是否正确"
        exit 1
    fi

    docker exec nginx nginx -t 2>/dev/null
    res=$?
    if [[ ${res} == 0 ]];then
        :
    else
        echo -e "> nginx配置文件语法校验失败，请检查配置文件，错误信息如下: \n"
        docker exec nginx nginx -t || true
        exit 1
    fi
fi

do_check_nginx_configure(){
    docker exec nginx nginx -t 2>/dev/null
    res=$?
    if [[ ${res} == 0 ]];then
        :
    else
        echo "> 添加配置后，nginx配置文件语法校验失败，请检查配置文件: ${nginx_conf_dir}/${deny_conf}"
        exit 1
    fi
    echo "热加载配置文件完成"
    docker exec nginx nginx -s reload 2>/dev/null
}

do_deny_url(){
    touch ${nginx_conf_dir}/${deny_conf}
    echo 'if ($uri ~ "'${1}'") { return 406;}' >> ${nginx_conf_dir}/${deny_conf}
    do_check_nginx_configure
}

do_deny_ip(){
    touch ${nginx_conf_dir}/${deny_conf}
    echo "deny ${1};" >> ${nginx_conf_dir}/${deny_conf}
    do_check_nginx_configure
}

case $1 in
    url)
        do_deny_url ${2}
    ;;
    ip)
        do_deny_ip ${2}
    ;;
    *) echo "Usage: [$0 url /path/to] or [$0 ip x.x.x.x]";;
esac
