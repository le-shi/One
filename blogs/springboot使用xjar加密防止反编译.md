# pre

1. 准备环境
   1. `springboot2.3`: Java 框架
   2. `jdk1.7+`: Java 运行环境
   3. `go1.15.6`: xjar 的构建环境(运行不需要go)
      1. 每个工程的xjar必须单独构建，不能通用，详情见: [源码介绍](https://gitee.com/core-lib/xjar)
   4. `xjar`: pom依赖 [github](https://github.com/core-lib/xjar) [gitlab](https://gitee.com/core-lib/xjar)
   5. `xjar-maven-plugin`: pom插件依赖 [github](https://github.com/core-lib/xjar-maven-plugin) [gitlab](https://gitee.com/core-lib/xjar-maven-plugin)
2. 改造pom.xml

    ```xml
    ...
    <dependencies>
        <!-- 添加 XJar 依赖 -->
        <dependency>
            <groupId>com.github.core-lib</groupId>
            <artifactId>xjar</artifactId>
            <version>4.0.2</version>
            <!-- <scope>test</scope> -->
        </dependency>
    </dependencies>
    ...
        <build>
            <plugins>
                <plugin>
                    <groupId>com.github.core-lib</groupId>
                    <artifactId>xjar-maven-plugin</artifactId>
                    <version>4.0.2</version>
                    <executions>
                        <execution>
                            <goals>
                                <goal>build</goal>
                            </goals>
                            <phase>package</phase>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </build>
    ...
    ```

3. 打包

    ```shell
    mvn clean package -Dxjar.password=123
    ```

4. 会生成jar加密前的程序和xjar加密后的程序，xjar的后缀是xjar插件定义的
5. 构建xjar可执行文件

    ```shell
    cd target
    go build xjar.go
    ```

6. 验证使用jd-gui反编译工具或者归档管理器打开jar和xjar，会看到xjar里的xml是二进制文件不可查看
7. 运行加密后的jar

    ```shell
    ./xjar java -jar apple-0.0.1-SNAPSHOT.xjar
    ```

8. 注册中心查看注册的服务
9. 访问接口，是否正常返回数据

缺点1: 加密后的包会很大，比原来的大几倍

```txt
apple-0.0.1-SNAPSHOT.jar                           02-Jul-2021 16:52     83M
apple-0.0.1-SNAPSHOT.war                           02-Jul-2021 16:53     83M
apple-0.0.1-SNAPSHOT.xjar                          02-Jul-2021 16:53    207M
```

缺点2: 每个工程的xjar必须单独构建，不能多个工程混用