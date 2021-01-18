#!/bin/bash

# back_jobs_xml: 
back_dir=/home/centos/nextcloud_back
config_dir=/home/centos
count=0

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

do_sync_nginx_conf(){
    job_back_dir=${back_dir}/nginx_conf
    mkdir -pv ${job_back_dir}
    rsync -zva /home/centos/volume/nginx/*.conf ${job_back_dir}
    let count+=1
}

main(){
    # do_sync_jenkins_job
    # do_sync_jenkins_compose
    # do_sync_gitlab_compose
    # do_sync_nginx_conf

    if [[ ${count} -eq 0 ]]
    then
        echo "do nothing"
    else
        echo "do ${count} jobs."
    fi
}

main