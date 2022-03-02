# Elasticsearch

> 自定义镜像请参考: 坚果云备份目录 **extend/elasticsearch** ，包含了自定义内容和镜像的简单使用说明

生产环境条件:

1. 设置 `vm.max_map_count` 最少是 `262144`: `sysctl -a | grep "vm.max_map_count"`
   - 临时生效: `sysctl -w vm.max_map_count=262144`
   - 永久生效: `echo "vm.max_map_count=262144" >> /etc/sysctl.conf && sysctl -p`
2. 配置文件必须能让 elasticsearch 用户读取
3. 增加 nofile 和 nproc 的 ulimits 限制
   - 检查: `docker run --rm centos:8 /bin/bash -c 'ulimit -Hn && ulimit -Sn && ulimit -Hu && ulimit -Su'`
   - 设置: `docker run --ulimit nofile=65535:65535`
4. 关闭 swapping
   - 设置: `docker run -e "bootstrap.memory_lock=true" --ulimit memlock=-1:-1`
5. 手动设置堆大小，如果使用16g，官方不建议在生产中使用ES_JAVA_OPTS
   - 设置: `docker run -e ES_JAVA_OPTS="-Xms16g -Xmx16g"`
6. 将部署的镜像固定为特定版本
7. 始终绑定数据卷
   - 说明: 应该使用卷绑定的目录是 `/usr/share/elasticsearch/data`
8. 避免使用 loop-lvm 模式
   - 说明: 如果您正在使用devicemapper存储驱动程序，请不要使用默认的loop-lvm模式。配置docker-engine使用direct-lvm
9. 集中你的日志
   - 说明: 考虑使用不同的日志驱动程序来集中日志。还要注意，默认的json文件日志驱动程序并不适合于生产使用。

---

ES开启密码认证

1. 配置文件

   - 配置文件 elasticsearch.yml 添加 `xpack.security.enabled
   - =true`

   或者
   
   - docker启动时添加环境变量 `xpack.security.enabled: true`

   > 如果是集群，还需要在docker启动时添加环境变量 `xpack.security.transport.ssl.enabled=true` ，配置文件中加入以下参数，启用传输安全

   ```yml
   xpack.security.transport.ssl.verification_mode: certificate
   xpack.security.transport.ssl.keystore.path: elastic-certificates.p12
   xpack.security.transport.ssl.truststore.path: elastic-certificates.p12
   ```

2. 设置密码，生成或设置的密码自行记录

   - 需要进到容器里 ./bin/elasticsearch-setup-passwords auto

3. 访问

   ```bash
   curl -u elastic:密码 http://0.0.0.0:9200
   ```

---

备份集群 <https://www.elastic.co/guide/en/elasticsearch/reference/7.14/backup-cluster.html>

---

使用docker方式部署在多台机器(和其他机器混用的情况)下，使用 `主机网络` 模式，减少复杂度

---

一个运行中的 Elasticsearch 实例称为一个节点，而集群是由一个或者多个拥有相同 cluster.name 配置的节点组成， 它们共同承担数据和负载的压力。当有节点加入集群中或者从集群中移除节点时，集群将会重新平均分布所有的数据。

当一个节点被选举成为 主 节点时， 它将负责管理集群范围内的所有变更，例如增加、删除索引，或者增加、删除节点等。 而主节点并不需要涉及到文档级别的变更和搜索等操作，所以当集群只拥有一个主节点的情况下，即使流量的增加它也不会成为瓶颈。 任何节点都可以成为主节点。我们的示例集群就只有一个节点，所以它同时也成为了主节点。

作为用户，我们可以将请求发送到 集群中的任何节点 ，包括主节点。 每个节点都知道任意文档所处的位置，并且能够将我们的请求直接转发到存储我们所需文档的节点。 无论我们将请求发送到哪个节点，它都能负责从各个包含我们所需文档的节点收集回数据，并将最终结果返回給客户端。 Elasticsearch 对这一切的管理都是透明的。

---
官方公网镜像推送到私服，加快内网部署速度

```bash
# 拉镜像
ELK_VER=7.14.0
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:${ELK_VER}
docker pull docker.elastic.co/elasticsearch/elasticsearch:${ELK_VER}
docker pull docker.elastic.co/kibana/kibana:${ELK_VER}
docker pull docker.elastic.co/kibana/kibana-oss:${ELK_VER}
docker pull docker.elastic.co/logstash/logstash:${ELK_VER}
docker pull docker.elastic.co/logstash/logstash-oss:${ELK_VER}

docker pull docker.elastic.co/beats/auditbeat:${ELK_VER}
docker pull docker.elastic.co/beats/auditbeat-oss:${ELK_VER}
docker pull docker.elastic.co/beats/elastic-agent:${ELK_VER}
docker pull docker.elastic.co/beats/elastic-logging-plugin:${ELK_VER}
docker pull docker.elastic.co/beats/filebeat:${ELK_VER}
docker pull docker.elastic.co/beats/filebeat-oss:${ELK_VER}
docker pull docker.elastic.co/beats/heartbeat:${ELK_VER}
docker pull docker.elastic.co/beats/heartbeat-oss:${ELK_VER}
docker pull docker.elastic.co/beats/journalbeat:${ELK_VER}
docker pull docker.elastic.co/beats/journalbeat-oss:${ELK_VER}
docker pull docker.elastic.co/beats/metricbeat:${ELK_VER}
docker pull docker.elastic.co/beats/metricbeat-oss:${ELK_VER}
docker pull docker.elastic.co/beats/packetbeat:${ELK_VER}
docker pull docker.elastic.co/beats/packetbeat-oss:${ELK_VER}
```

```bash
#!/bin/bash
# ELK官方镜像，推私服
# docker.elastic.co/elasticsearch/elasticsearch:${ELK_VER} -> 私服地址/elk/elasticsearch:${ELK_VER}

OLD_NAME=$(docker image ls | grep docker.elastic.co | awk  '{print $1}')
NEW_NAME_1=私服地址/elk/
ELK_VER=7.14.0

for i in ${OLD_NAME};
do
  NEW_ID=$(echo ${i} | awk -F "/" {'print $NF'})
  NEW_NAME_2=${NEW_NAME_1}${NEW_ID}:${ELK_VER}
  echo  ${NEW_ID}  - ${NEW_NAME_2}
  docker tag ${i}:${ELK_VER} ${NEW_NAME_2}
  docker push ${NEW_NAME_2}
done
```

# Kibana

## 安装 Sense

Sense 是一个 Kibana 应用 它提供交互式的控制台，通过你的浏览器直接向 Elasticsearch 提交请求。 这本书的在线版本包含有一个 View in Sense 的链接，里面有许多代码示例。当点击的时候，它会打开一个代码示例的Sense控制台。 你不必安装 Sense，但是它允许你在本地的 Elasticsearch 集群上测试示例代码，从而使本书更具有交互性。


1. 安装与运行 Sense：

        在 Kibana 目录下运行下面的命令，下载并安装 Sense app：

        ./bin/kibana plugin --install elastic/sense 

        Windows上面执行: bin\kibana.bat plugin --install elastic/sense 。

        NOTE：你可以直接从这里 https://download.elastic.co/elastic/sense/sense-latest.tar.gz 下载 Sense 离线安装可以查看这里 install it on an offline machine 。

2. 启动 Kibana.

        ./bin/kibana 

        Windows 上启动 kibana: bin\kibana.bat 。

3. 在你的浏览器中打开 Sense: 
   
   - <http://localhost:5601/app/sense>