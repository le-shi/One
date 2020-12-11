+ Rabbitmq四种工作模式：
  - 单机模式：单节点运行
  - 普通集群模式(普通队列)：多个机器运行多个MQ节点，每个节点创建的一个Queue都只会存在一个节点上，节点之间同步queue的元数据，当在进行消费的时候, 就算 连接到了其他的MQ节点上, 其也会根据内部的queue的元数据,从该queue所在节点上拉取数据过来.没有考虑高可用. 并且性能开销巨大.容易造成单节点的性能瓶颈. 并且如果真正有数据的那个queue的节点宕机了. 那么其他的节点就无法进行数据的拉取.这种方式只是通过集群部署的方式提高了消息的吞吐量
  - 镜像集群模式(HA队列)：与普通集群模式的主要区别在于. 无论queue的元数据还是queue中的消息都会同时存在与多个节点上.要开启镜像集群模式,需要在后台新增镜像集群模式策略. 即要求数据同步到所有的节点.也可以指定同步到指定数量的节点.任何一个服务宕机了,都不会影响整个集群数据的完整性, 因为其他服务中都有queue的完整数据, 当进行消息消费的时候,连接其他的服务器节点一样也能获取到数据.
    - [本文示例](#镜像集群模式)
  - 仲裁队列: 镜像队列的升级

+ Rabbitmq集群的三种网络分区模式:
  - cluster：应用于同一个网段内的局域网，不支持跨网段，可以随意的动态增加或减少，节点之间需要相同版本的rabbitmq和Erlang
  - federation：应用于广域网，允许单台服务器上的交换机或队列接受发布到另一个服务器的交换机或队列的消息，可以是单台或集群。类似于单向点对点连接，消息会在联盟队列之间转发任意次,直到被消费者接受.通常使用federation来连接internet上的中间服务器,用作订阅分发消息或者工作队列.
  - shovel：应用于广域网，连接方式与federation的连接方式类似,但它工作在更低层次。

+ Rabbitmq镜像集群的三种HA模式：

    rabbitmqctl set_policy [-p <vhost>] [--priority <priority>] [--apply-to <apply-to>] <name> <pattern>  <definition>
    
    rabbitmqctl set_policy [--apply-to <queues|exchanges|all>] 策略名称 匹配模式(正则) 镜像定义(json格式)

  - exactly: 需要参数`ha-params=count`,可选参数`ha-sync-mode=[automatic|manually]`,集群中队列副本的数量(主副本加上镜像).count值为1表示一个副本:只是队列主机。如果运行队列主机的节点变得不可用，则其行为取决于队列持久性。count值为2表示两个副本:一个队列主队列和一个队列镜像。换句话说:“NumberOfQueueMirrors=NumberOfNodes-1”。如果运行队列主服务器的节点变得不可用，队列镜像将根据配置的镜像提升策略自动提升到主服务器。如果集群中的节点数少于count的个数，则将队列被镜像到所有节点。如果集群中有多个计数节点，并且一个包含镜像的节点宕机，那么将在另一个节点上创建一个新镜像。使用' exactly '模式和' - ha-promot -on-shutdown ': ' always '可能是危险的，因为队列可以跨集群迁移，并在关闭时变得不同步。对于3个或更多节点的集群，建议复制到一个仲裁(大多数)节点，例如3个节点集群中的2个节点或5个节点集群中的3个节点。
  比如: `rabbitmqctl set_policy ha-two "^two\." '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'`
  - all: 可选参数`ha-sync-mode=[automatic|manually]`,队列在集群中的所有节点上传播镜像。当一个新节点被添加到集群中时，队列将被镜像到该节点。这个设置非常保守。建议镜像到集群节点的仲裁(N/2 + 1)。镜像到所有节点会给所有集群节点带来额外的负担，包括网络I/O、磁盘I/O和磁盘空间的使用。
  比如: `rabbitmqctl set_policy ha-all "ha\." '{"ha-mode":"all"}'`
  - nodes: 需要参数ha-params=<node names>,可选参数`ha-sync-mode=[automatic|manually]`,队列被镜像到节点名中列出的节点。节点名是在`rabbitmqctl cluster_status`中出现的Erlang节点名;它们的形式通常是“rabbit@hostname”。如果这些节点名中有任何一个不是集群的一部分，则不构成错误。如果在声明队列时列表中的节点都不在线，则将在声明客户机连接的节点上创建队列。
  比如: `rabbitmqctl set_policy ha-nodes "^nodes\." '{"ha-mode":"nodes","ha-params":["rabbitmq-a@rabbitmq-a","rabbitmq-b@rabbitmq-b"]}'`

+ Rabbitmq的持久化：
  - 交换机持久化: rabbitmqadmin declare exchange name=ex_master type=[fanout,direct,topic] durable=true
  - 队列持久化: rabbitmqadmin declare queue name=hello durable=true
  - 消息持久化: 需要生产者在生产消息的时候设置

+ 流程节点在停止和重新启动时经历的过程：
  - 磁盘节点：重新启动后，默认情况下，该节点将尝试与该对等节点联系10次，响应超时为30秒。如果对等节点在该时间间隔内可用，则节点将成功启动，同步对等节点的需求并继续运行。如果对等节点不可用，则重新启动的节点将放弃并自愿停止。
  - 当节点在关闭过程中没有在线的对等节点时，它将在不尝试与任何已知对等节点同步的情况下启动。它不能作为独立节点启动，但是对等节点将能够重新加入它。
  - 如果节点名称或主机名更改后的 数据目录路径随之更改，则该节点可以作为空白节点开始。这样的节点将无法重新加入群集。当节点处于脱机状态时，可以使用空白数据目录重置或启动其对等节点。在那种情况下，由于内部数据存储群集标识(ERLANG_COOKIE)不再匹配，恢复节点也将无法重新加入其对等节点。
  - 请考虑以下情形：
    ```
    形成一个由3个节点组成的集群A，B和C
    节点A已关闭
    节点B重置
    节点A启动
    节点A尝试重新加入B，但B的群集标识已更改
    节点B无法识别为已知的群集成员，因为它已被重置
    在这种情况下，节点B将拒绝A的群集尝试，并在日志中显示适当的错误消息：
    Node 'rabbit@node1.local' thinks it's clustered with node 'rabbit@node2.local', but 'rabbit@node2.local' disagrees
    在这种情况下，可以再次重置B，然后将能够加入A，或者可以重置A并成功加入B。
    结论：因此，当整个群集关闭时，最后一个关闭的节点是在关闭时唯一没有任何正在运行的对等节点的节点。该节点可以启动而无需先联系任何对等节点。由于节点将尝试与已知对等方联系最多5分钟（默认情况下），因此可以在该时间段内以任何顺序重新启动节点。在这种情况下，他们将成功地彼此重新加入。可以使用两种配置设置来调整此时间窗口：
    # 重试超时时间为60s(default: 30s)
    mnesia_table_loading_retry_timeout = 60000
    # 重试次数为15次(default: 10次)
    mnesia_table_loading_retry_limit = 15
    通过调整这些设置并调整必须返回已知对等方的时间窗口，可以解决可能需要超过5分钟才能完成的群集范围内的重新部署方案。
    ```
  - 升级期间，有时最后一个要停止的节点必须是升级后要启动的第一个节点。该节点将被指定执行集群范围的架构迁移，其他节点可以在它们重新加入时从中进行同步并应用。
  - 在某些情况下，无法恢复最后一个脱机节点。可以使用forget_cluster_node  rabbitmqctl命令将其从集群中删除。
  - 另外，可以在节点上使用force_boot  rabbitmqctl命令使其引导，而无需尝试与任何对等节点同步（就像它们最后一次关闭一样）。仅当最后一个要关闭的节点或一组节点永远不会重新联机时，才通常需要这样做。

+ 总结：
  - RabbitMQ集群中的所有节点都是对等的，没有特殊的节点
  - 强烈建议奇数个集群节点：1、3、5、7等
  - 节点可以是磁盘节点或RAM节点


***全局环境: docker=19.03.5 docker-compose=1.24.1 centos=7.7***

### 镜像集群模式
```bash
# 创建rabbitmq_net网络
docker network rm rabbitmq_net
docker network create --attachable --subnet 1.2.3.0/24 --gateway 1.2.3.1 rabbitmq_net

配置3个rabbitmq节点，准备docker部署需要的参数，启动服务
# 自定义节点名称,不能重复
RABBITMQ_NODENAME=rabbitmq-a
# 节点认证作用，部署集成时 需要同步该值,需要保持一致
RABBITMQ_ERLANG_COOKIE='YZDDDWMFSMKEMBDHSGGG'
# 自定义UI登陆用户
RABBITMQ_DEFAULT_USER=rabbit
# 自定义UI登陆密码
RABBITMQ_DEFAULT_PASS=TQ2YzFiY2JjYTM

# 创建集群(default: disc, chooice [ram])
## 进入rabbitmq容器
docker exec -ti rabbitmq-b bash
## 在B节点上,重置实例,加入A节点
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbitmq-a@rabbitmq-a
rabbitmqctl start_app
## 进入rabbitmq容器
docker exec -ti rabbitmq-a bash
## 在A节点上,查看集群状态
rabbitmqctl cluster_status
## 进入rabbitmq容器
docker exec -ti rabbitmq-c bash
## 加入C节点,选择集群中任意一个在线节点即可
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster rabbitmq-b@rabbitmq-b
rabbitmqctl start_app
# 此时是普通集群，只有元数据同步，没有同步queue中的消息
# 使用策略配置镜像集群
## 创建交换机-exchange
rabbitmqadmin declare exchange name=hello_ex type=direct durable=true
## 创建队列-queue
rabbitmqadmin declare queue name=hello_qu durable=true
## 创建路由绑定-binding
rabbitmqadmin declare binding source=hello_ex destination=hello_qu
## 创建镜像策略-policy，策略名hello-two，匹配hello开头的queue和exchange，ha模式镜像节点数为2，同步模式:自动
rabbitmqctl set_policy hello-two "^hello" '{"ha-mode":"exactly","ha-params":2,"ha-sync-mode":"automatic"}'
## 测试推送消息到队列
rabbitmqadmin publish exchange=hello_ex routing_key= payload="hello world...000"
rabbitmqadmin publish exchange=hello_ex routing_key= payload="hello world...111"
rabbitmqadmin publish exchange=hello_ex routing_key= payload="hello world...222"
## 获取队列消息
rabbitmqadmin get queue=hello_qu count=10

# rabbirmq单机->集群无缝上线方案
1. 搭建rabbitmq集群，原来单机不关
2. 修改服务的配置文件，然后重启各自其中一个实例(前提:服务是多副本,可以滚动更新的)
3. 修改其他服务配置文件，重启这些服务的1个实例；启动成功后，重启另一个实例
4. 待单机rabbitmq队列消费完成后，关闭单机rabbitmq
5. 重启服务的另一个实例

# 客户端配置
## springcloud
spring.rabbitmq.addresses=amqp://rabbitmq-a:5672,amqp://rabbitmq-b:5672,amqp://rabbitmq-3:5672
# Rabbitmq Management使用nginx反向代理
http {
...
upstream rabbitmq {
    server rabbitmq-a:15672;
    server rabbitmq-b:15672;
    server rabbitmq-3:15672;
}
...
    server {
        ...
        location ^~ /rabbitmq/ {
            proxy_pass http://rabbitmq/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  
        }
    }
}
```
