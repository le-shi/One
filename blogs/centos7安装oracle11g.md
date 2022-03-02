# Centos7 安装 Oracle11g 11.2.0.4.0

> 验证过的系统: Centos6,Centos7

```bash
# 每个版本的oracle数据文件，安装方式有些差别
# 本安装文档是基于 oracle 11g 11.2.0.4.0 版本做的记录
# 安装过程中遇到问题，还请及时提出

云盘链接: https://pan.baidu.com/s/1Axxk2-P6vhk1zXJ0rNxe_Q 
提取码: 6my4
```

# 检查基本环境

## 安装依赖软件


```bash
# 定义 rpm 软件包列表
export RPM_LIST="binutils compat-libcap1  compat-libstdc++-33 compat-libstdc++-33*.i686 elfutils-libelf-devel gcc gcc-c++ glibc*.i686 glibc glibc-devel glibc-devel*.i686 ksh libgcc*.i686 libgcc libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.i686 libaio libaio*.i686 libaio-devel libaio-devel*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686 libXp libXext libXext-devel unzip"
```

> 在线


1. 配置国内 yum 源

    ```bash
    # Centos-Base源
    wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
    # epel源 - Centos6
    wget -O /etc/yum.repos.d/epel-6.repo http://mirrors.aliyun.com/repo/epel-6.repo
    # epel源 - Centos7
    wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo

    # 重建缓存
    yum clean all && yum makecache
    ```

2. 安装依赖软件

    ```bash
    # 安装
    yum -y install ${RPM_LIST}

    # 检查
    rpm -q ${RPM_LIST} | grep not
    如果包有显示is not installed(没安装)
    ```

> 离线

1. 本地提前下载好需要的rpm包

    ```bash
    # 下载工具包
    yum install yum-utils
    # 下载之前预览rpm包的下载地址
    yumdownloader --urls --resolve ${RPM_LIST}
    # 下载
    yumdownloader --resolve ${RPM_LIST}
    yumdownloader --resolve default-yama-scope
    yumdownloader --resolve basesystem
    yumdownloader --resolve libselinux
    yumdownloader --resolve libselinux-devel
    yumdownloader --resolve libsepol-devel
    yumdownloader --resolve pkgconfig
    yumdownloader --resolve libsepol
    yumdownloader --resolve chkconfig
    yumdownloader --resolve libxcb
    yumdownloader --resolve systemd-sysv
    ```

2. 本地打包

    ```bash
    tar -zcvf offline_install_oracle11g_rpms.tar.gz *.rpm
    ```

3. 上传离线rpm包到服务器，并依次安装

    ```bash
    mkdir -pv oracle-rpms
    tar -zxf offline_install_oracle11g_rpms.tar.gz -C oracle-rpms

    cd oracle-rpms

    rpm -ivh binutils-2.27-44.base.el7_9.1.x86_64.rpm 
    rpm -ivh compat-libcap1-1.10-7.el7.x86_64.rpm
    rpm -ivh compat-libstdc++-33-3.2.3-72.el7.x86_64.rpm
    rpm -ivh cpp-4.8.5-44.el7.x86_64.rpm
    rpm -ivh elfutils-libelf-0.176-5.el7.x86_64.rpm
    rpm -ivh elfutils-libelf-devel-0.176-5.el7.x86_64.rpm
    rpm -ivh elfutils-default-yama-scope-0.176-5.el7.noarch.rpm
    rpm -ivh elfutils-libs-0.176-5.el7.x86_64.rpm
    rpm -ivh gcc-4.8.5-44.el7.x86_64.rpm
    rpm -ivh gcc-c++-4.8.5-44.el7.x86_64.rpm
    rpm -ivh basesystem-10.0-7.el7.centos.noarch.rpm
    rpm -ivh glibc-2.17-325.el7_9.x86_64.rpm
    rpm -ivh libsepol-2.5-10.el7.x86_64.rpm
    rpm -ivh libsepol-devel-2.5-10.el7.x86_64.rpm
    rpm -ivh pkgconfig-0.27.1-4.el7.x86_64.rpm
    rpm -ivh libselinux-2.5-15.el7.x86_64.rpm
    rpm -ivh libselinux-devel-2.5-15.el7.x86_64.rpm
    rpm -ivh glibc-common-2.17-325.el7_9.x86_64.rpm
    rpm -ivh glibc-devel-2.17-325.el7_9.x86_64.rpm
    rpm -ivh glibc-headers-2.17-325.el7_9.x86_64.rpm

    rpm -ivh chkconfig-1.7.6-1.el7.x86_64.rpm
    rpm -ivh ksh-20120801-142.el7.x86_64.rpm
    rpm -ivh libaio-0.3.109-13.el7.x86_64.rpm
    rpm -ivh libaio-devel-0.3.109-13.el7.x86_64.rpm
    rpm -ivh libgcc-4.8.5-44.el7.x86_64.rpm
    rpm -ivh libgomp-4.8.5-44.el7.x86_64.rpm
    rpm -ivh libstdc++-4.8.5-44.el7.x86_64.rpm
    rpm -ivh libstdc++-devel-4.8.5-44.el7.x86_64.rpm
    rpm -ivh libtool-ltdl-2.4.2-22.el7_3.x86_64.rpm
    rpm -ivh libX11-common-1.6.7-4.el7_9.noarch.rpm
    rpm -ivh libX11-1.6.7-4.el7_9.x86_64.rpm
    rpm -ivh libX11-devel-1.6.7-4.el7_9.x86_64.rpm
    rpm -ivh libXau-devel-1.0.8-2.1.el7.x86_64.rpm
    rpm -ivh libxcb-1.13-1.el7.x86_64.rpm

    rpm -ivh libxcb-devel-1.13-1.el7.x86_64.rpm
    rpm -ivh libXext-1.3.3-3.el7.x86_64.rpm
    rpm -ivh libXext-devel-1.3.3-3.el7.x86_64.rpm
    rpm -ivh libXp-1.0.2-2.1.el7.x86_64.rpm
    rpm -ivh lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64.rpm
    rpm -ivh make-3.82-24.el7.x86_64.rpm
    rpm -ivh nspr-4.32.0-1.el7_9.x86_64.rpm
    rpm -ivh nss-softokn-freebl-3.67.0-3.el7_9.x86_64.rpm
    rpm -ivh nss-util-3.67.0-1.el7_9.x86_64.rpm
    rpm -ivh systemd-sysv-219-78.el7_9.3.x86_64.rpm
    rpm -ivh sysstat-10.1.5-19.el7.x86_64.rpm
    rpm -ivh unixODBC-2.3.1-14.el7.x86_64.rpm
    rpm -ivh unixODBC-devel-2.3.1-14.el7.x86_64.rpm
    rpm -ivh unzip-6.0-22.el7_9.x86_64.rpm
    rpm -ivh xorg-x11-proto-devel-2018.4-1.el7.noarch.rpm
    rpm -ivh zlib-1.2.7-19.el7_9.x86_64.rpm
    rpm -ivh zlib-devel-1.2.7-19.el7_9.x86_64.rpm

    # 检查
    rpm -q ${RPM_LIST} | grep not
    如果包有显示is not installed(没安装)
    ```

## 配置系统参数

1. 修改 ulimit 参数

    ```bash
    grep -Ev "#|^$" /etc/security/limits.conf
    
    oracle soft nofile 65536
    oracle hard nofile 65536
    oracle soft nproc 65536
    oracle hard nproc 65536
    oracle soft stack 65536
    oracle hard stack 65536
    ```

2. 修改内核参数

    ```bash
    # 没有 /etc/sysctl.conf 就创建一个
    grep -Ev "#|^$" /etc/sysctl.conf

    kernel.shmmax = 2147483648
    kernel.shmall = 2097152
    kernel.shmmni = 4096
    kernel.sem = 250 32000 100 128
    fs.file-max = 65536
    net.ipv4.ip_local_port_range = 1024 65000 
    net.core.rmem_default = 262144
    net.core.rmem_max = 262144
    net.core.wmem_default = 262144
    net.core.wmem_max = 262144

    # 使内核参数生效
    /sbin/sysctl -p
    ```

3. 修改主机名

    ```bash
    # 修改主机名
    hostnamectl set-hostname oracledb
    # 添加主机名与IP对应记录
    echo "$(hostname --all-ip-address | awk '{print $1}') oracledb" | tee -a /etc/hosts
    ```

4. 关闭 selinux 和 防火墙

    ```bash
    # 临时关闭 selinux
    setenforce 0
    # 永久关闭 selinux , 机器重启生效
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
    # 停止 firewalld 服务并禁用开机启动
    systemctl disable --now firewalld
    ```

## 开始安装

1. 创建组和用户

    ```bash
    # 添加组 oinstall
    groupadd oinstall
    # 添加组 dba
    groupadd dba
    # 添加用户 oracle , -g设置新账户主组的名称 , -G设置新账户附加组列表的名称
    useradd -g oinstall -G dba oracle
    ```

2. 创建 `/etc/oraInst.loc` 文件，并修改文件权限

    ```bash
    tee /etc/oraInst.loc <<EOF
    inventory_loc=/home/oracle/oracle/oraInventory
    inst_group=oinstall
    EOF

    chown oracle:oinstall /etc/oraInst.loc
    chmod 664 /etc/oraInst.loc
    ```

3. 切换到 oracle 用户，本次的安装目录是 /home/oracle/

4. 上传 oracle 数据库文件到 安装目录， 并解压

5. 解压

    ```bash
    cd /home/oracle
    unzip linux-oracle11g-64_1of7.zip
    unzip linux-oracle11g-64_2of7.zip
    ```

6. 修改响应文件模板，添加执行权限

    ```bash
    install --compare --verbose --mode=755 database/response/db_install.rsp database

    # 修改响应文件 -- vim database/db_install.rsp
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

7. 设置普通用户 oracle 的环境变量

    ```bash
    echo '''
    export ORACLE_BASE=/home/oracle/oracle
    export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1
    export PATH=$PATH:$ORACLE_HOME/bin
    export ORACLE_SID=orcl
    export NLS_LANG=AMERICAN_AMERICA.ZHS16GBK
    ''' | tee -a ~/.bash_profile

    # 加载环境变量
    source ~/.bash_profile
    ```

8. 使用响应文件安装数据库软件

    ```bash
    # 切换到解压目录
    cd /home/oracle/database
    # 采用静默方式 , 安装数据库软件
    ./runInstaller -silent -responsefile /home/oracle/database/db_install.rsp -ignoresysprereqs -ignoreprereq


    安装过程中:

    如果提示[WARNING]可以忽略，安装程序仍在进行；
    如果出现[FATAL]，说明安装程序已经停止，请检查错误日志。
    若安装失败清理/etc/oratab文件，重新安装。
    查看安装日志信息了解安装进度

    tail -f -n 200 $ORACLE_BASE/oraInventory/logs/installActions*.log

    出现类似如下提示表示安装完成：

    Oracle Database 11g 的 安装 已成功。

    以 root 用户的身份执行以下脚本:
        1. /home/oracle/oracle/product/11.2.0/db_1/root.sh

    Successfully Setup Software.
    ```

9. 使用root用户执行root.sh

    ```bash
    /home/oracle/oracle/product/11.2.0/db_1/root.sh
    ```

10. 安装数据库实例

    ```bash
    dbca -silent \
        -createDatabase 
        -templateName /home/oracle/oracle/product/11.2.0/db_1/assistants/dbca/templates/General_Purpose.dbc \
        -gdbName orcl \
        -sid orcl \
        -sysPassword oracle \
        -systemPassword oracle \
        -emConfiguration LOCAL \
        -dbsnmpPassword oracle \
        -sysmanPassword oracle \
        -characterSet al32utf8


    ---
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
    # 开始安装
    Copying database files
    1% complete
    37% complete
    Creating and starting Oracle instance
    40% complete
    62% complete
    Completing Database Creation
    66% complete
    100% complete
    Look at the log file "/home/oracle/oracle/cfgtoollogs/dbca/orcl/orcl.log" for further details.
    # 安装结束

    提示`java.lang.UnsatisfiedLinkError: /home/oracle/oracle/product/11.2.0/db_1/lib/libnjni11.so: libclntsh.so.11.1: cannot open shared object file: No such file or directory`错误，需要删除 /home/oracle/oracle /etc/oratab ，重新确认依赖包是否安装全，然后安装数据库软件和数据库实例
    ```

    1. 检查安装

    ```bash
    # lsnrctl 查看监听
    lsnrctl status

    # sqlplus 登陆数据库, 查看实例状态
    SQL> select open_mode from v$database; 
    OPEN_MODE
    ----------
    READ WRITE
    ```

11. 可选 - 开启归档日志

    ```
    sqlplus / as sysdba
    SQL> --关闭数据库
    SQL> shutdown immediate;
    SQL> --启动到mount状态
    SQL> startup mount;
    SQL> --开启归档模式
    SQL> alter database archivelog;
    SQL> --如果要启用数据库闪回功能则执行 - 可选
    SQL> alter database flashback on;
    SQL> --启动数据库
    SQL> alter database open;
    SQL> --重新编译所有可能失效对象
    SQL> execute utl_recomp.recomp_serial();
    SQL> --手工归档测试
    SQL> alter system archive log current;
    ```

## 初次安装数据库后的操作

1. 修改用户密码有效期

    ```sql
    SQL> --查看密码有效期
    SQL> SELECT * FROM dba_profiles s WHERE s.profile='DEFAULT' AND resource_name='PASSWORD_LIFE_TIME';
    SQL> --将密码有效期由默认的180天修改成 "无限期"
    SQL> ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
    SQL> --修改之后不需要重启动数据库，会立即生效。
    ```

2. 修改最大连接数(须重启数据库)

    ```sql
    SQL> --查看当前数据库的最大连接数
    SQL> select value from v$parameter where name = 'processes';
    SQL> --修改最大连接数为 3000
    SQL> alter system set processes = 3000 scope = spfile;
    SQL> --停止数据库实例
    SQL> shutdown immediate;
    SQL> --启动数据库实例
    SQL> startup;
    ```

3. 可选 - 修改归档区大小(须重启数据库)

    ```sql
    SQL> --查看当前归档区大小
    SQL> show parameter db_recovery_file_dest_size;
    SQL> --修改归档区为10G
    SQL> alter system set db_recovery_file_dest_size=10G scope=spfile;
    SQL> --停止数据库实例
    SQL> shutdown immediate;
    SQL> --启动数据库实例
    SQL> startup;
    ```

4. 创建普通(业务)用户

    ```sql
    SQL> --创建用户，设置密码
    SQL> create user username identified by password;
    SQL> --授于用户连接、登录权限
    SQL> grant dba,connect,resource to username;
    ```

5. 系统防火墙开放默认1521端口

    ```bash
    iptables -A INPUT -p tcp --dport 1521 -j ACCEPT
    iptables -A OUTPUT -p tcp --sport 1521 -j ACCEPT
    ```

6. 设置开机自启动

    ```bash
    # 文件 /etc/oratab 内, 参数为 Y
    grep -Ev "#|^$" /etc/oratab
    orcl:/home/oracle/oracle/product/11.2.0/db_1:Y
    # 如果是 N ，使用下面的命令修改
    sed -i 's/:N/:Y/g' /etc/oratab

    # 文件 /etc/rc.d/rc.local 有执行权限
    chmod +x /etc/rc.d/rc.local


    # 第一种
    echo "su - oracle -c 'lsnrctl start && dbstart'" | tee -a /etc/rc.d/rc.local

    # 第二种 
    vim +78 $ORACLE_HOME/bin/dbstart
    ORACLE_HOME_LISTNER=/home/oracle/oracle/product/11.2.0/db_1
    echo  "su - oracle -c 'dbstart'" >> /etc/rc.d/rc.local

    # 第三种
    echo "su - oracle -c 'lsnrctl start && dbstart'" | tee /etc/init.d/oracle
    chmod +x /etc/init.d/oracle
    ```

## 其他命令

```bash
# 查看监听器状态
lsnrctl status
# 开启监听
lsnrctl start
# 停止监听
lsnrctl stop

# 通过 dbstart 和 dbshut 启停数据库
# 修改oracle启动配置文件
sed -i 's/:N/:Y/' /etc/oratab
# 设置Y可以通过 dbstart 启动此实例和监听器。(开启数据库)
dbstart $ORACLE_HOME
# 通过 dbstart 停止此实例和监听器。(关闭数据库)
dbshut $ORACLE_HOME
```
