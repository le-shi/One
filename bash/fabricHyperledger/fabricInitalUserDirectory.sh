#!/bin/bash
###创建用户目录
listFile=~/orgList

grep -Ev "#|^$" $listFile | while read line
do
  SSH_USERNAME=$(echo ${line} | awk -F ";" '{print $1}')
  SSH_PASSWORD=$(echo ${line} | awk -F ";" '{print $5}')
  useradd -m -s /bin/bash -N ${SSH_USERNAME}
  echo "${SSH_USERNAME}:${SSH_PASSWORD}" | chpasswd
  chown 700 /home/${SSH_USERNAME}
done
