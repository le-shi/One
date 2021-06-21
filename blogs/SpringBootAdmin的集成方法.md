# Spring-Boot-Admin(SBA)

> 服务端配置项参考 <https://codecentric.github.io/spring-boot-admin/2.3.1/#spring-boot-admin-server>
> 客户端配置项参考 <https://codecentric.github.io/spring-boot-admin/2.3.1/#spring-boot-admin-client>

+ SBA注册有两种行为:
  1. 引导应用用Spring Boot Admin Client (via HTTP) 进行主动上报, 特征: `应用名显示为小写`(服务向SBA主动发起上报)，可用于不使用注册中心的spring-boot工程
  2. 从注册中心发现, 特征: `应用名显示为大写`(SBA主动从注册中心发现服务)，可用于使用注册中心的spring-boot工程

+ 必要的:
    1. 客户端需要在pom.xml里添加引用 --security会造成所有端点都要认证，影响正常使用

        ```pom
        <dependencies>
        ...
        <!-- https://mvnrepository.com/artifact/de.codecentric/spring-boot-admin-client -->
        <dependency>
            <groupId>de.codecentric</groupId>
            <artifactId>spring-boot-admin-client</artifactId>
            <version>2.3.1</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.springframework.boot/spring-boot-starter-security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
            <version>2.4.5</version>
        </dependency>
        ...
        </dependencies>
        ```

    2. 两种注册行为二选其一

## 行为１

+ SBA Server

```properties
# SBA服务器的api受到HTTP基本身份验证的保护, 和UI登录共用
spring.security.user.name=admin-user
spring.security.user.password=admin-password
# 从注册中心发现(Eureka, Consul)设置为false
spring.boot.admin.discovery.enabled=false
# Eureka实例元数据选项, 凭证被用来访问端点(SBA Server需要保证元数据和基本身份认证的用户名密码一致, SBA自我监控用的到)
eureka.instance.metadata-map.user.name=${spring.security.user.name}
eureka.instance.metadata-map.user.password=${spring.security.user.password}
```

这时SBA Server只会显示SBA Client主动上报的程序

+ SBA Client

```properties
# admin注册的地址
spring.boot.admin.client.url=http://localhost:8080
# 访问SBA服务器的api受到HTTP基本身份验证的保护, 这里的用户名密码需要和SBA服务端保持一致
spring.boot.admin.client.username=admin-user
spring.boot.admin.client.password=admin-password
# 添加spring-boot-starter-security包，会自动开启安全认证，设置自定义用户名和密码
spring.security.user.name=client-user
spring.security.user.password=client-password
# Eureka实例元数据选项, 凭证被用来访问端点
eureka.instance.metadata-map.user.name=${spring.security.user.name}
eureka.instance.metadata-map.user.password=${spring.security.user.password}
# http方式包含需要公开的端点'*'代表所有(默认health,info) --通过spring-boot-starter-security消除安全问题
management.endpoints.web.exposure.include=*
# http方式排除需要公开的端点
management.endpoints.web.exposure.exclude=info
# 服务端看日志用
logging.file.name=/tmp/${spring.application.name}.log
```

## 行为2

+ SBA Server

```properties
# SBA服务器的api受到HTTP基本身份验证的保护, 和UI登录共用
spring.security.user.name=admin-user
spring.security.user.password=admin-password
# 从注册中心(Eureka, Consul)发现设置为true
spring.boot.admin.discovery.enabled=true
# Eureka实例元数据选项, 凭证被用来访问端点(SBA Server需要保证元数据和基本身份认证的用户名密码一致, SBA自我监控用的到)
eureka.instance.metadata-map.user.name=${spring.security.user.name}
eureka.instance.metadata-map.user.password=${spring.security.user.password}
```

这时SBA Server显示注册中心里的程序和SBA Client主动上报的程序, 如果client即注册又主动上报, SBA Server显示会有重复

+ SBA Client

```properties
# 添加spring-boot-starter-security包，会自动开启安全认证，设置自定义用户名和密码
spring.security.user.name=client-user
spring.security.user.password=client-password
# Eureka实例元数据选项, 凭证被用来访问端点
eureka.instance.metadata-map.user.name=${spring.security.user.name}
eureka.instance.metadata-map.user.password=${spring.security.user.password}
# http方式包含需要公开的端点'*'代表所有(默认health,info) --通过spring-boot-starter-security消除安全问题
management.endpoints.web.exposure.include=*
# http方式排除需要公开的端点
management.endpoints.web.exposure.exclude=info
# 服务端看日志用
logging.file.name=/tmp/${spring.application.name}.log
```

### 添加build详情显示

```pom
            ...
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <!-- build-info begin -->
                <executions>
                    <execution>
                        <goals>
                            <goal>build-info</goal>
                        </goals>
                    </execution>
                </executions>
                <!-- build-info end -->
                <configuration>
                    <layers>
                        <enabled>true</enabled>
                    </layers>
                </configuration>
            </plugin>
            ...
```

## [Nginx] - SpringBootAdmin配置反向代理

```bash
# spring-boot-admin配置
java -Xms128m -Xmx2048m -Xss512k -Djava.security.egd=file:/dev/urandom -jar spring-boot-admin.jar --spring.application.name=admin --spring.boot.admin.ui.title="我的监控" --spring.boot.admin.ui.brand="<img src=\"assets/img/icon-spring-boot-admin.svg\"><span>我的监控</span>" --spring.security.user.name=admin --spring.security.user.password=admin --eureka.instance.metadata-map.user.name=admin --eureka.instance.metadata-map.user.password=admin --eureka.client.service-url.defaultZone=http://${eureka_ip}:8761/eureka/ --spring.boot.admin.ui.public-url=http://访问地址/stats --eureka.client.register-with-eureka=false --eureka.client.fetch-registry=true 
```

```nginxconf
# nginx配置
...
upstream springbootadmin {
    server spring-boot-admin:8080;
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
        # http - 默认端口
        proxy_redirect ~^http://([^/]+)?(.*)$ http://$1/stats$2;
        # http - 非默认端口
        #proxy_redirect ~^http://([^:]+)(:\d+)?(.*)$ http://$1:$server_port/stats$3;
        # https - 默认端口
        #proxy_redirect ~^https://([^/]+)?(.*)$ https://$1/stats$2;
        # https - 非默认端口
        #proxy_redirect ~^http://([^:]+)(:\d+)?(.*)$ https://$1:$server_port/stats$3;
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
