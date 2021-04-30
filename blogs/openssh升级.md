# OpensSSH的升级

操作系统: `Centos 7.x`

## 安装新的openssh

1. 备份/etc/ssh目录

        # cp -rp /etc/ssh /etc/ssh.bak

        如果原来的openssh有了自定义配置，还需要将这些配置继承到新的openssh配置文件里
        如果原来的openssh有了自定义配置，还需要将这些配置继承到新的openssh配置文件里
        如果原来的openssh有了自定义配置，还需要将这些配置继承到新的openssh配置文件里
        # grep -Ev "#|^$" /etc/ssh/sshd_config
        # grep -Ev "#|^$" /etc/ssh/ssh_config

2. 必要软件的安装

        # yum -y install gcc zlib zlib-devel openssl-devel

3. 查看当前OpenSSH版本

        # ssh -V
        OpenSSH_7.0.4, OpenSSL 1.0.1e-fips 11 Feb 2017

4. 下载OpenSSH新版本

        打开 https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/ 网站
        选择 一个比较新的版本 进行下载，这里假设是下载 openssh-8.0p1

5. 传到服务器上面，目录随便

6. 安装openssh-8.0p1

        # tar -zxvf openssh-8.0p1.tar.gz

        # cd openssh-8.0p1

        # ./configure

        这步要注意，如果报错，就需要先解决报错的问题才能进行下一步。

        上一步正常执行后，开始编译安装。

        # make -j $(nproc)

        # make install

        # /usr/local/bin/ssh -V

        上面只能说明OpenSSH的客户端开始使用新版本了，但openssh-server服务端还是在用旧版的。

        所以我们还需要修改一下ssh的服务文件，让它开始使用新的版本。

        如果前面./configure没指定位置(prefix)的话，编译后新的sshd服务文件默认是/usr/local/sbin/sshd

## 配置新的openssh

1. 禁用原先的开机启动 SSH服务，并移除服务文件

        # systemctl disable sshd

        # mv /usr/lib/systemd/system/sshd.service /usr/lib/systemd/system/sshd.service_bak

2. 在OpenSSH_8.0p1源码包中，把一些服务文件复制到系统中：

        # cp contrib/redhat/sshd.init /etc/init.d/sshd

        # cp contrib/redhat/sshd.pam /etc/pam.d/sshd.pam

        #  chmod +x /etc/init.d/sshd

3. 修改/etc/init.d/sshd中的SSHD路径：

        # vim /etc/init.d/sshd

        SSHD=/usr/local/sbin/sshd

        启用新的sshd后，由于新版本的OpenSSH默认不允许root用户登录，如果需要使用root远程登录，还需要做一下设置。如果不需要，可以直接重启服务。

        新的OpenSSH的配置文件是在/usr/local/etc/这个目录下，编辑/usr/local/etc/sshd_config：

        # vim /usr/local/etc/sshd_config

        PermitRootLogin yes

4. 重启服务：

        # systemctl daemon-reload

        # systemctl restart sshd

        # systemctl status sshd

5. 更改默认的ssh命令

        备份原有的ssh
        mv /usr/bin/ssh{.old-bak}

        创建软连接
        ln -s /usr/local/sbin/ssh /usr/bin/ssh

        验证
        type ssh

6. 新版本的ssh

        ssh -V

7. 新打开一个ssh终端，可以正常连接就行
