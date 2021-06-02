#!/bin/bash

## 使用docker方式运行nextcloudcmd, 需要提前在服务端创建对应目录 https://github.com/le-shi/nextcloud-client-docker
# docker pull juanitomint/nextcloud-client:alpine_3.6
# docker tag juanitomint/nextcloud-client:alpine_3.6 cr.example.com/3rd/nextcloud-client:alpine_3.6
# docker run --rm -v /tmp/ooo:/media/nextcloud -e NC_EXIT=true -e NC_USER=username -e NC_PASS=password -e NC_URL=http://backup.example.com/remote.php/webdav/test cr.example.com/3rd/nextcloud-client:alpine_3.6
## nextcloudcmd
# 附件的备份
# 05 * * * * volume/nginx/data
# 数据库备份文件的备份
# 05 * * * * volume/mysql_backup
# svn仓库文件的备份(包含认证文件和数据文件)
# 05 * * * * volume/svn-data
# 环境配置文件的备份
# 05 * * * * nextcloud_back
# 
# do_check 方法是聚合之前的条件检查
# 下面的所有 do_sync 方法是把一台机器上需要备份的文件(小文件，不算数据库备份文件，svn仓库，附件)聚合到一个目录，通过 nextcloudcmd 同步到备份服务器
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

    if [[ ${count} -eq 0 ]]
    then
        echo "do nothing"
    else
        echo "do ${count} jobs."
    fi
}

main
