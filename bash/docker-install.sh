#!/bin/sh
# 一键安装docker环境
set -e

u=$USER
r=$(lsb_release -cs)
listfile=/etc/apt/sources.list

deb_bionic="deb http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse"
deb_bionic_security="deb http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse"
deb_bionic_updates="deb http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse"
deb_bionic_backports="deb http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse"
deb_bionic_proposed="deb http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse"
deb_src_bionic="deb-src http://mirrors.aliyun.com/ubuntu/ bionic main restricted universe multiverse"
deb_src_bionic_security="deb-src http://mirrors.aliyun.com/ubuntu/ bionic-security main restricted universe multiverse"
deb_src_bionic_updates="deb-src http://mirrors.aliyun.com/ubuntu/ bionic-updates main restricted universe multiverse"
deb_src_bionic_backports="deb-src http://mirrors.aliyun.com/ubuntu/ bionic-backports main restricted universe multiverse"
deb_src_bionic_proposed="deb-src http://mirrors.aliyun.com/ubuntu/ bionic-proposed main restricted universe multiverse"

sudo cp ${listfile} ${listfile}.bak
grep "${deb_bionic}" ${listfile} || echo "${deb_bionic}" | sudo tee -a ${listfile}
grep "${deb_bionic_security}" ${listfile} || echo "${deb_bionic_security}" | sudo tee -a ${listfile}
grep "${deb_bionic_updates}" ${listfile} || echo "${deb_bionic_updates}" | sudo tee -a ${listfile}
grep "${deb_bionic_backports}" ${listfile} || echo "${deb_bionic_backports}" | sudo tee -a ${listfile}
grep "${deb_bionic_proposed}" ${listfile} || echo "${deb_bionic_proposed}" | sudo tee -a ${listfile}
grep "${deb_src_bionic}" ${listfile} || echo "${deb_src_bionic}" | sudo tee -a ${listfile}
grep "${deb_src_bionic_security}" ${listfile} || echo "${deb_src_bionic_security}" | sudo tee -a ${listfile}
grep "${deb_src_bionic_updates}" ${listfile} || echo "${deb_src_bionic_updates}" | sudo tee -a ${listfile}
grep "${deb_src_bionic_backports}" ${listfile} || echo "${deb_src_bionic_backports}" | sudo tee -a ${listfile}
grep "${deb_src_bionic_proposed}" ${listfile} || echo "${deb_src_bionic_proposed}" | sudo tee -a ${listfile}

sudo apt-get update && \
sudo apt-get remove -y docker docker-engine docker.io && \
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common && \
curl -fsSL https://download.docker.com/linux/ubuntu/gpg |sudo apt-key add - && \
#apt-key fingerprint 0EBFCD88 && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $r stable" && \
sudo apt-get update && \
sudo apt-get install -y docker-ce && \
#docker -v && \
sudo usermod -aG docker $u && \
sudo service docker start && \
sudo chown $u.docker /var/run/docker.sock  && \
docker ps
