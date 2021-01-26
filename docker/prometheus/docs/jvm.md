# JVM

---

> Spring Boot 2.x

1. 需要 [micrometer-registry-prometheus](https://micrometer.io/docs/registry/prometheus)

2. 添加依赖-pom.xml

    ```xml
    <dependencies>
    ...
        <!-- https://mvnrepository.com/artifact/io.micrometer/micrometer-registry-prometheus -->
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
            <version>1.6.3</version>
        </dependency>
    ...
    </dependencies>
    ```

3. 修改配置，没有则添加-application.properties

    ```properties
    # 暴露prometheus端点
    management.endpoints.web.exposure.include=prometheus
    # 添加tag，application为当前服务名
    management.metrics.tags.application=${spring.application.name}
    # 开启Tomcat的MBean指标注册
    server.tomcat.mbeanregistry.enabled=true
    # 如果使用Eureka的自动发现，需要添加元数据指定prometheus端点路径是/actuator/prometheus
    eureka.instance.metadataMap.prometheus.path=/actuator/prometheus
    ```

4. 显示进程内存
   1. 需要 [micrometer-jvm-extras](https://github.com/mweirauch/micrometer-jvm-extras)

   2. 继续添加依赖-pom.xml

        ```xml
        <dependencies>
        ...
        <!-- https://mvnrepository.com/artifact/io.github.mweirauch/micrometer-jvm-extras -->
        <dependency>
            <groupId>io.github.mweirauch</groupId>
            <artifactId>micrometer-jvm-extras</artifactId>
            <version>0.2.1</version>
        </dependency>
        ...
        </dependencies>
        ```

   3. 修改启动类

        ```java
        import io.github.mweirauch.micrometer.jvm.extras.ProcessMemoryMetrics;
        import io.github.mweirauch.micrometer.jvm.extras.ProcessThreadMetrics;
        import io.micrometer.core.instrument.binder.MeterBinder;

        ...

        /* With Spring */
        @Bean
        public MeterBinder processMemoryMetrics() {
            return new ProcessMemoryMetrics();
        }

        @Bean
        public MeterBinder processThreadMetrics() {
            return new ProcessThreadMetrics();
        }
        ```

5. 请求端点

   `http://ip:port/actuator/prometheus`

6. 配置Prometheus
   1. 通过Eureka自动发现

        ```yaml
        - job_name: 'jvm'
          eureka_sd_configs:
            - server: http://ip:8761/eureka
          relabel_configs:
            - source_labels: [__meta_eureka_app_instance_metadata_prometheus_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
        ```

   2. 单个发现

        ```yaml
        - job_name: 'jvm'
          metrics_path: '/actuator/prometheus'
          static_configs:
            - targets: ['ip:port']
        ```

7. 展示在Grafana, ID: `4701`
