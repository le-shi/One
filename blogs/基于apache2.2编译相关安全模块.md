# CentOS下源码安装apache2.2

### 编译需要的基础软件

    sudo yum -y install gcc gcc-c++ cmake

### 编译 apache 的 ssl 模块，启用模块需要的软件
#### 有 yum 源时
    
    sudo yum -y install zlib-devel openssl-devel

#### 无 yum 源时

    sudo rpm -ivh zlib-devel-1.2.7-18.el7.x86_64.rpm
    
    sudo rpm -ivh libcom_err-devel-1.42.9-17.el7.x86_64.rpm 
    sudo rpm -ivh keyutils-libs-devel-1.5.8-3.el7.x86_64.rpm 
    sudo rpm -ivh libverto-devel-0.2.5-4.el7.x86_64.rpm 
    sudo rpm -ivh libsepol-devel-2.5-10.el7.x86_64.rpm 
    sudo rpm -ivh pkgconfig-0.27.1-4.el7.x86_64.rpm 
    sudo rpm -ivh pcre-devel-8.32-17.el7.x86_64.rpm 
    sudo rpm -ivh libselinux-devel-2.5-15.el7.x86_64.rpm 
    sudo rpm -ivh krb5-devel-1.15.1-46.el7.x86_64.rpm 
    sudo rpm -ivh openssl-devel-1.0.2k-19.el7.x86_64.rpm 

### 安装 apr 依赖

    wget https://archive.apache.org/dist/apr/apr-1.5.2.tar.gz
    tar -zxf apr-1.5.2.tar.gz
    cd apr-1.5.2
    ./configure
    make -j $(nproc)
    sudo make install

    wget https://archive.apache.org/dist/apr/apr-util-1.5.4.tar.gz
    tar -zxf apr-util-1.5.4.tar.gz
    cd apr-util-1.5.4
    ./configure --with-apr=/usr/local/apr
    make -j $(nproc)
    sudo make install

### 安装 apache 2.2

    wget http://archive.apache.org/dist/httpd/httpd-2.2.32.tar.gz
    tar zxf httpd-2.2.32.tar.gz
    cd httpd-2.2.32
    # fix --> configure: error: ... Error, SSL/TLS libraries were missing or unusable
    export LDFLAGS=-ldl
    # 注意这里 --prefix 指定的安装目录 /home/user/apache2 是本文档举例使用，落地安装时根据自己(要求)环境修改安装目录
    ./configure --prefix=/home/user/apache2 --enable-ssl --with-ssl=/usr/local/openssl-1.0.2u --enable-proxy --enable-so --enable-mods-shared=all && make -j $(nproc) && sudo make install

### 动态添加mod_xx.so 模块

- `mod_jk.so`:

    ```bash
    # 下载现成的
    # 32位
    wget https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/binaries/linux/jk-1.2.31/i386/mod_jk-1.2.31-httpd-2.2.x.so
    # 64位
    wget https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/binaries/linux/jk-1.2.31/x86_64/mod_jk-1.2.31-httpd-2.2.x.so
    ```

    ```bash
    # 如果使用最新版本的 mod_jk ,需要自行编译
    # 下载源码
    wget http://archive.apache.org/dist/tomcat/tomcat-connectors/jk/tomcat-connectors-1.2.48-src.tar.gz
    # 解压
    tar -zxf tomcat-connectors-1.2.48-src.tar.gz
    # 切换到源码编译目录
    cd tomcat-connectors-1.2.48-src/native
    # 使用安装 apache 自带的工具 apxs 进行编译
    ./configure --with-apxs=/home/user/apache2/bin/apxs
    # 编译源码成 .so 文件
    make -j $(nproc)
    # 这时生成的 mod_jk.so 文件是存放在 apache-2.0 目录下的，需要手动拷贝到目录 ${APACHE_PREFIX_PATH}/modules 下面
    /bin/cp -v --backup --suffix=-$(date +%FT%T) apache-2.0/mod_jk.so /home/user/apache2/modules/
    ```


- `mod_security.so`:

    ```bash
    # 下载源码
    wget https://master.dl.sourceforge.net/project/mod-security/modsecurity-apache/1.9.5/modsecurity-apache_1.9.5.tar.gz?viasf=1 -O modsecurity-apache_1.9.5.tar.gz
    # 解压
    tar zxf modsecurity-apache_1.9.5.tar.gz
    # 切换到源码目录
    cd modsecurity-apache_1.9.5/apache2
    # 使用安装 apache 自带的工具 apxs 进行编译，执行完这句命令，mod_security.so 就已经安装到了目录 ${APACHE_PREFIX_PATH}/modules 下面
    /home/user/apache2/bin/apxs -aic mod_security.c
    ```

- `mod_qos.so`:

    ```bash
    # 官网 http://mod-qos.sourceforge.net/
    # 下载地址 https://sourceforge.net/projects/mod-qos/files/

    # 安装依赖
    sudo yum -y install pcre-devel pcre openssl-devel
    # 下载
    wget https://jaist.dl.sourceforge.net/project/mod-qos/mod_qos-11.66.tar.gz
    # 解压
    tar xf mod_qos-11.66.tar.gz
    # 切换到源码目录
    cd mod_qos-11.66/apache2
    # httpd 二进制文件必须支持动态加载的对象 (DSO)。通过检查mod_so的可用性来验证这一点：该命令 必须列出 mod_so.c 模块
    /home/user/apache2/bin/httpd -l
    # 使用安装 apache 自带的工具 apxs 进行编译，以下命令编译模块并将 mod_qos.so 安装到模块目录中
    /home/user/apache2/bin/apxs -i -c mod_qos.c -lcrypto -lpcre 
    ```

### 检查语法

    /home/user/apache2/bin/apachectl configtest
    或者
    /home/user/apache2/bin/httpd -t

### 启动

    /home/user/apache2/bin/apachectl start

### 查看端口

    ss -anplt | grep 80