#Centos6.x
#Centos7.5.1804
```
#每个版本的oracle数据文件，安装方式有些差别
#本安装文档是基于 oracle 11g 11.2.0.4.0 版本做的记录
#安装过程中遇到问题，还请及时提出
BaiDY
链接: https://pan.baidu.com/s/1Axxk2-P6vhk1zXJ0rNxe_Q 
提取码: 6my4
```
##一、检查基本环境
1. 依赖环境
参考网络yum源
- Centos源:wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo && yum clean all && yum makecache && yum -y update
- epel源（Centos5）:wget -O /etc/yum.repos.d/epel-5.repo mirrors.aliyun.com/repo/epel-5.repo && yum clean all && yum makecache
- epel源（Centos6）:wget -O /etc/yum.repos.d/epel-6.repo mirrors.aliyun.com/repo/epel-6.repo && yum clean all && yum makecache
- epel源（Centos7）:wget -O /etc/yum.repos.d/epel-7.repo mirrors.aliyun.com/repo/epel-7.repo && yum clean all && yum makecache

先对操作系统进行一次全面的更新
```shell
yum -y install \
binutils \
compat-libcap1  \
compat-libstdc++-33 \
compat-libstdc++-33*.i686 \
elfutils-libelf-devel \
gcc \
gcc-c++ \
glibc*.i686 \
glibc \
glibc-devel \
glibc-devel*.i686 \
ksh \
libgcc*.i686 \
libgcc \
libstdc++ \
libstdc++*.i686 \
libstdc++-devel \
libstdc++-devel*.i686 \
libaio \
libaio*.i686 \
libaio-devel \
libaio-devel*.i686 \
make \
sysstat \
unixODBC \
unixODBC*.i686 \
unixODBC-devel \
unixODBC-devel*.i686 \
libXp \
libXext \
libXext-devel
```

检查安装依赖系统包

```
rpm -q binutils compat-libstdc++-33 elfutils-libelf elfutils-libelf-devel gcc gcc-c++ glibc-2.5 glibc-common glibc-devel glibc-headers ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make sysstat unixODBC unixODBC-devel | grep not
```
如果包有显示is not installed(没安装)
针对RedHat系统可能需要rpm包安装，本地挂载光盘后进入挂载目录
依次执行安装：

修改内核参数
```
vim /etc/security/limits.conf
-------------------------------------
oracle soft nofile 65536
oracle hard nofile 65536
oracle soft nproc 65536
oracle hard nproc 65536
oracle soft stack 65536
oracle hard stack 65536

vim /etc/sysctl.conf
---------------------------------------------
修改的
kernel.shmmax = 2147483648
kernel.shmall = 2097152
新增的
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
fs.file-max = 65536
net.ipv4.ip_local_port_range = 1024 65000 
net.core.rmem_default = 262144
net.core.rmem_max = 262144
net.core.wmem_default = 262144
net.core.wmem_max = 262144

使内核参数生效
/sbin/sysctl -p
```


2. 主机名
修改主机名>>查看主机名>>重启
`[root@linux ~]# sed -i "s/HOSTNAME=localhost.localdomain/HOSTNAME=oracledb/" /etc/sysconfig/network`
`[root@linux ~]# reboot`
添加主机名与IP对应记录
` [root@linux ~]# vi /etc/hosts `
`IP    oracledb`
关闭Selinux
`[root@linux ~]# setenforce 0`

3. 创建用户、组
创建所需的操作系统组和用户
`[root@linux ~]# groupadd oinstall && groupadd dba && useradd -g oinstall -G dba oracle`
设置oracle用户密码
`[root@linux ~]# echo -n 'oracle:oracle' | chpasswd`

4. 创建`/etc/oraInst.loc`文件
```shell
tee /etc/oraInst.loc <<EOF
inventory_loc=/home/oracle/oracle/oraInventory
inst_group=oinstall
EOF
```
5. 更改文件的权限
```shell
chown oracle:oinstall /etc/oraInst.loc && chmod 664 /etc/oraInst.loc
```

##二、准备安装

1. 上传文件
(文件上传到/home/oracle/下，创建oracle用户自动创建oracle目录)
！！！传文件！！！
2. 解压文件
解压oracle安装文件(文件须上传到/home/oracle/下,oracle用户执行)
`[root@linux ~]# su - oracle`
`[oracle@linux ~]$ unzip linux-oracle11g-64_1of7.zip && unzip linux-oracle11g-64_2of7.zip`
3. 更改模板文件
拷贝模板文件，授权
`[oracle@linux ~]$ cp /home/oracle/database/response/db_install.rsp /home/oracle/database`
`[oracle@linux ~]$ chmod +x /home/oracle/database/db_install.rsp`
4. 设置oracle环境变量
`[oracle@linux ~]$ vim ~/.bash_profile`

在最后加上以下内容
```
export ORACLE_BASE=/home/oracle/oracle
export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin$PATH:$ORACLE_HOME/bin
export ORACLE_SID=orcl
export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
```
使设置生效
`[oracle@linux ~]$ source /home/oracle/.bash_profile`
检查环境变量：
`[oracle@linux ~]$ env`
5. 安装Oracle软件
 修改安装Oracle软件的响应文件/home/oracle/database/db_install.rsp
 ```
oracle.install.option=INSTALL_DB_SWONLY // 安装类型
ORACLE_HOSTNAME=oracledb // 主机名称
UNIX_GROUP_NAME=oinstall // 安装组
INVENTORY_LOCATION=/home/oracle/oracle/oraInventory // INVENTORY目录
SELECTED_LANGUAGES=en,zh_CN // 选择语言
ORACLE_HOME=/home/oracle/oracle/product/11.2.0/db_1 // oracle_home
ORACLE_BASE=/home/oracle/oracle // oracle_base
oracle.install.db.InstallEdition=EE // oracle版本
oracle.install.db.EEOptionsSelection=true
oracle.install.db.DBA_GROUP=dba // dba用户组
oracle.install.db.OPER_GROUP=oinstall // oper用户组
DECLINE_SECURITY_UPDATES=true
oracle.installer.autoupdates.option=SKIP_UPDATES
```

进到解压目录，安装数据库软件

```
cd /home/oracle/database
./runInstaller -silent -responsefile /home/oracle/database/db_install.rsp -ignoresysprereqs -ignoreprereq

`#(./runInstaller -silent -force -responseFile /home/oracle/etc/db_install.rsp)`
```

安装过程中:
+ 如果提示[WARNING]可以忽略，安装程序仍在进行；
+ 如果出现[FATAL]，说明安装程序已经停止，请检查错误日志。

若安装失败清理/etc/oratab文件，重新安装。
查看安装日志信息了解安装进度
 
`[oracle@linux ~]$ cd $ORACLE_BASE/oraInventory/logs`
`tail -100f installActions*.log`
出现类似如下提示表示安装完成：
------------------------------------------------------------------

/home/oracle/oracle/product/11.2.0/db_1/root.sh
To execute the configuration scripts:
1. Open a terminal window 
2. Log in as "root" 
3. Run the scripts 
4. Return to this window and hit "Enter" key to continue
 
Successfully Setup Software.

-------------------------------------------------------------------

使用root用户执行root.sh
 
su - root
`[root@linux ~]# /home/oracle/oracle/product/11.2.0/db_1/root.sh`
6.安装数据库
```shell
dbca -silent -createDatabase -templateName /home/oracle/oracle/product/11.2.0/db_1/assistants/dbca/templates/General_Purpose.dbc -gdbName orcl -sid orcl -sysPassword oracle -systemPassword oracle  -emConfiguration LOCAL -dbsnmpPassword oracle -sysmanPassword oracle -characterSet al32utf8
```


|使用参数说明||
|-|-|
|-silent|指以静默方式执行dbca命令|
|-createDatabase|指使用dbca|
|-templateName|指定用来创建数据库的模板名称，这里指定为/home/oracle/oracle/product/11.2.0/db_1/assistants/dbca/templates/General_Purpose.dbc，即一般用途的数据库模板|
|-gdbName|指定创建的全局数据库名称，这里指定名称为orcl|
|-sid |指定数据库系统标识符，这里指定为orcl，与数据库同名|
|-sysPassword| SYS 用户口令设置为oracle|
|-systemPassword   |SYSTEM 用户口令设置为oracle|
|-emConfiguration  |指定Enterprise Management的管理选项。LOCAL表示数据库由Enterprise Manager本地管理|
|-dbsnmpPassword   DBSNMP |用户口令设置为oracle|
|-sysmanPassword   SYSMAN |用户口令设置为oracle|
|-characterSet| 指定数据库使用的字符集，这里指定为al32utf8|

执行命令，检查安装，显示如下:(100%进度非常快，安装失败)
//开始安装
Copying database files
1% complete
37% complete
Creating and starting Oracle instance
40% complete
62% complete
Completing Database Creation
66% complete
100% complete
Look at the log file "/home/oracle/oracle/cfgtoollogs/dbca/orcl/orcl.log" for further details.//安装结束

提示`java.lang.UnsatisfiedLinkError: /home/oracle/oracle/product/11.2.0/db_1/lib/libnjni11.so: libclntsh.so.11.1: cannot open shared object file: No such file or directory`错误


7. 检查安装
`[oracle@linux ~]$ lsnrctl status`
安装成功则最终会显示：The command completed successfully
修改oracle启动配置文件
`[oracle@linux ~]$ vi /etc/oratab`
`racl:/home/oracle/oracle/product/11.2.0/db_1:Y` //把“N”改成“Y”
 `$ORACLE_SID:$ORACLE_HOME:Y:`
 设置Y可以通过dbstart 启动此实例，监听器。(开数据库)
`[oracle@linux ~]$ dbstart $ORACLE_HOME`
所有oracle的进程关闭，监听器也停止。 (关数据库)
`[oracle@linux ~]$ dbshut $ORACLE_HOME`

8. 归档检查：(带* 必须执行)
```
sqlplus / as sysdba
SQL> shutdown immediate; --关闭数据库*
SQL> startup mount;  --启动到mount状态*
SQL> alter database archivelog; --开启归档模式*
SQL> alter database flashback on;  --如果要启用数据库闪回功能则执行
SQL> alter database open;  --启动数据库*
SQL> execute utl_recomp.recomp_serial();  --重新编译所有可能失效对象
SQL> alter system archive log current;  --手工归档测试*
```
9. sqlplus登陆数据库,查看启动状态
```
sqlplus 账户名/密码 as sysdba(角色名)
SQL> select open_mode from v$database; //查询实例状态
OPEN_MODE
----------
READ WRITE   //启动成功
SQL> startup nomount;  //启动为mount模式
SQL> select status from v$instance;
SQL> select open_mode from v$database;
SQL> alter database mount;
SQL> select status from v$instance;
SQL> select open_mode from v$database;查询实例状态
SQL> alter database open;
SQL> select status from v$instance; 

```
10. 监听程序
lsnrctl status查看监听器状态
lsnrctl start开启监听
lsnrctl stop 停止监听
11. 初次安装数据库后的操作
 (1). 查看密码有效期：
`SQL> SELECT * FROM dba_profiles s WHERE s.profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';`
将密码有效期由默认的180天修改成“无限制”：
`SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;`
修改之后不需要重启动数据库，会立即生效。
(2). 修改最大连接数(须重启数据库)
`SQL> select value from v$parameter where name = 'processes'; `--数据库的最大连接数
`SQL> alter system set processes = 3000 scope = spfile;` --修改最大连接数:
(3). 修改归档区大小（确定数据库是关闭的或者修改完重启数据库 )
`SQL> show parameter db_recovery_file_dest_size;` --查看当前归档区大小
`SQL> alter system set db_recovery_file_dest_size=10G scope=spfile;` --修改归档区为10G
`SQL> alter database open;`
`SQL> alter database open noresetlogs;`
重启数据库:
`SQL> shutdown immediate;`
`SQL> startup;`
(4). 创建业务用户
`SQL> create user zjutr_db identified by zjutr_db;` --创建用户，设置密码
`SQL> grant connect,resource to zjutr_db;` --授于用户连接、登录权限

系统防火墙开放默认1521端口
`iptables -A INPUT -p tcp --dport 1521 -j ACCEPT`
`iptables -A OUTPUT -p tcp --sport 1521 -j ACCEPT`

(5).设置开机启动
*确保/etc/oratab-`orcl:/home/oracle/oracle/product/11.2.0/db_1:Y`参数为Y*
*确保/etc/rc.d/rc.local有执行权限`chmod +x /etc/rc.d/rc.local`*
第I种.  
`echo "su - oracle -c 'lsnrctl start && dbstart'" >> /etc/rc.d/rc.local`
第II种. 
`vim +78 $ORACLE_HOME/bin/dbstart`
`ORACLE_HOME_LISTNER=/home/oracle/oracle/product/11.2.0/db_1`
`echo  "su - oracle -c 'dbstart'" >> /etc/rc.d/rc.local`

