# 声明

> 启动前先把prometheus挂在的TSDB目录进行授权: `chown -R 65534.65534 ./volume/prometheus/data`

---

1. 告警规则来自: <https://awesome-prometheus-alerts.grep.to> 里面部分规则没有的是通过官方插件或文档获取的
   1. 规则获取日期: 2020-12-03
   2. 日期之后的规则可能会有更新,自己可进行对比或Fork此项目进行修改
2. 部分规则进行了简单的修改,可根据自己实际的情况进行调试
3. 告警规则文件: alertmanager-rules.yml
4. 当前规则包含:
   1. 栗子: 类别(exporter来源)-[Grafana Dashboard Id]
   2. prometheus(自身监控)
   3. host([prom/node-exporter](https://hub.docker.com/r/prom/node-exporter))-[8919,1856]
   4. blackbox([prom/blackbox-exporter](https://hub.docker.com/r/prom/blackbox-exporter))-[9965]
   5. mysql([prom/mysqld-exporter](https://hub.docker.com/r/prom/mysqld-exporter))-[7362]
   6. redis([oliver006/redis_exporter](https://hub.docker.com/r/oliver006/redis_exporter))-[763]
   7. rabbitmq([rabbitmq的prometheus插件,3.8.9之后自动开启(15692)](https://www.rabbitmq.com/prometheus.html))-[10991]
   8. ceph([ceph的prometheus模块,需手动开启(9283)](https://docs.ceph.com/en/latest/mgr/prometheus/))-[2842]
   9. jenkins([jenkins的prometheus插件,需手动安装(8080/prometheus)](https://plugins.jenkins.io/prometheus/))-[9524]
   10. jvm/eureka([MavenPlugin](./docs/jvm.md))-[4701]
5. 关于报警时间的问题
    1. Prometheus 告警自定义模板的默认使用的是`UTC`时间
    2. 改成北京时间,其中 `Add 28800e9`  就是表示加8个小时。[28800e9为什么表示8小时?](https://www.google.com/search?q=28800e9%E4%B8%BA%E4%BB%80%E4%B9%88%E8%A1%A8%E7%A4%BA8%E5%B0%8F%E6%97%B6%3F&oq=28800e9%E4%B8%BA%E4%BB%80%E4%B9%88%E8%A1%A8%E7%A4%BA8%E5%B0%8F%E6%97%B6%3F&aqs=chrome..69i64j69i57.2040j0j1&sourceid=chrome&ie=UTF-8)
        1. 改之前
           - 触发时间: `{{ .StartsAt.Format "2006-01-02 15:04:05" }}`
        2. 改之后
           - 触发时间: `{{ (.StartsAt.Add 28800e9).Format "2006-01-02 15:04:05" }}`
    3. 这样接收到告警的那一端时间显示就是对的了

下一步:

---

1. 规则,exporter,GDI(Grafana Dashboard Id)
   1. openstack([niedbalski/openstack-exporter-linux-amd64](https://quay.io/niedbalski/openstack-exporter-linux-amd64))-[9701]
   2. zipkin([zipkin内置的prometheus接口](https://github.com/le-shi/docker-zipkin))-[1598]
   3. harbor([zhangguanzhang/harbor_exporter](https://hub.docker.com/r/zhangguanzhang/harbor_exporter))
   4. docker([google/cadvisor](https://hub.docker.com/r/google/cadvisor))
   5. kubernetes-[13105]
   6. ingress-nginx([参考](https://github.com/kubernetes/ingress-nginx/tree/master/deploy/prometheus))-[9614]
   7. nginx-log-[13844]
   8. elasticsearch([justwatchcom/elasticsearch_exporter](https://github.com/justwatchcom/elasticsearch_exporter))-[6483]
2. PromQL如何使用
3. Alert告警规则如何配置
4. Grafana图表如何配置
