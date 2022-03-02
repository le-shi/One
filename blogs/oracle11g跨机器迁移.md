
> 原有机器故障，将 整个数据库软件和实例 迁移到新机器

1. 为了减少实例迁移产生其他问题，新旧机器的操作系统都是 `CentOS 7` (同一种包管理系列的操作系统，理论上这种迁移操作方法是通用的，但是没有测试过)

2. 在旧机器上停止 oracle 相关服务

   ```bash
   # 切换至 oracle 用户
   su - oracle
   # 停止监听
   lsnrctl stop

   # 进入数据库
   sqlplus / as sysdba
   # 停止数据库
   shutdown
   ```

3. 在新机器上创建对应的普通用户账号

   ```bash
   # 创建用户组
   groupadd oinstall && groupadd dba && useradd -g oinstall -G dba oracle
   # 设置 oracle 用户密码
   echo -n 'oracle:复杂的密码' | chpasswd
   ```

4. 同步相关文件

   ```bash
   # 在旧机器操作

   # 同步数据库软件目录，因为安装到了家目录下，所以同步的是家目录
   rsync -avzPh /home/oracle NEW_HOST_IP:/home/
   
   # 获取数据库实例安装目录
   su - oracle -c "env | grep ORACLE_HOME"
   # 同步数据库实例安装目录
   rsync -avzPh INSTALL_HOME NEW_HOST_IP:INSTALL_HOME
   
   # 同步声明文件
   rsync -avzPh /etc/oraInst.loc NEW_HOST_IP:/etc/
   rsync -avzPh /etc/oratab NEW_HOST_IP:/etc/
   ```

5. 同步内核参数

    ```
    # 在旧机器获取
    grep -Ev "#|^$" /etc/sysctl.conf

    # 在新机器载入
    echo '''
    vm.hugetlb_shm_group = 1001
    kernel.shmall = 4294967296
    kernel.shmmax = 68719476736
    kernel.shmmni = 4096
    kernel.sem = 250 32000 100 128
    net.ipv4.ip_local_port_range = 1024 65000
    net.core.rmem_default=4194304
    net.core.rmem_max=4194304
    net.core.wmem_default=262144
    net.core.wmem_max=262144
    ''' | tee -a /etc/sysctl.conf

    # 立即生效
    sysctl -p
    ```

6. 启动新机器的数据库

    ```bash
    # 切换只oracle用户
    su - oracle
    # 启动监听
    lsnrctl start

    # 进入数据库
    sqlplus / as sysdba
    # 启动数据库
    startup
    # 退出数据库
    exit

    # 查看监听状态
    lsnrctl status
    ```

7. 验证操作

    ```bash
    # 通过客户端工具连接
    # 查询数据
    ```
