Alibaba Cloud Linux 是阿里云推出的 Linux 服务器操作系统，它为云上应用程序环境提供 Linux 社区的最新增强功能，在提供云上最佳用户体验的同时，也针对阿里云基础设施做了深度的优化。Alibaba Cloud Linux 服务器操作系统可以运行在阿里云云服务器全规格系列 VM 实例上，包括弹性裸金属服务器 。

阿里云操作系统版本: `Alibaba Cloud Linux (Aliyun Linux) release 2.1903 LTS (Hunting Beagle)`

<https://www.zabbix.com/download?zabbix=5.0&os_distribution=centos&os_version=7&db=mysql&ws=nginx>

zabbix版本: 5.0
操作系统: CentOS
系统版本: 7
数据库: mysql
web服务: nginx

服务端
---

1. 安装Zabbix库

    ```bash
    rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
    yum clean all
    # 替换成阿里云的源，加速下载包
    sed -i 's@repo.zabbix.com@mirrors.aliyun.com/zabbix@g'  /etc/yum.repos.d/zabbix.repo
    ```

2. 安装Zabbix服务器和代理

    ```
    yum install zabbix-server-mysql zabbix-agent

    # 安装一个测试工具
    yum install zabbix-get
    ```

3. 安装Zabbix前端

    打开红帽软件集合

    > 阿里云系统: 按照官网提供的步骤，执行 `yum install centos-release-scl` 提示 `没有可用软件包 centos-release-scl` ，这里手动下载rpm包进行安装

    ```shell
    rpm -ivh http://mirror.centos.org/centos/7/extras/x86_64/Packages/centos-release-scl-rh-2-3.el7.centos.noarch.rpm
    ```

    编辑文件 /etc/yum.repos.d/zabbix.repo 并打开 zabbix-frontend 仓库

    ```repo
    [zabbix-frontend]
    ...
    enabled=1
    ...
    ```

    安装Zabbix前端包

    ```shell
    yum install zabbix-web-mysql-scl zabbix-nginx-conf-scl
    ```

4. 创建初始数据库

    ```
    yum -y install mariadb-server
    systemctl enable --now mariadb
    '/usr/bin/mysqladmin' -u root password 'new-password'
    确保数据库服务器启动并运行。
    在数据库主机上运行以下。
    # mysql -uroot -p
    password
    mysql> create database zabbix character set utf8 collate utf8_bin;
    mysql> create user zabbix@localhost identified by 'password';
    mysql> grant all privileges on zabbix.* to zabbix@localhost;
    mysql> quit;
    ```

    Zabbix服务器主机上导入初始模式和数据。系统将提示您输入您新创建的密码。

    ```
    zcat /usr/share/doc/zabbix-server-mysql*/create.sql.gz | mysql -uzabbix -p zabbix
    ```

5. Zabbix服务器配置数据库

    Edit file /etc/zabbix/zabbix_server.conf
    ```
    DBPassword=password
    ```

6. 为Zabbix前端配置PHP

    编辑文件 /etc/opt/rh/rh-nginx116/nginx/conf.d/zabbix.conf , 取消注释“listen”和“server_name”指令

    ```
    # listen 80;
    # server_name example.com;
    ```

    编辑 /etc/opt/rh/rh-nginx116/nginx/nginx.conf ，注释 IPV4和IPV6的两条 "listen" 指令

    ```
    listen       80 default_server;
    listen       [::]:80 default_server;
    ```

    编辑 /etc/opt/rh/rh-php72/php-fpm.d/zabbix.conf 文件，添加 nginx listen.acl_users 指令。

    ```
    listen.acl_users = apache,nginx
    ```

    然后取消注释，为自己设置正确的时区。

    ```
    ; php_value[date.timezone] = Europe/Riga
    
    php_value[date.timezone] = Asia/Shanghai
    ```

1. 启动Zabbix服务器和代理进程

    启动Zabbix服务器和代理进程，并使其在系统引导时启动。
    ```shell
    systemctl restart zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm
    systemctl enable zabbix-server zabbix-agent rh-nginx116-nginx rh-php72-php-fpm
    ```

8. 配置Zabbix前端

    连接到新安装的Zabbix前端: http://server_ip_or_name

9. 开始使用Zabbix

    默认账号密码: `Admin`/`zabbix`

    登录后
    - 配置中文界面: 左下角"User settings"，语言: en_GB => zh_CN，点击"update"，
    - 自动发现主机
      - 配置
        - 动作 "自动注册": 
          - 条件：当 元数据=linux
          - 动作：添加linux主机; 添加linuxservices群组; 关联linux模板
    - 实现微信报警
    - 中文乱码: 复制字体到server端的 `/usr/share/zabbix/assets/fonts` 字体目录下，注意文件权限 `664` ，切换到字体目录下制作软连接 `ln -sf SIMSUN.TTC graphfont.ttf` ，直接刷新页面即可

客户端
---

1. 客户端(zabbix_agent)和服务端(zabbix_server)的10051端口要互通

2. 下载zabbix源/下载软件包

    ```
    # 如果可以使用yum源
    rpm -Uvh https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-release-5.0-1.el7.noarch.rpm
    # 替换阿里源
    sed -i 's@repo.zabbix.com@mirrors.aliyun.com/zabbix@g'  /etc/yum.repos.d/zabbix.repo

    # 如果访问不到yum源的，手动下载软件包
    wget https://repo.zabbix.com/zabbix/5.0/rhel/7/x86_64/zabbix-agent-5.0.18-1.el7.x86_64.rpm
    ```

1. 安装

    ```
    # 如果可以使用yum源
    yum install zabbix-agent

    # 如果访问不到yum源，使用下载的软件包进行安装
    rpm -ivh zabbix-agent-5.0.18-1.el7.x86_64.rpm
    ```

1. 修改配置 /etc/zabbix/zabbix_agent.conf

    ```
    # 被动模式(客户端只会等待服务端收集数据)的 Server IP
    Server=zabbix服务器IP
    # 主动模式(客户端主动向服务端发送数据)的 Server IP(纯主动模式下的zabbix agent，只能支持Zabbix Agent (Active)类型的监控项)
    ServerActive=zabbix服务器IP
    # 客户端的hostname
    Hostname=主机名
    HostMetadata=linux
    ```

1. 启动服务

    ```
    systemctl enable --now zabbix-agent
    ```
