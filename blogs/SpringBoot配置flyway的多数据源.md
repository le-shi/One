# requirements

> springboot 2.x.x
> flyway-core 5.2.4

## Configure Action

1. 配置文件`application.yml` 或 `application.properties`

    ```properties
    # 数据源类型
    database.type=mysql
    # flyway放置脚本的路径，可以用"{vendor}"变量占位
    spring.flyway.locations=classpath:db/migration/${database.type}
    # 打开flyway开关
    spring.flyway.enabled=true
    ```

    or

    ```yml
    # 数据源类型
    database:
      type: mysql
    # flyway放置脚本的路径，可以用"{vendor}"变量占位
    spring:
      flyway:
        locations: classpath:db/migration/${database.type}
    # 打开flyway开关
    spring:
      flyway:
        enabled: true
    ```

2. 路径规划，db/migration目录下新建不同数据库的目录，并将对应sql文件放入

    ```diff
    src
    └── main
        ├── java
        └── resources
            └── db
                └── migration
    +               ├── h2
    +               ├── mysql
    +               └── oracle
    ```

3. 启动服务，观察数据库是否已自动创建相应表
