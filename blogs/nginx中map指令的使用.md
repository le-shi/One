
- map 指令介绍：
  - map 指令是由 `ngx_http_map_module` 模块提供的，默认情况下安装 nginx 都会安装该模块。
  - map 的主要作用是创建自定义变量，通过使用 nginx 的内置变量，去匹配某些特定规则，如果匹配成功则设置某个值给自定义变量。 而这个自定义变量又可以作于他用。
  - 在 Nginx 配置文件中的作用段: `http{}` ，注意 map 不能写在 `server{}` 否则会报错
  - map 的 `$var1` 为源变量，通常可以是 nginx 的内置变量，`$var2` 是自定义变量。 `$var2` 的值取决于 `$var1` 在对应表达式的匹配情况。 如果一个都匹配不到则 `$var2` 就是 default 对应的值。

# Nginx根据不同的域名(server_name)设置不同的网站根目录

1. 创建测试用的目录和文件 htmlA、htmlB

    ```bash
    sudo mkdir -pv /usr/share/nginx/html/{htmlA,htmlB}
    echo '127.0.0.1' | sudo tee /usr/share/nginx/html/htmlA
    echo 'localhost' | sudo tee /usr/share/nginx/html/htmlB
    ```

2. 添加配置文件

    ```nginx
    # if的实现
    server {
        listen 81;
        set $sm 0;

        if ($host = "127.0.0.1") { set $sm 0; }
        if ($host = "localhost") { set $sm 1; }

        location / {
            if ($sm = 0) {
                root /usr/share/nginx/html/htmlA;
            }

            if ($sm = 1) {
                root /usr/share/nginx/html/htmlB;
            }
        }
    }
    ```

    ```nginx
    # map的实现
    http {
        ...
        # 当host为127.0.0.1时，host_root变量设置为htmlA
        # 当host为localhost时，host_root变量设置为htmlB
        # 其他条件时，host_root变量为空
        map $host $host_root {
            default "";
            127.0.0.1 /usr/share/nginx/html/htmlA;
            localhost /usr/share/nginx/html/htmlB;
        }
        ...
    }

    server {
        listen 81;

        location / {
            root $host_root;
        }
    }
    ```

3. 加载配置文件

    ```bash
    nginx -t && nginx -s reload
    ```

4. 发起请求测试

    ```bash
    [17:05:49] in /usr/share/nginx/html  
    ➜ curl 127.0.0.1:81                        
    127.0.0.1

    [17:05:54] in /usr/share/nginx/html  
    ➜ curl localhost:81
    localhost
    ```

5. 查看请求日志

    ```diff
    # tail -f /var/log/nginx/access_json.log | jq .

    {
    "@timestamp": "2021-05-17T17:05:54+08:00",
    "server_addr": "127.0.0.1",
    "server_port": "81",
    "server_protocol": "HTTP/1.1",
    "client_ip": "127.0.0.1",
    "client_user": "-",
    "status": "200",
    "request_method": "GET",
    "request_length": "76",
    "request_time": "0.000",
    "request_url": "/",
    "request_line": "GET / HTTP/1.1",
    "send_client_size": "254",
    "send_client_body_size": "10",
    "http_host": "127.0.0.1",
    "http_cookie": "-",
    "http_user_agent": "curl/7.68.0",
    +  "document_root": "/usr/share/nginx/html/htmlA",
    "connection_requests": "1",
    "connection_number": "10"
    }
    {
    "@timestamp": "2021-05-17T17:06:03+08:00",
    "server_addr": "127.0.0.1",
    "server_port": "81",
    "server_protocol": "HTTP/1.1",
    "client_ip": "127.0.0.1",
    "client_user": "-",
    "status": "200",
    "request_method": "GET",
    "request_length": "76",
    "request_time": "0.000",
    "request_url": "/",
    "request_line": "GET / HTTP/1.1",
    "send_client_size": "254",
    "send_client_body_size": "10",
    "http_host": "localhost",
    "http_cookie": "-",
    "http_user_agent": "curl/7.68.0",
    +  "document_root": "/usr/share/nginx/html/htmlB",
    "connection_requests": "1",
    "connection_number": "11"
    }
    ```


# Nginx根据不同args转发指定下游服务器

1. 添加配置文件

    ```nginx
    # 使用map实现
    http {
        ...
        # 当args为id=220时，cust_upstream变量设置为127.0.0.1
        # 其他条件时，cust_upstream变量设置为192.168.13.77,nginx的机器IP就是13.77
        map $args $cust_upstream {
            default 192.168.13.77;
            id=220 127.0.0.1;
        }
        ...
    }

    server {
        listen 9876;

        location ^~ /aa {
            return 210;
        }

        location ^~ /cc {
            add_header X-debug-message $cust_upstream always;
            proxy_pass http://$cust_upstream:9876/aa;
        }
    }
    ```

2. 加载配置文件

    ```bash
    nginx -t && nginx -s reload
    ```

3. 发起请求测试

    ```bash
    [09:54:05] in ~ is 📦 v5.4.0-77-generic via ⬢ v14.16.1 on 🐳 v20.10.8 via 🐍 system
    ➜ curl -I '0.0.0.0:9876/cc?id=220'
    HTTP/1.1 210 
    Server: nginx/1.18.0 (Ubuntu)
    Date: Tue, 31 Aug 2021 01:54:05 GMT
    Content-Type: application/octet-stream
    Content-Length: 0
    Connection: keep-alive
    X-debug-message: 127.0.0.1


    [09:54:08] in ~ is 📦 v5.4.0-77-generic via ⬢ v14.16.1 on 🐳 v20.10.8 via 🐍 system
    ➜ curl -I '0.0.0.0:9876/cc?id='
    HTTP/1.1 210 
    Server: nginx/1.18.0 (Ubuntu)
    Date: Tue, 31 Aug 2021 01:54:08 GMT
    Content-Type: application/octet-stream
    Content-Length: 0
    Connection: keep-alive
    X-debug-message: 192.168.13.77
    ```

# Nginx根据日期和端口号打印日志到带有日期和端口的日志文件


1. 添加配置文件

    ```nginx
    # 使用map实现
    http {
        ...
        # 自定义日志格式跟map没有关系，只是为了看日志时结构清晰
        log_format json '{"@timestamp":"$time_iso8601",'
                 '"server_addr":"$server_addr",'
                 '"server_name":"$server_name",'
                 '"server_port":"$server_port",'
                 '"server_protocol":"$server_protocol",'
                 '"client_ip":"$remote_addr",'
                 '"status":"$status",'
                 '"request_method": "$request_method",'
                 '"http_host":"$host",'
                 '"http_scheme":"$scheme"}';

        # 正则获取time_iso8601的日期，将curr_date设置为前面正则取出来的日期
        # 其他条件时，curr_date变量设置为 date-not-found
        map $time_iso8601 $curr_date {
          # 1 效率: 正则匹配需要6步 - ^(.{10})
          '~^(.{10})' $1;
          # 2 效率: 正则匹配需要9步 - ^(\d{4}-\d{2}-\d{2})
          #'~^(\d{4}-\d{2}-\d{2})' $1;
          # 3 效率: 正则匹配需要36步 - ^(.*)T
          #'~^(.*)T' $1;

          default 'date-not-found';
        }
        # 日志文件名字采用curr_data和server_port变量，每一天不同端口的请求，都会记录到日期和端口对应的log里
        # 配置加载生效后，nginx只有收到请求才会生成 access_json-2021-01-01-80.log 这样名称的日志文件
        access_log /var/log/nginx/access_json-$curr_date-$server_port.log json;
        ...
    }

    server {
        listen 9875;
        location / {
            return 230;
        }
    }
    server {
        listen 9874;
        location / {
            return 231;
        }
    }
    ```

2. 加载配置文件

    ```bash
    nginx -t && nginx -s reload
    ```

3. 请求之前，检查带有日期和端口的日志文件没有生成

    ```bash
    ls -t /var/log/nginx/
    ```

4. 发起请求测试

    ```bash
    [10:16:52] in ~ is 📦 v5.4.0-77-generic via ⬢ v14.16.1 on 🐳 v20.10.8 via 🐍 system 
    ➜ curl -I '0.0.0.0:9875'                          
    HTTP/1.1 230 
    Server: nginx/1.18.0 (Ubuntu)
    Date: Tue, 31 Aug 2021 02:16:52 GMT
    Content-Type: application/octet-stream
    Content-Length: 0
    Connection: keep-alive


    [10:16:53] in ~ is 📦 v5.4.0-77-generic via ⬢ v14.16.1 on 🐳 v20.10.8 via 🐍 system 
    ➜ curl -I '0.0.0.0:9874'
    HTTP/1.1 231 
    Server: nginx/1.18.0 (Ubuntu)
    Date: Tue, 31 Aug 2021 02:16:57 GMT
    Content-Type: application/octet-stream
    Content-Length: 0
    Connection: keep-alive
    ```

5. 检查生成带有日期和端口的日志文件

    ```bash
    [10:18:17] in ~ is 📦 v5.4.0-77-generic via ⬢ v14.16.1 on 🐳 v20.10.8 via 🐍 system 
    ➜ ls -1t /var/log/nginx/access_json*

    /var/log/nginx/access_json-2021-08-31-9874.log
    /var/log/nginx/access_json-2021-08-31-9875.log
    ```