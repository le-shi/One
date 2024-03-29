# 声明

> 启动前先把prometheus挂载的目录进行授权: `chown -R 65534.65534 ./volume/{prometheus,pushgateway}`

---

1. 告警规则来自: <https://awesome-prometheus-alerts.grep.to> 里面部分规则没有的是通过官方插件或文档获取的
   1. 规则获取日期: 2020-12-03
   2. 日期之后的规则可能会有更新,自己可进行对比或Fork此项目进行修改
   3. 官方收集的exporter列表: <https://prometheus.io/docs/instrumenting/exporters/>
2. 部分规则进行了简单的修改,可根据自己实际的情况进行调试
3. 告警规则文件: volume/prometheus/config/alertmanager-rules.yml
4. 当前规则包含:
   1. 栗子: 类别-[exporter来源]-[Grafana Dashboard Id]
   2. prometheus-[自身监控]
   3. host-[[prom/node-exporter](https://hub.docker.com/r/prom/node-exporter)]-[8919,1856]
      1. 监控对象: 主机，服务器的磁盘，内存，CPU，网络，Inode，运行时间，负载，TCP状态，文件描述符，物理机温度
   4. blackbox([prom/blackbox-exporter](https://hub.docker.com/r/prom/blackbox-exporter))-[14792]
      1. 监控对象: http、https、tcp端点，ssl的过期时间
   5. mysql-[[prom/mysqld-exporter](https://hub.docker.com/r/prom/mysqld-exporter)]-[14934]
   6. redis, [点击查看几种方式的区别](https://redisgrafana.github.io/intro/)
      1. (推荐)grafana插件方式: [[redis-datasource](https://grafana.com/grafana/plugins/redis-datasource/)]-[12776]
      2. exporter方式: [[oliver006/redis_exporter](https://hub.docker.com/r/oliver006/redis_exporter)]-[763]
   7. rabbitmq-[[rabbitmq的prometheus插件,3.8.9之后自动开启(port: 15692)](https://www.rabbitmq.com/prometheus.html)]-[10991]
   8. ceph-[[ceph的prometheus模块,需手动开启(port: 9283)](https://docs.ceph.com/en/latest/mgr/prometheus/)]-[2842]
   9. jenkins-[[jenkins的prometheus插件,需手动安装(port: 8080/prometheus)](https://plugins.jenkins.io/prometheus/)]-[9524]
      1. 监控对象: jenkins的job
   10. jvm-[[MavenPlugin](./docs/jvm.md)]-[4701]
       1. 监控对象: java程序的jvm虚机使用情况
   11. domain-[[domain_exporter](https://github.com/le-shi/domain_exporter)]-[14605]
       1. 监控对象: 域名的到期时间
   12. 自定义规则
       1. ssh登录、DNS验证
5. 关于报警时间的问题
    1. Prometheus 告警自定义模板的默认使用的是`UTC`时间
    2. 改成北京时间,其中 `Add 28800e9`  就是表示加8个小时。[28800e9为什么表示8小时?](https://www.google.com/search?q=28800e9%E4%B8%BA%E4%BB%80%E4%B9%88%E8%A1%A8%E7%A4%BA8%E5%B0%8F%E6%97%B6%3F&oq=28800e9%E4%B8%BA%E4%BB%80%E4%B9%88%E8%A1%A8%E7%A4%BA8%E5%B0%8F%E6%97%B6%3F&aqs=chrome..69i64j69i57.2040j0j1&sourceid=chrome&ie=UTF-8)
        1. 改之前
           - 触发时间: `{{ .StartsAt.Format "2006-01-02 15:04:05" }}`
        2. 改之后
           - 触发时间: `{{ (.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}`
    3. 这样接收到告警的那一端时间显示就是对的了
6. 关于告警值小数点后面的数字过多的问题
   1. 假设规则: "Disk is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
   2. 默认情况下VALUE的值是这种格式的 `1.3009774758313586`
   3. 支持三种转换方法: `{{ printf "%.2f" $value }}` 或 `{{ $value | printf "%.2f" }}` 或 `{{ humanize $value }}`
   4. 使用第一种方法之后
      - 规则: "Disk is almost full (< 10% left)\n  VALUE = {{ printf \"%.2f\" $value }}\n  LABELS = {{ $labels }}"
      - VALUE的值: `1.30`
   5. 这样接收到告警的那一端数值就是转换过的了
7. 关于告警规则重复的问题
   1. alert和labels相同时认为是重复的规则
8. 警告的三种状态
   1. Inactive：非活动状态，表示正在监控，但是还未有任何警报触发。
   2. Pending：表示这个警报必须被触发。由于警报可以被分组、压抑/抑制或静默/静音，所以等待验证，一旦所有的验证都通过，则将转到 Firing 状态。
   3. Firing：将警报发送到 AlertManager，它将按照配置将警报的发送给所有接收者。一旦警报解除，则将状态转到 Inactive，如此循环。



下一步:

---

1. 规则,exporter,GDI(Grafana Dashboard Id)
   1. openstack-[[niedbalski/openstack-exporter-linux-amd64](https://quay.io/niedbalski/openstack-exporter-linux-amd64)]-[9701]
   2. zipkin-[[zipkin内置的prometheus接口](https://github.com/le-shi/docker-zipkin)]-[1598]
   3. harbor-[[zhangguanzhang/harbor_exporter](https://hub.docker.com/r/zhangguanzhang/harbor_exporter)]
   4. docker-container-[[google/cadvisor](https://hub.docker.com/r/google/cadvisor)]
   5. kubernetes-[13105]
   6. ingress-nginx-[[参考](https://github.com/kubernetes/ingress-nginx/tree/master/deploy/prometheus)]-[9614]
   7. nginx-log-[EFG](./docs/nginx.md)-[14913]
   8. elasticsearch-[[justwatchcom/elasticsearch_exporter](https://github.com/justwatchcom/elasticsearch_exporter)]-[6483]
   9. vmware-[[pryorda/vmware_exporter](https://github.com/pryorda/vmware_exporter)]
2. PromQL如何使用
3. Alert告警规则如何配置
4. Grafana图表如何配置




---

**开始**

```bash
# 创建docker网络
docker network create ops

# 创建mysql监控用户
CREATE USER 'exporter'@'%' IDENTIFIED BY 'prometheus';
GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'exporter'@'%';
GRANT SELECT ON performance_schema.* TO 'exporter'@'%';
```

---

**自定义指标的使用**

1. 准备自定义指标脚本(push_gateway.sh: 支持ssh登录人，dns校验)

   chmod +x /usr/sbin/push_gateway.sh

2. 配置服务.service

```bash
# cat > /usr/lib/systemd/system/push-gateway.service <<EOF
[Unit]
Description=push-gateway client

[Service]
Type=simple
ExecStart=/usr/sbin/push_gateway.sh
EOF
```

3. 配置服务.timer

```bash
# cat > /usr/lib/systemd/system/push-gateway.timer <<EOF
[Unit]
Description=push-gateway every 15s

[Timer]
# 定时器后指定的时间单位可以是：us(微秒), ms(毫秒), s(秒), m(分), h(时), d(天), w(周), month(月), y(年)。如果省略了单位，则表示使用默认单位‘秒’
# 多少(OnActiveSec)时间后，开始运行
OnActiveSec=30s
# 连续运行两次之间的间隔时间
OnUnitActiveSec=15s
Unit=push-gateway.service

[Install]
WantedBy=multi-user.target
EOF
```

4. 启用计时器

```bash
# 重新加载配置
systemctl daemon-reload
# 启动定时器
systemctl start push-gateway.timer
# 设置开机启动
systemctl enable push-gateway.timer
```

5. 查看

```bash
# 查看定时器，服务
systemctl status push-gateway.timer push-gateway.service
```
