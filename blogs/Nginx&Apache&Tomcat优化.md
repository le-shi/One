# 优化记录

---

## 共同优化点：TCP 协议栈调优

```bash
[root@localhost nginx]# cat /etc/sysctl.conf
# Increase system IP port limits to allow for more connections
# 调高系统的 IP 以及端口数据限制，从可以接受更多的连接
net.ipv4.ip_local_port_range = 2000 65000

net.ipv4.tcp_window_scaling = 1

# number of packets to keep in backlog before the kernel starts dropping them
# 设置协议栈可以缓存的报文数阀值，超过阀值的报文将被内核丢弃
net.ipv4.tcp_max_syn_backlog = 3240000

# increase socket listen backlog
# 调高 socket 侦听数阀值
net.core.somaxconn = 3240000
net.ipv4.tcp_max_tw_buckets = 1440000

# Increase TCP buffer sizes
# 调大 TCP 存储大小
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216
net.ipv4.tcp_congestion_control = cubic
```

> 通过对内核 TCP 配置的优化可以提高服务器网络带宽。

---

### Nginx优化

```nginxconf
[root@localhost nginx]# cat /etc/nginx/nginx.conf
# For more information on configuration, see:
#   * Official English Documentation: http://nginx.org/en/docs/

# 使用nginx用户运行工作进程
user nginx;
# 定义了nginx对外提供Web服务时的worker进程数,起始可以设置为CPU的核数,CPU核数是多少就设置为多少(设置为"auto"将自动检测)
worker_processes auto;
# 只记录 critical 级别的错误日志
error_log /var/log/nginx/error.log crit;
pid /var/run/nginx.pid;
# 更改worker进程的最大打开文件限制,如果没设置的话，这个值为操作系统的限制.设置后你的操作系统和Nginx可以处理比"ulimit -a"更多的文件,所以把这个值设高,这样nginx就不会有"too many open files"问题了
worker_rlimit_nofile 100000;

# Load dynamic modules. See /usr/share/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    # 设置可由一个worker进程同时打开的最大连接数.如果设置了上面提到的worker_rlimit_nofile,我们可以将这个值设得很高
    worker_connections  4000;
    # 允许尽可能地处理更多的连接数，如果 worker_connections 配置太低，会产生大量的无效连接请求。
    multi_accept on;
    # 使用epoll模型,效率更高
    use epoll;
}


http {
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  ' "$http_user_agent" "$http_x_forwarded_for" '
    #                  '$upstream_connect_time $upstream_header_time $upstream_response_time $request_time'
    #                  '$upstream_status sn=$server_name';
#log_format main '客户端真实IP - 客户端用户名(缺省为-) [请求的本地时间] "请求信息(bg:GET/POST xxx)" '
#                 '状态码 返回消息大小 "从哪个链接跳转过来的" '
#                 ' "客户端浏览器信息" "客户端真实IP(缺省为-)"  '
#                 ' 与应用(上游)服务器建立连接所花费的时间,在SSL的情况下，包括花在握手上的时间  建立连接和从上游服务器接收响应头的第一个字节之间的时间 建立连接和从上游服务器接收响应主体的最后一个字节之间的时间 处理请求总时间'
#                 '保留从上游服务器获得的响应的状态码(如果无法选择服务器，则该变量将保留502（错误网关）状态码) sn=请求的服务地址(可以再变量前加上sn=标识符，在日志中方便查找)'
# 将日志写入高速 IO 存储设备，或者直接关闭日志
# access_log off;
    #access_log  /var/log/nginx/access.log  main buffer=16k;
    # log json化
    log_format json  '{"@timestamp":"$time_iso8601",'
                    '"host":"$server_addr",'
                    '"clientip":"$remote_addr",'
                    '"clientuser":"$remote_user",'
                    '"request":"$request",'
                    '"status":"$status",'
                    '"request_method": "$request_method",'
                    '"size":"$body_bytes_sent",'
                    '"request_time":"$request_time",'
                    '"upstreamtime":"$upstream_response_time",'
                    '"upstreamhost":"$upstream_addr",'
                    '"http_host":"$host",'
                    '"url":"$uri",'
                    '"http_x_forward":"$http_x_forwarded_for",'
                    '"http_referer":"$http_referer",'
                    '"user_agent":"$http_user_agent"}';
    access_log /var/log/nginx/access.log_json json;
    # 开启 sendfile 选项，使用内核的 FD 文件传输功能，这个比在用户态用 read() + write() 的方式更加高效。
    sendfile            on;
    # 打开 tcp_nopush 选项，Nginux 允许将 HTTP 应答首部与数据内容在同一个报文中发出。这个选项使服务器在 sendfile 时可以提前准备 HTTP 首部，能够达到优化吞吐的效果。
    tcp_nopush          on;
    # 不要缓存 data-sends （关闭 Nagle 算法），这个能够提高高频发送小数据报文的实时性。
    tcp_nodelay         on;
    # 配置连接 keep-alive 超时时间，服务器将在超时之后关闭相应的连接。
    keepalive_timeout   30;
    # 单个客户端在 keep-alive 连接上可以发送的请求数量，在测试环境中，需要配置个比较大的值。
    keepalive_requests  100000;
    types_hash_max_size 2048;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;

    #client_header_timeout和client_body_timeout 设置请求头和请求体(各自)的超时时间,在一定时间内收不到客户端的请求头请求体就关闭连接
    client_header_timeout 10;
    client_body_timeout 10;
    #告诉nginx关闭不响应的客户端连接.这将会释放那个客户端所占有的内存空间
    reset_timedout_connection on;
    # 客户端数据读超时配置，客户端停止读取数据，超时时间后断开相应连接，默认是 60 秒。
    send_timeout 2;
    #设置用于保存各种key（比如当前连接数）的共享内存的参数.5m就是5兆字节,这个值应该被设置的足够大以存储（32K*5）32byte状态或者（16K*5）64byte状态
    limit_conn_zone $binary_remote_addr zone=addr:5m;
    #为给定的key设置最大连接数.这里key是addr,我们设置的值是100,也就是说我们允许每一个IP地址最多同时打开有100个连接
    limit_conn addr 100;
    #只是一个在当前文件中包含另一个文件内容的指令。这里我们使用它来加载稍后会用到的一系列的MIME类型
    include /etc/nginx/mime.types;
    #设置文件使用的默认的MIME-type
    default_type text/html;
    #设置我们的头文件中的默认的字符集
    charset UTF-8;
    #采用gzip压缩的形式发送数据,这将会减少我们发送的数据量
    gzip on;
    #最小1K的文件才启动压缩
    gzip_min_length 1k;
    #压缩过程都写到buffer里面,压缩完成后发给客户端
    #调大[gzip_buffers number size]的值可解决an upstream response is buffered to a temporary file /var/lib/nginx/tmp/proxy/4/06/0000009064报错的问题
    gzip_buffers 6 256k;
    #gzip_http_version是http协议
    gzip_http_version 1.1;
    #设置数据的压缩等级.这个等级可以是1-9之间的任意数值,9是最慢但是压缩比最大的.设置4,这是一个比较折中的设置
    gzip_comp_level 4;
    #设置需要压缩的数据格式
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml application/json;
    #让前边的缓存服务器识别压缩后的文件
    gzip_vary on;
    #打开缓存的同时也指定了缓存最大数目,以及缓存的时间.我们可以设置一个相对高的最大时间,这样我们可以在它们不活动超过20秒后清除掉
    open_file_cache max=200000 inactive=20s;
    #在open_file_cache中指定检测正确信息的间隔时间
    open_file_cache_valid 30s;
    #定义了open_file_cache中指令参数不活动时间期间里最小的文件数
    open_file_cache_min_uses 2;
    #指定了当搜索一个文件时是否缓存错误信息,也包括再次给配置中添加文件.我们也包括了服务器模块,这些是在不同文件中定义的.如果你的服务器模块不在这些位置,你就得修改这一行来指定正确的位置
    open_file_cache_errors on;
    #指定是否传递4xx和5xx错误信息到客户端，或者允许nginx使用error_page处理错误信息。
    fastcgi_intercept_errors on;
    #指定了从FastCGI进程到来的应答，本地将用多少和多大的缓冲区读取
    #fastcgi_buffers可以设置为你的FastCGI返回的大部分应答大小，这样可以处理大部分的请求，较大的请求将被缓冲到磁盘
    #想关闭对所有请求道磁盘的缓冲，可以将fastcgi_max_temp_file_size设置为0
    #fastcgi_buffer等于：fastcgi_buffer_size + the_number * is_size
    #调大[fastcgi_buffers],[fastcgi_buffer_size],[proxy_buffer_size],[proxy_buffers],[proxy_busy_buffers_size]的值可解决an upstream response is buffered to a temporary file /var/lib/nginx/tmp/proxy/4/06/0000009064报错的问题
    fastcgi_buffers 6 2048k;
    fastcgi_buffer_size 2048k;
    #设置缓冲区大小,从代理后端服务器取得的第一部分的响应内容,会放到这里
    #设置自定义缓存以限制缓冲区溢出攻击的可能性
    #调大[client_body_buffer_size]的值可解决an upstream response is buffered to a temporary file /var/lib/nginx/tmp/[fastcgi_temp],[client_body]/0000009047报错的问题
    #调大[client_header_buffer_size]的值可解决an upstream response is buffered to a temporary file /var/lib/nginx/tmp/proxy_temp/4/06/0000009064报错的问题
    client_body_buffer_size 1K;
    client_header_buffer_size 1k;
    # 链接延时关闭
    lingering_timeout 5s;

    # 关闭目录列表展示(default: off)
    autoindex off;
    # 隐藏服务版本号(default: on)
    server_tokens off;
    # 客户端最大body大小(default: 1m)
    # 调大[client_max_body_size]的值可解决client intended to send too large body: 1538729 bytes报错的问题
    client_max_body_size 500m;
    # 解决Cookie/Header过大的问题,从代理后端服务器取得的第一部分的响应内容,会放到这里(default: 4k|8k)
    proxy_buffer_size 512k;
    # 设置缓冲区的大小和数量,从被代理的后端服务器取得的响应内容,会放置到这里(default: 8 4k|8k)
    proxy_buffers 32 64k;
    # proxy_busy_buffers_size不是独立的空间，他是proxy_buffers和proxy_buffer_size的一部分。nginx会在没有完全读完后端响应的时候就开始向客户端传送数据，所以它会划出一部分缓冲区来专门向客户端传送数据(这部分的大小是由proxy_busy_buffers_size来控制的，建议为proxy_buffers中单个缓冲区大小的2倍)，然后它继续从后端取数据，缓冲区满了之后就写到磁盘的临时文件中(default: 8 16k)
    proxy_busy_buffers_size 512k;
    # 解决Request Headers:Content-Length过大的问题(default: 4 8k)
    large_client_header_buffers 8 64k;
    # 反向代理连接超时时间，解决后端服务挂了响应时间长的问题(default: 60s)
    proxy_connect_timeout 3s;
    # 读取代理服务器最大超时时间(default: 60)
    proxy_read_timeout 600;
    # 设置Iframe限制规则
    add_header X-Frame-Options DENY;
    # 拦截状态码大于或等于300的代理请求到nginx以使用error_page指令进行处理(default: off)
    proxy_intercept_errors on;
    # 指定在哪种情况下请求传递到下一个服务器(default: error timeout)
    proxy_next_upstream error timeout http_502 http_504;
    # 限制请求传递到下一个服务器的时间(default: 0)
    proxy_next_upstream_timeout 3;
    # 限制请求传递到下一个服务器的可能尝试次数(default: 0)
    proxy_next_upstream_tries 2;

    # 非ssl配置参数
    server {
        listen 80 default_server;
        # IPV6 Support
        listen [::]:80;
        charset utf-8;
        #处理响应中的SSI命令: 默认值off，启用ssi时将其设为on
        ssi on;  
        #开启后在处理SSI文件出错时不输出错误提示"[an error occurred while processing the directive]"
        ssi_silent_errors on;
        #默认是text/html，所以如果需支持html，则不需要设置这句，如果需要支持shtml则需要设置
        ssi_types text/shtml;
        #允许在SSI处理期间保留来自原始响应的“Last-Modified”标题字段以促进响应缓存。
        ssi_last_modified  on;
        index index.html index.shtml;
        
        root /data;

        # 域名在这添加
        server_name _;
        
        #配合[fastcgi|proxy]_intercept_errors使用，定义错误码指定页面
        error_page 404 /404.html;

        # websocket配置
        location ^~ /websocket/ {
            proxy_pass http://websocket:9000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # ssl配置参数,myssl扫描结果A+
    server {
        # IPv4
        listen 443 ssl http2 default_server;
        # IPv6 Support
        listen [::]:443 ssl http2;
        charset utf-8;

        # 域名在这添加
        server_name _;

        ssl_certificate /etc/tower/tower.cert;
        ssl_certificate_key /etc/tower/tower.key;

        # 使用shared缓存,所有工作进程之间共享缓存,一兆字节可以存储大约4000个session
        ssl_session_cache shared:SSL:50m;
        # 客户端可以重用会话参数的时间(1 days)，超时后重新进行握手
        ssl_session_timeout 1d;
        # 重用Session 关闭
        ssl_session_tickets off;

        # intermediate configuration
        # 设置支持的协议
        ssl_protocols TLSv1.2 TLSv1.3;
        # 密码加密方式
        ssl_ciphers 'ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS';
        # 依赖TLSv1协议的服务器密码将优先于客户端密码
        ssl_prefer_server_ciphers on;

        # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
        add_header Strict-Transport-Security "max-age=15768000" always;

        # OCSP stapling 装订
        ssl_stapling on;
        ssl_stapling_verify on;

        # 使用解析器的IP地址替换
        resolver 127.0.0.1;

        location /favicon.ico { alias /var/lib/awx/public/static/favicon.ico; }
        location /static { alias /var/lib/awx/public/static; }

        # 强制跳转https
        if ($scheme = "http") { return 301 https://$host$request_uri; }
        }
}
```

> 参考：

+ [官网：ngx_http_upstream_module](https://nginx.org/en/docs/http/ngx_http_upstream_module.html#var_upstream_addr)
+ [如何生成每秒百万级别的 HTTP 请求？ -伯乐在线](http://blog.jobbole.com/87509/)
+ [7个角度进行nginx性能优化](https://mp.weixin.qq.com/s?__biz=MzA5Njg1OTI5Mg==&mid=2651025818&idx=1&sn=a3a4499bf14e86593b7fe7bcd289a8bb&chksm=8b5e7469bc29fd7f717d6a450b9374bbba6f20a3bab7a05bd6087f67013896c976cfcb5bec22&scene=0#rd)

---

### Apache优化

1. 日志格式优化

    ```apacheconf
    [root@localhost apache2]# cat /home/apache2/conf/httpd.conf
    <IfModule log_config_module>
        #配置json格式日志
        LogFormat "{\"@timestamp\": \"%{%Y-%m-%dT%H:%M:%S%z}t\", \"@version\": \"1\", \"clientip\": \"%a\", \"duration\": %D, \"status\": %>s, \"request\": \"%U%q\", \"url_path\": \"%U\", \"url_query\": \"%q\", \"bytes\": %B, \"request_method\": \"%m\", \"http_host\": \"%{Host}i\", \"http_referer\": \"%{Referer}i\", \"user_agent\": \"%{User-agent}i\"}" log_json
        <IfModule logio_module>
        ...
        </IfModule>
    </IfModule>
    ```

2. 开启安全过滤模块，在httpd.conf文件中

    1. 添加内容: `Include conf/mod_security.conf`[前提是有这个文件]
    2. 检查配置文件: `apache2/bin/apachectl configtest`

3. 最大连接数优化，conf/extra/httpd-mpm.conf内容修改Server MPM:     Prefork

    ```apacheconf
    <IfModule mpm_prefork_module>
        StartServers          20
        MinSpareServers       50
        MaxSpareServers      100
        ServerLimit         2000
        MaxClients          2000
        MaxRequestsPerChild   10000
    </IfModule>
    <IfModule mpm_netware_module>
        ThreadStackSize      65536
        StartThreads           250
        MinSpareThreads         25
        MaxSpareThreads        250
        MaxThreads            1000
        MaxRequestsPerChild      0
        MaxMemFree             100
    </IfModule>
    ```

4. 日志切割，在httpd.conf文件中。修改

    ```apacheconf
    CustomLog "|/home/apache2/bin/rotatelogs /home/apache2/logs/www.xxx.com-access%Y-%m-%d.log 86400" common
    ```

5. 安全漏洞方面

    [apache安全漏洞修复方法](https://www.jianshu.com/p/6f762492f4cf)

6. ssi配置优化

    [Apache下开启SSI配置使html支持include包含的方法](http://www.jb51.net/article/95262.htm)

7. 设置apache字符集，在httpd.conf文件中

    1. 添加如下语句 `AddDefaultCharset UTF-8` 注意这里是在 `</IfModule>` 标签中添加。

8. [Options指令详解](http://www.365mini.com/page/apache-options-directive.htm)
9. [rewrite详解](https://www.cnblogs.com/jukan/p/5660736.html)

---

### Tomcat优化

1. *server.xml*:配置进程连接

    ```xml
     <Connector connectionTimeout="2000" #网络连接超时时间(ms)
                   redirectPort="8443"  enableLookups="false"  #是否反查域名(true|flase)
          acceptCount="5000" maxThreads="2000"/>
    <Connector ... maxThreads="1000" #最多同时处理1000个连接
                maxProcessors="10000" #最多可以75个空线程等待（最大连接线程数）
                minProcessors="500" #即使没有人使用也开这么多空线程等待 （最小空闲连接线程数）
                acceptCount="2000"  #达到maxThreads的连接数后，还可以继续排队的连接个数（应大于等于）
        protocol="AJP/1.3" ... URIEncoding="UTF-8"/>
    ```

2. *catalina.sh*:配置内存参数

    ```bash
    JAVA_OPTS="-server -Xms512m -Xmx2048m -Xss512k -XX:+UseBiasedLocking -XX:PermSize=128M -XX:MaxPermSize=256M -XX:+UseConcMarkSweepGC -XX:+UseParNewGC  -XX:+CMSParallelRemarkEnabled -XX:+UseCMSCompactAtFullCollection -XX:LargePageSizeInBytes=128m -XX:+UseFastAccessorMethods -Djava.awt.headless=true"
    ```

3. *catalina.sh*:调试参数

    ```bash
    JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.port=60001"
    JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
    JAVA_OPTS="$JAVA_OPTS -Dcom.sun.management.jmxremote.ssl=false"
    JAVA_OPTS="$JAVA_OPTS -Djava.rmi.server.hostname=1.2.3.4"
    ```

4. 安全方面，server.xml文件，shutdown端口改为-1

    ```xml
    <Server port="-1" shutdown="SHUTDOWN">
    ```
