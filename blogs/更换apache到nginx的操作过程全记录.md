# apache to nginx

## 1. 安装

> 有两种安装方式,yum安装和源码编译安装，下面分别介绍两种安装方式，根据自己情况采取其中一种进行安装

### 安装方法1: yum安装

1. 安装依赖: `yum install yum-utils`
2. 将下面内容写入到 `/etc/yum.repos.d/nginx.repo` 文件中:

    ```repo
    [nginx-stable]
    name=nginx stable repo
    baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=1
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true

    [nginx-mainline]
    name=nginx mainline repo
    baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
    gpgcheck=1
    enabled=0
    gpgkey=https://nginx.org/keys/nginx_signing.key
    module_hotfixes=true
    ```

3. 安装: `yum install nginx`
4. 检查安装版本: `nginx -V`
5. 设置开机启动: `chkconfig nginx on`
6. 查看开机启动(2-5启用就可以): `chkconfig --list nginx`

### 安装方法2: 源码编译安装

1. 下载nginx安装包 <http://nginx.org/download/nginx-1.20.0.tar.gz>
2. 安装依赖

    ```bash
    # 安装 pcre 依赖
    https://ftp.pcre.org/pub/pcre/pcre-8.44.tar.gz

    tar -zxf pcre-8.44.tar.gz
    cd pcre-8.44
    ./configure 
    make -j $(nproc)
    make install
    pcre-config --version

    # 安装 zlib 依赖
    http://www.zlib.net/zlib-1.2.11.tar.gz
    tar -zxf zlib-1.2.11.tar.gz 
    cd zlib-1.2.11
    ./configure 
    make -j $(proc)
    make install

    # 安装 openssl 依赖
    https://www.openssl.org/source/openssl-1.1.1k.tar.gz
    tar -zxf openssl-1.1.1k.tar.gz 
    cd openssl-1.1.1k
    ./config 
    make -j $(nproc)
    make install

    # 创建软连接
    ln -s /usr/local/lib/libpcre.so /lib64/libpcre.so.1
    ln -s /usr/local/lib64/libssl.so /lib64/libssl.so.1.1
    ln -s /usr/local/lib64/libcrypto.so /lib64/libcrypto.so.1.1
    ```

3. 解压: `tar -zxf nginx-1.20.0.tar.gz`
4. 切换目录: `cd nginx-1.20.0`
5. 配置并设置编译参数

    ```shell
    ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --with-perl_modules_path=/usr/lib/perl5/vendor_perl --with-compat --with-file-aio --with-threads --with-http_addition_module --with-http_auth_request_module --with-http_dav_module --with-http_flv_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_mp4_module --with-http_random_index_module --with-http_realip_module --with-http_secure_link_module --with-http_slice_module --with-http_ssl_module --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-mail --with-mail_ssl_module --with-stream --with-stream_realip_module --with-stream_ssl_module --with-stream_ssl_preread_module --with-cc-opt='-Os -fomit-frame-pointer -g' --with-ld-opt=-Wl,--as-needed
    ```

6. 编译: `make -j $(nproc)`
7. 安装: `make install`
8. 检查安装版本: `nginx -V`
9. 设置开机启动需要单独使用脚本处理，脚本如下

    ```bash
    #!/bin/sh
    #
    # nginx - this script starts and stops the nginx daemon
    #
    # chkconfig:   - 85 15
    # description:  Nginx is an HTTP(S) server, HTTP(S) reverse \
    #               proxy and IMAP/POP3 proxy server
    # processname: nginx
    # config:      /etc/nginx/nginx.conf
    # config:      /etc/sysconfig/nginx
    # pidfile:     /var/run/nginx.pid

    # Source function library.
    . /etc/rc.d/init.d/functions

    # Source networking configuration.
    . /etc/sysconfig/network

    # Check that networking is up.
    [ "$NETWORKING" = "no" ] && exit 0

    nginx="/usr/sbin/nginx"
    prog=$(basename $nginx)

    sysconfig="/etc/sysconfig/$prog"
    lockfile="/var/lock/subsys/nginx"
    pidfile="/var/run/${prog}.pid"

    NGINX_CONF_FILE="/etc/nginx/nginx.conf"

    [ -f $sysconfig ] && . $sysconfig


    start() {
        [ -x $nginx ] || exit 5
        [ -f $NGINX_CONF_FILE ] || exit 6
        echo -n $"Starting $prog: "
        daemon $nginx -c $NGINX_CONF_FILE
        retval=$?
        echo
        [ $retval -eq 0 ] && touch $lockfile
        return $retval
    }

    stop() {
        echo -n $"Stopping $prog: "
        killproc -p $pidfile $prog
        retval=$?
        echo
        [ $retval -eq 0 ] && rm -f $lockfile
        return $retval
    }

    restart() {
        configtest_q || return 6
        stop
        start
    }

    reload() {
        configtest_q || return 6
        echo -n $"Reloading $prog: "
        killproc -p $pidfile $prog -HUP
        echo
    }

    configtest() {
        $nginx -t -c $NGINX_CONF_FILE
    }

    configtest_q() {
        $nginx -t -q -c $NGINX_CONF_FILE
    }

    rh_status() {
        status $prog
    }

    rh_status_q() {
        rh_status >/dev/null 2>&1
    }

    # Upgrade the binary with no downtime.
    upgrade() {
        local oldbin_pidfile="${pidfile}.oldbin"

        configtest_q || return 6
        echo -n $"Upgrading $prog: "
        killproc -p $pidfile $prog -USR2
        retval=$?
        sleep 1
        if [[ -f ${oldbin_pidfile} && -f ${pidfile} ]];  then
            killproc -p $oldbin_pidfile $prog -QUIT
            success $"$prog online upgrade"
            echo 
            return 0
        else
            failure $"$prog online upgrade"
            echo
            return 1
        fi
    }

    # Tell nginx to reopen logs
    reopen_logs() {
        configtest_q || return 6
        echo -n $"Reopening $prog logs: "
        killproc -p $pidfile $prog -USR1
        retval=$?
        echo
        return $retval
    }

    case "$1" in
        start)
            rh_status_q && exit 0
            $1
            ;;
        stop)
            rh_status_q || exit 0
            $1
            ;;
        restart|configtest|reopen_logs)
            $1
            ;;
        force-reload|upgrade) 
            rh_status_q || exit 7
            upgrade
            ;;
        reload)
            rh_status_q || exit 7
            $1
            ;;
        status|status_q)
            rh_$1
            ;;
        condrestart|try-restart)
            rh_status_q || exit 7
            restart
            ;;
        *)
            echo $"Usage: $0 {start|stop|reload|configtest|status|force-reload|upgrade|restart|reopen_logs}"
            exit 2
    esac
    ```

10. 将上面的脚本负责保存到 /etc/init.d/nginx 并赋予执行权限: `chmod +x /etc/init.d/nginx`
11. 设置开机启动: `chkconfig nginx on`
12. 查看开机启动(2-5启用就可以): `chkconfig --list nginx`

## 2. 配置文件的转换

- 地址: <https://www.winginx.com/en/htaccess>
- 备用: <http://tools.jb51.net/aideddesign/htaccess2nginx>

apache -> nginx 名词对比

```txt
DocumentRoot -> root 网站主目录
ServerName -> server_name 域名
ServerAlias -> server_name 多个域名使用空格分隔
JkMount -> proxy_pass ajp换成http方式
VirtualHost *:80 -> listen 80 监听端口
DirectoryIndex -> index 首页格式
ProxyPass -> proxy_pass 反向代理
AddOutputFilter INCLUDES .shtml -> ssi 服务器端嵌入
RewriteRule -> if 处理rewrite规则
Deny from all -> deny all 指定路径拒绝
Header -> add_header 添加http头信息

```

### 例子 1 - 带有网站目录的 Tomcat 反向代理

```apache
# apache
<VirtualHost *:80>
    <Directory "/home/tomcat/webapps/portal">
        Options FollowSymLinks MultiViews Includes
        AllowOverride None
        Order allow,deny
        Allow from all  
        RewriteEngine  on
        rewritebase /scolumn
        RewriteCond %{REQUEST_METHOD} ^(OPTIONS)
        RewriteRule .* - [F]

        <Files ~ "/WEB-INF/web.xml">
            Order allow,deny
            Deny from all
        </Files>
        <Files ~ "/portal/bid/data/list/items">
            Order allow,deny
            Deny from all
       </Files>
    </Directory>

    DocumentRoot /home/tomcat/webapps/portal/
    JkMount /portal/* portal
    JkMount /sso/* sso    
    Include conf/mod_security.conf

    ServerName portal.example.com
    ServerAlias portal2.example.com
    DirectoryIndex index.shtml index.jsp
    CustomLog "|/home/apache2/bin/rotatelogs /home/apache2/logs/portal.example.com-access%Y-%m-%d.log 86400" common
</VirtualHost>
```

```nginx
# nginx
server{
    # VirtualHost *:80 -> listen 80 监听端口
    listen 80;
    # ServerName -> server_name 域名, ServerAlias -> server_name 多个域名使用空格分隔
    server_name portal.example.com portal2.example.com;

    # DocumentRoot -> root 网站主目录
    root /home/tomcat/webapps/portal;
    # DirectoryIndex -> index 首页格式
    index index.shtml index.jsp;

    # INCLUDE -> ssi 服务器端嵌入
    ssi on;
    ssi_silent_errors on;
    ssi_types text/shtml;

    # RewriteRule -> if 处理rewrite规则
    location /scolumn/ {
      if ($request_method ~ "^(OPTIONS)"){
        return 403;
      }
    }

    # Deny from all -> deny all 指定路径拒绝
    location ~ /WEB-INF/web.xml {
      deny all;
    }
    location ~ /portal/bid/data/list/items {
      deny all;
    }

    # JkMount -> proxy_pass ajp换成http方式
    location ^~ /portal {
      # 这里写portal服务的地址或者主机名
      # 端口使用普通http端口，不使用AJP端口；每个服务的具体端口可以查看Tomcat的conf/server.xml
      proxy_pass http://PORTAL:8080/portal;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
    location ^~ /sso {
      # 这里写sso服务的地址或者主机名
      # 端口使用普通http端口，不使用AJP端口；每个服务的具体端口可以查看Tomcat的conf/server.xml
      proxy_pass http://SSO:8084/sso;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
}
```

### 例子 2 -  Tomcat 服务的反向代理

```apache
# apache
<VirtualHost *:80>
    JkMount /* bid
    ServerName bid.example.com
    CustomLog "|/home/apache2/bin/rotatelogs /home/apache2/logs/bid.example.com-access%Y-%m-%d.log 86400" common
</VirtualHost>
```

```nginx
# nginx
server{
    listen 80;
    server_name bid.example.com;

    location ^~ / {
      # 这里写后端服务的地址或者主机名
      # 端口使用普通http端口，不使用AJP端口；每个服务的具体端口可以查看Tomcat的conf/server.xml
      proxy_pass http://bid:8082/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
}
```

### 例子 3 -  Tomcat 服务的反向代理, 存在多个路径

```apache
# apache
<VirtualHost *:80>
    JkMount /uweb/* usercenter
    JkMount /* manage
    ServerName manage.example.com
    CustomLog "|/home/apache2/bin/rotatelogs /home/apache2/logs/manage.example.com-access%Y-%m-%d.log 86400" common
</VirtualHost>
```

```nginx
# nginx
server{
    listen 80;
    server_name manage.example.com;

    location ^~ / {
      proxy_pass http://manage:8081/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
    # 这里写uweb的反向代理，服务指向是usercenter
    location ^~ /uweb {
      proxy_pass http://usercenter:8083/uweb;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
}
```

### 例子 4 - 其他服务的反向代理

```apache
# apache
<VirtualHost *:80>
    ServerName utrb.example.com
    SetEnv force-proxy-request-1.0.1
    SetEnv proxy-nokeepalive 1
    ProxyPreserveHost On
    ProxyRequests Off

    <Proxy /web>
        Order deny,allow
        Allow from all
    </Proxy>
    ProxyPass /web http://192.168.0.101/web Keepalive=On
    ProxyPassReverse /web http://192.168.0.101/web
    ProxyPass /weixin/ http://192.168.0.101/web/weixin/
    ProxyPass /ui-tools/ http://192.168.0.101/ui-tools/
    CustomLog "|/home/apache2/bin/rotatelogs /home/apache2/logs/sso.example.com-access%Y-%m-%d.log 86400" common
</VirtualHost>
```

```nginx
# nginx
server{
    listen 80;
    server_name utrb.example.com;
    
    location ^~ /web {
      proxy_pass http://192.168.0.101/web;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
    location ^~ /weixin/ {
      proxy_pass http://192.168.0.101/web/weixin/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
    location ^~ /ui-tools/ {
      proxy_pass http://192.168.0.101/ui-tools/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_http_version 1.1;
    }
}
```

## 3. 优化参数

```nginx
# 放到nginx.conf文件的http段内

# 关闭目录列表展示(default: off)
autoindex off;
# 隐藏服务版本号(default: on)
server_tokens off;
client_max_body_size 500m;
client_body_buffer_size 500m;
proxy_buffer_size 512k;
proxy_buffers 32 64k;
proxy_busy_buffers_size 512k;
large_client_header_buffers 8 64k;
# 防跨站点脚本攻击 设置Iframe限制规则，SAMEORIGIN表示该页面可以在相同域名页面的 frame 中展示
add_header "X-Frame-Options" SAMEORIGIN;
# 开启xss过滤。如果检测到攻击，浏览器将不呈现页面，而不会清除页面
add_header "X-XSS-Protection" "1; mode=block";
# 开启浏览器的 DNS 预读取功能；因为预读取会在后台执行，所以 DNS 很可能在链接对应的东西出现之前就已经解析完毕。这能够减少用户点击链接时的延迟。
add_header "X-DNS-Prefetch-Control" on;
# 被服务器用来提示客户端一定要遵循在 Content-Type 首部中对  MIME 类型 的设定，而不能对其进行修改。这就禁用了客户端的 MIME 类型嗅探行为
add_header "X-Content-Type-Options" nosniff;
```

## 4. 测试验证

### 测试方法一

1. 停止apache
2. 启动nginx: `service nginx start`
3. 访问验证

恢复步骤

1. 停止nginx: `service nginx stop`
2. 启动apache
3. 访问验证

### 测试方法二

1. 把nginx默认监听端口改成非80
2. 启动nginx进行测试: `service nginx start`
3. 测试完成后切换nginx端口为80
4. 停止apache
5. 重新加载nginx: `nginx -t && nginx -s reload`
6. 访问验证
