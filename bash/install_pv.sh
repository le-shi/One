#!/bin/bash
# http://www.ivarch.com/programs/pv.shtml
# pv version 1.6.6支持监控pid，其他版本暂不了解

# 如何通过linux监控一个进程，通过pv；如何在进程停止的时候发送通知给我，通过http协议接口
# example1: pv -d PID && curl https://wow.me/send/msg


# Add ivarch.repo
tee /etc/yum.repos.d/ivarch.repo <<EOF
[ivarch]
name=RPMs from ivarch.com
baseurl=http://www.ivarch.com/programs/rpms/\$basearch/
enabled=1
gpgcheck=1
EOF

# Add gpgkey
rpm --import http://www.ivarch.com/personal/public-key.txt

# Makecache
yum makecache

# Install
yum -y install pv

