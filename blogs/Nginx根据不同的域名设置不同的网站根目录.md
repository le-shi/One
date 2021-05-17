# Nginx根据不同的域名设置不同的网站根目录

1. 创建测试用的目录和文件 htmlA、htmlB

    ```bash
    sudo mkdir -pv /usr/share/nginx/html/{htmlA,htmlB}
    echo '127.0.0.1' | sudo tee /usr/share/nginx/html/htmlA
    echo 'localhost' | sudo tee /usr/share/nginx/html/htmlB
    ```

2. 添加配置文件

    ```nginx
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

