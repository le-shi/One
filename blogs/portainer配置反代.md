### [Nginx] - Portainer配置反向代理

```nginxconf
# nginx配置
server {
...
    location ^~ /portainer/ {
        proxy_pass http://1.1.1.2:9000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
...
}
```

### 使用SSL
```nginxconf
# portainer配置
启动时需要添加--ssl --sslcert --sslkey 三个参数
# nginx配置
server {
...
    location ^~ /portainer/ {
        proxy_pass https://1.1.1.2:9000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
...
}
```