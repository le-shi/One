#!/bin/bash
# 四种数据类型: Counter, Gauge, Histogram, Summary
# Counter数据类型: 用于累计值，一直增加，不会减少。重启进程后，会被重置。
# 例如 记录 请求次数、任务完成数、错误发生次数。

# Gauge数据类型: 常规数值，可变大，可变小。重启进程后，会被重置。
# 例如 温度变化、内存使用变化。

# Histogram 可以理解为柱状图的意思，常用于跟踪事件发生的规模
# 例如: 请求耗时、响应大小。它特别之处是可以对记录的内容进行分组，提供 count 和 sum 全部值的功能。
# 例如: {小于10=5次，小于20=1次，小于30=2次}，count=8次，sum=8次的求和值

# Summary和Histogram十分相似，常用于跟踪事件发生的规模
# 例如: 请求耗时、响应大小。同样提供 count 和 sum 全部值的功能。
# 例如: count=7次，sum=7次的值求值
# 它提供一个quantiles的功能，可以按%比划分跟踪的结果。
# 例如: quantile取值0.95，表示取采样值里面的95%数据。

### 三个#表示可以被Prometheus收集的指标
# 定义ssh登录用户指标 ssh_logind,ssh_login_info
# 定义校验DNS解析指标 verify_dns

export pushgateway_ip=${PUSHGATEWAY_IP:-192.168.9.157}
export pushgateway_port=${PUSHGATEWAY_PORT:-9091}
export instance_name=$(hostname -I | awk '{print $1}')
export curr_hostname=$(hostname)
export tmp_file=/tmp/adhoc-$(date +%FT%T).tmp

# 将往pushgateway上传的数据写入 ${tmp_file} 文件

# 定义ssh登录用户指标
function ssh_logind() {

    ### 统计当前登录用户数 ###
    local ssh_login_count=$(who | wc -l)
    echo """# HELP ssh_logind The total number of statistics.
    # TYPE ssh_logind gauge"""
    # 记录主机名和主机IP地址
    echo "ssh_logind{instance=\"${instance_name}\",hostname=\"${curr_hostname}\"} ${ssh_login_count}"

    # 有登录用户时，上报明细
    if [[ ${ssh_login_count} -gt 0 ]]
    then
        local who_tmp_file=/tmp/prom.who.tmp
        who > ${who_tmp_file}
        ### 列出每个登录用户 ###
        echo """# HELP ssh_login_info Details for each logged-in user.
        # TYPE ssh_login_info counter"""
        while read s_u
        do
            login_user=$(echo ${s_u} | awk '{print $1}')
            client_tty=$(echo ${s_u} | awk '{print $2}')
            login_time=$(echo ${s_u} | awk '{print $3, $4}')
            client_ip=$(echo ${s_u} | awk '{print $5}' | sed -e 's/(//' -e 's/)//')
            # 从 w 命令获取登录人当前运行的命令
            what_doing=$(w --no-header --short | grep "${client_tty}" | awk '{for (i=5;i<=NF;i++)printf("%s ", $i);print ""}' | sed "s/ $//")
            # 获取运行命令的PID
            what_doing_pid=$(ps -ef | grep -v grep | grep -v "$(basename ${0})" | grep -- "${what_doing}" | grep "${client_tty}" | awk '{print $2}')
            if [[ ${client_ip} == "" ]]
            then
                client_ip="Console terminal"
            fi
            echo "ssh_login_info{instance=\"${instance_name}\",hostname=\"${curr_hostname}\",login_user=\"${login_user}\",client_tty=\"${client_tty}\",login_time=\"${login_time}\",client_ip=\"${client_ip}\",what_doing=\"${what_doing}\",pid=\"${what_doing_pid}\"} 1"
        done < ${who_tmp_file}
        # 清理文件
        rm -f ${who_tmp_file}
    fi
}

# 定义校验DNS解析指标
function verify_dns() {
    ### 校验机器的DNS是否设置正确，能不能正常解析域名 ###
    local verify_addr=baidu.com
    ping -q -c 1 -W 3 ${verify_addr} >/dev/null
    local dns_response=${?}
    echo """# HELP verify_dns DNS Resolving domain names.
        # TYPE verify_dns gauge"""
    echo """verify_dns{instance=\"${instance_name}\",hostname=\"${curr_hostname}\",verify_point=\"${verify_addr}\"} ${dns_response}"""
}

# 定义MySQL备份结果指标
function backup_mysql() {
    # 判断有没有备份任务
    local check_backup_job=$(crontab -l 2>/dev/null | grep -v "^#" | grep -c "backupMysql.sh")
    if [[ ${check_backup_job} == 0 ]]
    then
        # 如果没有备份任务，返回状态码 1 并退出当前方法
        return 1
    fi
    ### 校验MySQL备份脚本是否正常执行 ###
    echo "Begin prometheus backup_mysql"
    # 获取备份脚本的路径
    local backup_script_path=$(crontab -l | grep -v "^#" | grep "backupMysql.sh" | awk '{print $6}')
    # 获取备份文件存放的路径
    local backup_local_path=$(grep "^DUMP_DIRECTORY=" ${backup_script_path} | awk -F'=' '{print $2}')
    # 判断备份结果正常的思路
    # 通过备份文件 xx.tar.gz ，提取出大小，时间
    # 告警条件：超过1天没备份就告警
    # find /home/centos/volume/mysql_backup/ -mtime -1 -name "*.tar.gz" | xargs -I {} ls -shk --block-size=K {} | tail -n 2
}

# 推送数据
function push_data() {
    # 定义需要执行的方法
    local run_action=${1}
    # 执行方法，生成指标
    ${run_action} > ${tmp_file}_${run_action}
    # 判断方法返回值。非0的返回值跳过推送数据操作
    if [[ ${?} == 0 ]]
    then
        echo "[INFO] Starting Action --- ${run_action} ---"
        # 向特定的 url(pushgateway服务) 推送数据，数据在 ${tmp_file} 文件中
        curl --silent --data-binary "@${tmp_file}_${run_action}" http://${pushgateway_ip}:${pushgateway_port}/metrics/job/${run_action}/instance/${instance_name}
        echo "[INFO] Started  Action --- ${run_action} ---"
    fi
    # 清理缓存文件
    rm -f ${tmp_file}_${run_action}
}

function main() {
    # 推送ssh登录信息
    # - 告警阈值: 有人登录服务器超过10分钟不断开会触发告警
    push_data ssh_logind
    # 推送dns验证结果
    # - 告警阈值: 无法解析域名触发告警
    push_data verify_dns
    # 推送mysql备份结果 --判断是否有mysql备份
    # - 告警阈值: 超过1天没有备份触发告警，文件大小符合空包(tar.gz)触发告警
    # push_data backup_mysql
    # 推送配置备份结果 --判断是否有配置备份
    # - 告警阈值: 没有开启(指定的)备份策略，最后一次备份时间超过1天触发告警
    # 推送备份机同步结果 --判断是否有备份机同步
    # - 告警阈值: 最后一次同步时间(附件类型除外)超过1天触发告警
    # oracle数据库密码有效期 --需要高权限用户查询用户信息？
    # - 告警阈值: 遍历用户，密码过期时间小于7天的触发告警
    # mysql数据库密码有效期 --需要高权限用户查询用户信息？
    # - 告警阈值: 遍历用户，密码过期时间小于7天的触发告警
    # linux用户密码有效期 --使用 root 用户执行
    # - 告警阈值: 遍历用户，密码过期时间小于7天的触发告警
    # mysql ssl证书有效期 --判断是否开启ssl
    # - 告警阈值: 证书有效期时间小于15天触发告警
    # 玄武库 zuul license 证书有效期 --判断是不是玄武库环境,有没有zuul
    # - 告警阈值: 证书有效期时间小于30天触发告警
}

case ${1} in
    *)
        echo "支持环境变量: PUSHGATEWAY_IP, PUSHGATEWAY_PORT"
    ;;
esac

main
