# Centos6 yum源失效的临时解决办法


```
cat /etc/yum.repos.d/CentOS-Base.repo

# CentOS-Base.repo
#
# The mirror system uses the connecting IP address of the client and the
# update status of each mirror to pick mirrors that are updated to and
# geographically close to the client.  You should use this for CentOS updates
# unless you are manually picking other mirrors.
#
# If the mirrorlist= does not work for you, as a fall back you can try the 
# remarked out baseurl= line instead.
#
#

[base]
name=CentOS-6.6 - Base
baseurl=http://mirrors.aliyun.com/centos-vault/6.6/os/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
[updates]
name=CentOS-6.6 - Updates
baseurl=http://mirrors.aliyun.com/centos-vault/6.6/updates/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
[extras]
name=CentOS-6.6 - Extras
baseurl=http://mirrors.aliyun.com/centos-vault/6.6/extras/x86_64/
gpgcheck=1
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
[centosplus]
name=CentOS-6.6 - Plus
baseurl=http://mirrors.aliyun.com/centos-vault/6.6/centosplus/x86_64/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
 
[contrib]
name=CentOS-6.6 - Contrib
baseurl=http://mirrors.aliyun.com/centos-vault/6.6/contrib/x86_64/
gpgcheck=1
enabled=0
gpgkey=http://mirrors.aliyun.com/centos-vault/RPM-GPG-KEY-CentOS-6
```

重建缓存

    yum makecache

安装测试

    yum install gcc