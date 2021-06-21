#!/bin/bash

# 1. 统计要备份的数据和文件，形成表格，便于记录
# 2. 在服务端创建好需要的备份目录
# 3. 在需要备份的服务器上添加定时任务，用于数据的归档备份和汇总
# 4. 在需要备份的服务器上添加定时任务，用于同步到服务端
# 5. 在服务端查看对应目录下步骤4同步的文件
# 6. 使用checkBackupStatus.sh脚本，查看每个同步周期变化的文件，用于检查备份任务是否正常执行

## 使用docker方式运行nextcloudcmd, 需要提前在服务端创建对应目录 https://github.com/le-shi/nextcloud-client-docker
# docker pull juanitomint/nextcloud-client:alpine_3.6
# docker tag juanitomint/nextcloud-client:alpine_3.6 cr.github.com/3rd/nextcloud-client:alpine_3.6
# nextcloudcmd for docker
# 05 * * * * docker run --rm -v /home/centos/nextcloud_back:/media/nextcloud -e NC_HIDDEN=true -e NC_EXIT=true -e NC_USER=用户名 -e NC_PASS=密码 -e NC_URL=http://backup.github.com/remote.php/webdav/9111_lab/nextcloud_back cr.github.com/3rd/nextcloud-client:alpine_3.6
# 附件的备份
# 05 * * * * volume/nginx/data
# 数据库备份文件的备份
# 05 * * * * volume/mysql_backup
# svn仓库文件的备份(包含认证文件和数据文件)
# 05 * * * * volume/svn-data
# 环境配置文件的备份
# 05 * * * * nextcloud_back

# do_check 方法是聚合(汇总)之前的条件检查
# do_sync 方法是把一台机器上需要备份的文件(小文件，不算数据库备份文件，svn仓库，附件)聚合到一个目录，再通过 nextcloudcmd 同步到备份服务器
# back_jobs_xml: 
back_dir=/home/centos/nextcloud_back
config_dir=/home/centos
count=0
command_exist=0

do_check_command_exist(){
    type ${1} > /dev/null 2>&1
    res=${?}
    case ${res} in
        0) :
        ;;
        *)
        echo "command [${1}] not exist, please install"
        let command_exist+=1
        ;;
    esac
}

do_check_command_result(){
    case ${command_exist} in
        0) :
        ;;
        *) exit 1
        ;;
    esac
}

do_check_dir_exist(){
    if [[ -d ${1} ]];
    then
        :
    else
        echo "dir: ${1} is not exist"
        exit 1
    fi
}

do_sync_jenkins_job(){
    job_dir=${config_dir}/volume/jenkins-data/jobs
    do_check_dir_exist ${job_dir}
    job_back_dir=${back_dir}/jenkins_config
    mkdir -pv ${job_back_dir}
    rsync -zva ${job_dir}/../config.xml ${job_back_dir}

    for job in `ls ${job_dir}`
    do
        job_back_dir=${back_dir}/jenkins_job/$job
        mkdir -pv ${job_back_dir}
        rsync -zva ${job_dir}/$job/config.xml ${job_back_dir}
    done
    let count+=1
}

do_sync_jenkins_compose(){
    job_back_dir=${back_dir}/jenkins_compose
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/docker-compose.yaml ${job_back_dir}
    let count+=1
}

do_sync_gitlab_compose(){
    job_back_dir=${back_dir}/gitlab_compose
    mkdir -pv ${job_back_dir}
    rsync -zva /root/gitlab/gitlabhq-11.10.1/docker-compose.yml ${job_back_dir}
    let count+=1
}

do_sync_autostart_script(){
    job_back_dir=${back_dir}/autostart_script
    mkdir -pv ${job_back_dir}
    rsync -zva /etc/init.d/*.sh ${job_back_dir}
    rsync -zva /etc/rc.d/rc.local ${job_back_dir}
    let count+=1
}

do_sync_crontab_configure(){
    job_back_dir=${back_dir}/crontab_configure
    mkdir -pv ${job_back_dir}
    is_login_user=$(awk -F ':' '!/nologin|sync|shutdown|false|halt/{print $1}' /etc/passwd)
    for iuser in ${is_login_user}
    do
      crontab -l -u ${iuser} > ${job_back_dir}/crontab_comand_list_for_${iuser}
    done
    rsync -zva /etc/crontab ${job_back_dir}
    let count+=1
}

do_sync_env_startup_configure(){
    job_back_dir=${back_dir}/startup_configure
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/{*.yaml,.env,*.sh,files/*.sh} ${job_back_dir}
    let count+=1
}

do_sync_env_spring_configure(){
    job_back_dir=${back_dir}/spring_configure
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/volume/config ${job_back_dir}
    let count+=1
}

do_sync_nginx_conf(){
    job_back_dir=${back_dir}/nginx_conf
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/volume/nginx/config/{*conf,*.pem,*.key,*.cert,*.crt} ${job_back_dir}
    let count+=1
}

do_sync_mysql_conf(){
    job_back_dir=${back_dir}/mysql_conf
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/volume/mysql/config ${job_back_dir}
    let count+=1
}

do_sync_redis_conf(){
    job_back_dir=${back_dir}/redis_conf
    mkdir -pv ${job_back_dir}
    rsync -zva ${config_dir}/volume/redis/config ${job_back_dir}
    let count+=1
}

do_sync_custome_file(){
    # 第1个参数备份出来的目录名 第2个参数是目标目录或文件,设计通配符的需要用双引号引起来
    job_back_dir=${back_dir}/${1}
    mkdir -pv ${job_back_dir}
    src_path=$(eval echo ${2})
    rsync -zva ${src_path} ${job_back_dir}
    let count+=1
}

main(){
    do_check_command_exist rsync
    do_check_command_result

    # do_sync_jenkins_job
    # do_sync_jenkins_compose
    # do_sync_gitlab_compose
    
    # do_sync_crontab_configure
    # do_sync_autostart_script
    # do_sync_env_startup_configure
    # do_sync_env_spring_configure
    # do_sync_nginx_conf
    # do_sync_mysql_conf
    # do_sync_redis_conf

    # do_sync_custome_file harbor_config "${config_dir}/harbor/{*.sh,*.yml,prepare}"
    # do_sync_custome_file harbor_ssl /etc/harbor/ssl
    # do_sync_custome_file jenkins-scripts ${config_dir}/jenkins/volume/jenkins-scripts
    # do_sync_custome_file prometheus_config "${config_dir}/prometheus/{*.yml,*.yaml,*.tmpl,readme,reload}"
    # do_sync_custome_file ingress_config ${config_dir}/ingress
    # do_sync_custome_file sonarqube_config "${config_dir}/sonarqube/*.yaml"
    # do_sync_custome_file gitlab_config /root/gitlab/gitlabhq-11.10.1/config
    # do_sync_custome_file autostart_script "/root/{README,start}"
    # do_sync_custome_file named_config "/etc/named.*"
    # do_sync_custome_file named_master_zone_config "/var/named/{dynamic,*.zone}"

    # do_sync_custome_file nginx_config /root/nginx
    # do_sync_custome_file prom_node_config /root/prom
    # do_sync_custome_file minio_config /root/minio
    # do_sync_custome_file git_config /root/git
    # do_sync_custome_file svn_config /root/svn
    # do_sync_custome_file mysql_config /root/mysql
    # do_sync_custome_file oracle_config /etc/oratab

    if [[ ${count} -eq 0 ]]
    then
        echo "do nothing"
    else
        echo "do ${count} jobs."
    fi
}

main
