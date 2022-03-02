centos7使用rsync_daemon进行文件同步

rsync是一个常用的 Linux 应用程序，用于文件同步。

它可以在本地计算机与远程计算机之间，或者两个本地目录之间同步文件（但不支持两台远程计算机之间的同步）。它也可以当作文件复制工具，替代cp和mv命

它名称里面的r指的是 remote，rsync 其实就是"远程同步"（remote sync）的意思。与其他文件传输工具（如 FTP 或 scp）不同，rsync 的最大特点是会检查发送方和接收方已有的文件，仅传输有变动的部分（默认规则是文件大小或修改时间有变动）。

远程同步：
SSH 协议
rsync 协议

这里仅对 rsync协议 进行配置和使用的展示

安装
如果本机或者远程计算机没有安装 rsync，可以用下面的命令安装。

yum install rsync

注意，传输的双方都必须安装 rsync。

配置
== 服务端配置 ==
# 配置文件在/etc/rsyncd.conf

# 更多参数信息通过 man rsyncd.conf 命令查看
# == 全局配置 ==
# 设置运行 rsync-daemon 进程的用户
uid = root                              
gid = root
# 设置运行rsync守护进程监听的端口(default: 873/tcp)
port = 50873
# 如果"use chroot"为true，则rsync守护进程会在开始与客户端传输文件之前，将chroot设置为"path"。这额外的保护的优势可能实现安全漏洞,但它的缺点是需要超级用户权限,无法跟踪绝对或新根路径之外的符号链接,并增加了按名称保存用户和组的复杂性
use chroot = no
# 这个参数决定了客户端是否能够上传文件。如果"read only"为真，那么任何尝试的上传都会失败。如果“read only”为false，那么上传将是可能的，这取决于守护端的文件权限。默认情况下，所有模块都是只读的
read only = no
# 最大连接数
max connections = 10
# 日志文件
log file = /var/log/rsyncd.log     
# 该参数以类似于ftp守护进程使用的格式支持对下载和上传的每个文件进行日志记录。守护进程总是在最后记录传输，所以如果传输中止，日志文件中不会提及。
transfer logging = yes
# 超时时长
timeout = 900

# == 模块配置 ==
# 模块名称
[module1]
# 指定一个描述字符串，当客户端获取可用模块列表时，该字符串显示在模块名称旁边。默认是没有注释。
comment = rsync info 1
# 为守护进程指定当前模块使用的目录，目录需要在文件系统中存在
path = /mnt/1
# 告诉rsyncd在运行传输的删除阶段时是否忽略守护进程上的I/O错误
ignore errors
# 允许连接到这个模块的用户名(指定以逗号和/或空格分隔的授权规则列表)。用户名不需要在本地系统中存在。如果设置了“认证用户”，那么客户端将被要求提供用户名和密码连接到模块。此交换使用质询响应身份验证协议。纯文本用户名和密码存储在由“secrets file”参数指定的文件中
auth users = admin1
# 纯文本用户名和密码存储文件路径，权限600
secrets file = /etc/rsyncd.secrets
# 当客户端请求可用模块列表时，决定是否列出该模块。
list = true
# 指定客户端主机名和IP地址的匹配模式列表。如果没有匹配的模式，则拒绝连接。
hosts allow = 192.168.13.0/24


# 模块名称
[module2]
# 指定一个描述字符串，当客户端获取可用模块列表时，该字符串显示在模块名称旁边。默认是没有注释。
comment = rsync info 2
# 为守护进程指定当前模块使用的目录，目录需要在文件系统中存在
path = /mnt/2
# 告诉rsyncd在运行传输的删除阶段时是否忽略守护进程上的I/O错误
ignore errors
# 允许连接到这个模块的用户名(指定以逗号和/或空格分隔的授权规则列表)。用户名不需要在本地系统中存在。如果设置了“认证用户”，那么客户端将被要求提供用户名和密码连接到模块。此交换使用质询响应身份验证协议。纯文本用户名和密码存储在由“secrets file”参数指定的文件中
auth users = admin2
# 纯文本用户名和密码存储文件路径，权限600
secrets file = /etc/rsyncd.secrets
# 当客户端请求可用模块列表时，决定是否列出该模块。
list = true
# 指定客户端主机名和IP地址的匹配模式列表。如果没有匹配的模式，则拒绝连接。
hosts allow = 192.168.13.0/24


# 创建模块里定义的目录
mkdir -pv /mnt/{1,2}
# 创建认证文件
touch /etc/rsyncd.secrets
chmod 600 /etc/rsyncd.secrets
echo 'admin1:123456' >> /etc/rsyncd.secrets
echo 'admin2:654321' >> /etc/rsyncd.secrets

注意：认证文件的属主、属组要和运行 rsync-daemon 进程的用户一致

# 启动rsync服务
systemctl start rsyncd.service
systemctl enable rsyncd.service

# 检查是否已经成功启动，端口看上面配置文件中自己定义的
ss -anplt | grep 50873

== 客户端配置 ==

测试端口连通性
telnet 172.30.1.11 50873
nc -zv 172.30.1.11 50873
echo -n > /dev/tcp/172.30.1.11/50873

创建密码文件
touch /etc/rsyncd.admin1.pass /etc/rsyncd.admin2.pass
chmod 600 /etc/rsyncd.*.pass
echo '123456' > /etc/rsyncd.admin1.pass
echo '654321' > /etc/rsyncd.admin2.pass

注意：密码文件的属主、属组要和运行 rsync 进程的用户一致

# 非默认端口下传输文件  客户端 -> 服务端 --注意用户名，地址，端口，模块名称 要完全匹配
rsync -avz --password-file=/etc/rsyncd.admin1.pass /tmp/backup rsync://admin1@172.30.1.11:50873/module1
# 非默认端口下传输文件  服务端 -> 客户端
rsync -avz --password-file=/tmp/test/a rsync://admin1@172.30.1.11:50873/module1 /tmp/backup

定时备份
将上面的命令放到 crontab/system.timer 里，设置定时的频率即可
