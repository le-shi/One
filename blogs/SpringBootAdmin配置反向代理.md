### [Nginx] - SpringBootAdmin配置反向代理

```bash
# spring-boot-admin配置
java -Xms128m -Xmx2048m -Xss512k -Djava.security.egd=file:/dev/urandom -jar spring-boot-admin.jar --spring.application.name=admin --spring.boot.admin.ui.title="我的监控" --spring.boot.admin.ui.brand="<img src=\"assets/img/icon-spring-boot-admin.svg\"><span>我的监控</span>" --spring.security.user.name=admin --spring.security.user.password=admin --eureka.instance.metadata-map.user.name=admin --eureka.instance.metadata-map.user.password=admin --eureka.client.service-url.defaultZone=http://${eureka_ip}:8761/eureka/ --spring.boot.admin.ui.public-url=http://访问地址/stats --eureka.client.register-with-eureka=false --eureka.client.fetch-registry=true 
```

```nginxconf
# nginx配置
...
upstream springbootadmin {
    server 127.0.0.1:8080;
}
...
server {
...
    location /stats/ {
        proxy_pass http://springbootadmin/;
        proxy_set_header Host $host:$server_port;
        proxy_set_header X-Forwarded-Port $server_port;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        # http
        # proxy_redirect ~^http://([^:]+)(:\d+)?(.*)$ http://$1/stats$3;
        # https
        # proxy_redirect ~^http://([^:]+)(:\d+)?(.*)$ https://$1:$server_port/stats$3;
    }
...
}
```

### 使用SSL

```
# spring-boot-admin配置
# 需要将--spring.boot.admin.ui.public-url的值变成https
--spring.boot.admin.ui.public-url=https://访问地址/stats
```
