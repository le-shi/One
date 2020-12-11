#/bin/bash
set -e
#创建rsyncd.conf这是rsync服务器的配置文件
touch /etc/rsyncd.conf
#创建rsyncd.secrets 这是用户密码文件
touch /etc/rsyncd.secrets
#将rsyncd.secrets这个密码文件的文件属性设为root拥有, 且权限要设为600, 否则无法备份成功!
chmod 600 /etc/rsyncd.secrets
#创建rysnc服务器信息文件
touch /etc/rsyncd.motd
#设定/etc/rsyncd.conf
echo > /etc/rsyncd.conf  <<EOF
# Distributed under the terms of the GNU General Public License v2
# Minimal configuration file for rsync daemon
# See rsync(1) and rsyncd.conf(5) man pages for help

# This line is required by the /etc/init.d/rsyncd script
pid file = /var/run/rsyncd.pid   
port = 873
address = 192.168.1.171  //本机地址
#uid = nobody 
#gid = nobody    
uid = root   
gid = root  

use chroot = yes  
read only = yes 

#limit access to private LANs
hosts allow=192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0  //允许的主机列表
hosts deny=*     //拒绝的主机列表

max connections = 5 
motd file = /etc/rsyncd.motd

#This will give you a separate log file
#log file = /var/log/rsync.log

#This will log every file transferred - up to 85,000+ per user, per sync
#transfer logging = yes

log format = %t %a %m %f %b
syslog facility = local3
timeout = 300

[rhel4home]   
path = /home     //本地存放目录
list=yes 
ignore errors 
auth users = root
secrets file = /etc/rsyncd.secrets  
comment = This is RHEL 4 data  
exclude = easylife/  samba/     //过滤的目录

[rhel4opt]
path = /opt 
list=no
ignore errors
comment = This is RHEL 4 opt 
auth users = easylife
secrets file = /etc/rsyncd/rsyncd.secrets

注：关于authusers是必须在服务器上存在的真实的系统用户，如果你想用多个用户以,号隔开，比如auth users = easylife,root
EOF

#设定密码文件并授权
echo > /etc/rsyncd.secrets <<EOF
root:mkir
EOF
chown root.root /etc/rsyncd.secrets && chmod 600 /etc/rsyncd.secrets
#设定rsyncd.motd 文件（可以忽略不写）
++++++++++++++++++++++++++++++++++++++++++++++
Welcome to use the mike.org.cn rsync services!
			2002------2009
++++++++++++++++++++++++++++++++++++++++++++++

