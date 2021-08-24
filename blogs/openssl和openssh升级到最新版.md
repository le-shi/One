# OpenSSL, OpensSSH的升级

操作系统: `Centos 7.x`, `Centos 6.x`

## 安装新的openssl

1. 查看当前版本

        openssl version

2. 下载openssl新版本

        https://www.openssl.org/source/openssl-1.1.1k.tar.gz

3. 传到服务器上面，目录选择/tmp

4. 编译升级到最新版

        cd /tmp

        tar -zxf openssl-1.1.1k.tar.gz

        cd openssl-1.1.1k

        ./config --prefix=/usr/local/openssl

        # 当操作系统是 Centos 7.x 时，使用此命令
        make -j $(nproc)
        # 当操作系统是 Centos 6.x 时，使用此命令
        make -j 4

        make install

5. 使用新的openssl

        # 查看openssl在哪里
        whereis openssl

        # 查看是不是软连接文件
        ls -l /usr/bin/openssl
        
        # 复制新文件到 /usr/bin 下
        cp /usr/local/openssl/bin/openssl /usr/bin/
        
        # 查看 openssl 版本，缺少依赖
        openssl version
        
        # 依赖库做软连接
        ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
        ln -s /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1
        
        # 查看版本是否为新安装的版本
        openssl version


## 升级ssh之前开启telnet服务，避免ssh升级失败无法连接服务器

1. 安装 telnet

        yum -y install xinetd telnet-server

2. 检查配置文件 /etc/xinetd.d/telnet ，如果没有就创建
   
        service telnet
        {
                flags           = REUSE
                socket_type     = stream
                wait            = no
                user            = root
                server          = /usr/sbin/in.telnetd
                log_on_failure  += USERID
                disable         = no
        }

3. 启动服务并查看端口是否监听

        # 当操作系统是 Centos 7.x 时，使用此命令
        systemctl start xinetd
        # 当操作系统是 Centos 6.x 时，使用此命令
        service xinetd start

        ss -antlp | grep 23

4. 创建telnet登录用户，设置登录密码

        useradd upgrade
        echo 'upgrade:upgrade123' | chpasswd

5. 赋予 upgrade 用户的sudo权限

        vim /etc/sudoers
        添加这一行，强制保存，退出
        upgrade ALL=(ALL) ALL

6. 测试登录，登录成功，可以执行root命令

        > telnet 192.168.9.111 23
        Trying 192.168.9.111...
        Connected to 192.168.9.111.
        Escape character is '^]'.

        Kernel 3.10.0-1127.el7.x86_64 on an x86_64
        host1 login: upgrade
        Password: 
        Last login: Fri Jul 30 11:09:19 from 192.168.13.34
        [upgrade@host1 ~]$ sudo su -
        [sudo] password for upgrade: 
        Last login: Fri Jul 30 11:08:25 CST 2021 on pts/1
        [root@host1 centos]# id
        uid=0(root) gid=0(root) groups=0(root)
        [root@host1 centos]# 

## 安装新的openssh

1. 备份/etc/ssh目录

        cp -rp /etc/ssh{,.bak}

2. 必要软件的安装

        yum -y install gcc zlib zlib-devel openssl-devel pam pam-devel
        # 如果yum找不到对应的包，去 <http://rpm.pbone.net/> 上面搜索并下载，进行安装

3. 查看当前OpenSSH版本

        ssh -V

        结果如下
        OpenSSH_7.4p1, OpenSSL 1.0.2k-fips  26 Jan 2017

4. 下载OpenSSH新版本

        打开 https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/ 网站
        选择 一个比较新的版本 进行下载，这里假设是下载 openssh-8.6p1
        https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.6p1.tar.gz

5. 传到服务器上面，目录选择/tmp

6. 编译升级到最新版

        cd /tmp

        tar -zxf openssh-8.6p1.tar.gz

        cd openssh-8.6p1

        ./configure --prefix=/usr/local/openssh --sysconfdir=/etc/ssh  --with-openssl-includes=/usr/local/openssl/include --with-ssl-dir=/usr/local/openssl --with-zlib --with-md5-passwords   --with-pam
        
        # 当操作系统是 Centos 7.x 时，使用此命令
        make -j $(nproc)
        # 当操作系统是 Centos 6.x 时，使用此命令
        make -j 4

        make install

## 配置新的openssh

1. 当操作系统是 Centos 7.x 时，禁用原先的开机启动 SSH 服务，并移除服务文件

        systemctl disable sshd

        mv /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service_bak

2. 复制原先的配置文件

        cp /etc/ssh.bak/sshd_config /etc/ssh/

3. 在源码包中，把服务启动文件复制到系统路径中，赋予执行权限：

        cp contrib/redhat/sshd.init /etc/init.d/sshd

        chmod +x /etc/init.d/sshd

4. 配置 /etc/pam.d/sshd 认证文件, 如果没有就创建

        # 当操作系统是 Centos 7.x 时，使用下面的内容

        #%PAM-1.0
        auth       required     pam_sepermit.so
        auth       substack     password-auth
        auth       include      postlogin
        # Used with polkit to reauthorize users in remote sessions
        -auth      optional     pam_reauthorize.so prepare
        account    required     pam_nologin.so
        account    include      password-auth
        password   include      password-auth
        # pam_selinux.so close should be the first session rule
        session    required     pam_selinux.so close
        session    required     pam_loginuid.so
        # pam_selinux.so open should only be followed by sessions to be executed in the user context
        session    required     pam_selinux.so open env_params
        session    required     pam_namespace.so
        session    optional     pam_keyinit.so force revoke
        session    include      password-auth
        session    include      postlogin
        # Used with polkit to reauthorize users in remote sessions
        -session   optional     pam_reauthorize.so prepare

        # 当操作系统是 Centos 6.x 时，使用下面的内容

        auth    required pam_sepermit.so
        auth       required pam_tally2.so deny=3 unlock_time=86400 even_deny_root root_unlock_time=600
        auth       include      password-auth
        account    required     pam_nologin.so
        account    include      password-auth
        password   include      password-auth
        # pam_selinux.so close should be the first session rule
        session    required     pam_selinux.so close
        session    required     pam_loginuid.so
        # pam_selinux.so open should only be followed by sessions to be executed in the user context
        session    required     pam_selinux.so open env_params
        session    optional     pam_keyinit.so force revoke
        session    include      password-auth

4. 使用新的二进制文件替换掉旧版本

        cp -f /usr/local/openssh/bin/s* /usr/bin/
        cp -f /usr/local/openssh/sbin/sshd /usr/sbin/

5. 重启 sshd 服务

        # 当操作系统是 Centos 7.x 时，使用此命令
        systemctl daemon-reload
        systemctl restart sshd
        systemctl status sshd

        # 当操作系统是 Centos 6.x 时，使用此命令
        service sshd restart
        service sshd status

6. 新打开一个ssh终端，可以正常连接就行

7. 新版本的ssh

        ssh -V

## 清理工作

1. 卸载 telnet-server 服务并重启 xinetd 服务

        # 卸载 telnet-server 服务
        yum -y remove telnet-server

        # 当操作系统是 Centos 7.x 时，使用此命令
        systemctl restart xinetd

        # 当操作系统是 Centos 6.x 时，使用此命令
        service xinetd restart

2. 删除用户

        userdel -r upgrade

3. 删除 sudo 配置

        vim /etc/sudoers
        把 upgrade 那行去掉，强制保存，退出
        upgrade ALL=(ALL) ALL
