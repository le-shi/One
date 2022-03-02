Centos6 解压 rar 文件
---

> centos6的yum源已经不可用，可以通过手动下载rpm的方式进行安装相关软件包

1. 安装 `unrar` 软件

        wget http://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/unrar-5.0.3-1.el6.rf.x86_64.rpm
        # 备用地址: https://github.com/le-shi/packages/raw/master/unrar-5.0.3-1.el6.rf.x86_64.rpm
        rpm -ivh http://rpmfind.net/linux/dag/redhat/el6/en/x86_64/dag/RPMS/unrar-5.0.3-1.el6.rf.x86_64.rpm
        rpm -ivh unrar-5.0.3-1.el6.rf.x86_64.rpm

2. 查看 `unrar` 命令帮助

        unrar --help

3. 查看 `unrar` 二进制命令、帮助页的安装位置

        # 查看当前执行的 unrar 命令是什么位置
        type unrar
        # 查看 unrar 的二进制命令、帮助页的安装位置
        whereis unrar

        # whereis 这个命令已经查出来安装信息了，为啥还用 type 命令；当一个软件同时安装多个版本或多个位置时，可以找到当前运行的可执行命令是不是自己想要运行的可执行命令；比如升级openssl，旧版本的可执行命令位置在/usr/bin/openssl，新安装的可执行命令位置在/usr/local/openssl/sbin/openssl，如果不做处理的话，默认使用的还是旧命令，解决办法就是，移除旧版本的可执行命令，将新版本安装位置的可执行命令，通过拷贝或软连接的方式添加到可执行路径下，可执行路径可以通过 $PATH 变量查看

4. 查看 rar 文件的类型

        file abc.rar
        # 返回: abc.rar: RAR archive data, vb2, os: Unix

5. 使用 `unrar` 解压到当前路径

        unrar x abc.rar

6. 使用 `unrar` 解压到指定路径

        unrar x abc.rar /tmp
