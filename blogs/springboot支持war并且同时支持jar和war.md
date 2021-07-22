# springboot 打jar包转为打war包

## 第一步: 修改 SpringBoot 工程

1. 修改打包形式

    修改pom.xml文件，添加以下内容，如果已经存在的，将其修改为war包形式

    ```xml
    <packaging>war</packaging>
    ```

2. 移除嵌入式tomcat插件

    在pom.xml里找到spring-boot-starter-web依赖节点，在其中添加如下代码：

    ```xml
    <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-starter-web</artifactId>
                <!-- 移除嵌入式tomcat插件 -->
                <exclusions>
                    <exclusion>
                        <groupId>org.springframework.boot</groupId>
                        <artifactId>spring-boot-starter-tomcat</artifactId>
                    </exclusion>
                </exclusions>
    </dependency>
    ```

3. 添加servlet-api的依赖

    以下有两个依赖可以选择，二选一：

    a. tomcat-servlet-api(选的这个)

    ```xml
    <dependency>
        <groupId>org.apache.tomcat</groupId>
        <artifactId>tomcat-servlet-api</artifactId>
        <version>9.0.37</version>
        <scope>provided</scope>
    </dependency>
    ```

    b. javax.servlet-api

    ```xml
    <dependency>
        <groupId>javax.servlet</groupId>
        <artifactId>javax.servlet-api</artifactId>
        <version>4.0.1</version>
        <scope>provided</scope>
    </dependency>
    ```

4. 添加servlet容器

    以下有两个类型可以选择，二选一：
    a. tomcat-embed-core(选的这个)

    ```xml
    <dependency>
        <groupId>org.apache.tomcat.embed</groupId>
        <artifactId>tomcat-embed-core</artifactId>
        <version>9.0.37</version>
    </dependency>
    ```

    b. spring-boot-starter-tomcat

    ```xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-tomcat</artifactId>
        <scope>provided</scope>
    </dependency>
    ```

5. 修改启动类，并重写初始化方法，新增 `ServletInitializer.java` 文件，无需操作启动类

    ```java
    import org.springframework.boot.builder.SpringApplicationBuilder;
    // spring 2.x
    import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
    // spring 1.x
    // import org.springframework.boot.web.support.SpringBootServletInitializer;
    public class SpringBootStartApplication extends SpringBootServletInitializer {
        @Override
        protected SpringApplicationBuilder configure(SpringApplicationBuilder builder) {

            //  这里sources的类就是启动类
            return builder.sources(Application.class);
    }
    ```

6. 编译打war包

    ```shell
    mvn clean package
    ```

## 第二步: 测试运行

1. 测试运行
   + 使用tomcat镜像运行war包

       ```dockerfile
       FROM tomcat:9.0.37-jdk8-openjdk-slim-buster
       COPY target/*.war webapps/ROOT.war
       ```

   + 使用Tomcat/Tongweb运行war包
1. 启动后，访问接口测试是否正常运行

## 使用一个pom.xml文件同时构建jar和war

pom.xml参考

```diff
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.zbxsoft.sc</groupId>
    <artifactId>sc</artifactId>
    <version>2.3.11-SNAPSHOT</version>
+    <packaging>${project.packaging}</packaging>

    <name>sc</name>
    <description>玄武库配置中心</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.3.2.RELEASE</version>
        <relativePath/>
    </parent>

    <properties>
        ...
    </properties>


+    <profiles>
+        <profile>
+            <id>jar</id>
+            <activation>
+                <activeByDefault>true</activeByDefault>
+            </activation>
+            <properties>
+                <project.packaging>jar</project.packaging>
+            </properties>
+            <build>
+                <plugins>
+                    <plugin>
+                        <groupId>org.springframework.boot</groupId>
+                        <artifactId>spring-boot-maven-plugin</artifactId>
+                            <configuration>
+                                <layers>
+                                    <enabled>true</enabled>
+                                </layers>
+                            </configuration>
+                    </plugin>
+                </plugins>
+            </build>
+        </profile>
+        <profile>
+            <id>war</id>
+            <properties>
+                <project.packaging>war</project.packaging>
+            </properties>
+            <dependencies>
+                <dependency>
+                    <groupId>org.springframework.boot</groupId>
+                    <artifactId>spring-boot-starter-web</artifactId>
+                    <exclusions>
+                        <exclusion>
+                            <groupId>org.springframework.boot</groupId>
+                            <artifactId>spring-boot-starter-tomcat</artifactId>
+                        </exclusion>
+                    </exclusions>
+                </dependency>
+                <dependency>
+                    <groupId>org.springframework.boot</groupId>
+                    <artifactId>spring-boot-starter-tomcat</artifactId>
+                    <scope>provided</scope>
+                </dependency>
+            </dependencies>
+        </profile>
+    </profiles>
    
    ...

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
-                    <configuration>
-                        <layers>
-                            <enabled>true</enabled>
-                        </layers>
-                    </configuration>
            </plugin>
            ...
        </plugins>
    </build>

</project>

```

```bash
# 通过-P,--activate-profiles参数控制
# 打jar包 (默认是jar)
mvn clean package
mvn -P jar clean package
# 打war包
mvn -P war clean package
```
