http://redis.cn

+ Redis高可用的常见方式:
  - [主从(Replication模式)](http://redis.cn/topics/replication.htm): 需要手动切换主从
    - [本文示例](#主从模式)
  - [哨兵(Redis-Sentinel模式)](http://redis.cn/topics/sentinel.html): 自动切换主从，不能动态扩容
    - [本文示例](#哨兵模式)
  - [集群(Redis-Cluster模式)](#http://redis.cn/topics/cluster-tutorial.html): 自动切换主从，可以动态扩容
    - [本文示例](#集群模式)
      - [集群模式说明](#集群模式说明)
  - [codis](https://github.com/CodisLabs/codis): Codis是一个用Go编写的基于代理的高性能Redis集群解决方案。

+ 问题分析:
  - 异步复制导致的数据丢失: 因为master->slave的数据同步是异步的，所以可能存在部分数据还没有同步到slave，master就宕机了，此时这部分数据就丢失了。
  - 脑裂导致的数据丢失: 当master所在的机器突然脱离的正常的网络，与其他slave、sentinel失去了连接，但是master还在运行着。此时sentinel就会认为master宕机了，会开始选举把slave提升为新的master，这个时候集群中就会出现两个master，也就是所谓的脑裂。此时虽然产生了新的master节点，但是客户端可能还没来得及切换到新的master，会继续向旧的master写入数据。当网络恢复正常时，旧的master会变成新的master的从节点，自己的数据会清空，重新从新的master上复制数据。

***全局环境: docker=19.03.5 docker-compose=1.24.1 centos=7.7***

### 主从模式
```bash
docker准备三个redis服务(一主两从)，增加配置，然后启动服务
## 主服务 - 配置
# 设置主服务密码
requirepass 111master
# 开启数据持久化(default: no)
appendonly yes

## 从服务 - 配置
# 设置从服务密码
requirepass 222slave
# 开启数据持久化(default: no)
appendonly yes
# 配置主服务地址、端口号 
slaveof 10.10.10.3 6379 
# 主服务密码 
masterauth "111master"
```

### 哨兵模式
```bash
docker准备三个redis服务(三哨兵)，需要单独准备配置文件，然后启动服务
## 配置项
# 指定监听端口
port 26379
# 指定数据目录
dir "/data"
# 配置指示Sentinel去监视一个名为mymaster的主服务器，这个主服务器的IP地址为10.10.10.3，端口号为6379，而将这个主服务器判断为失效至少需要2个Sentinel同意（只要同意Sentinel的数量不达标，自动故障迁移就不会执行）
sentinel monitor mymaster redis-master-1 6379 2
# 指定Sentinel认为服务器已经断线所需的毫秒数
sentinel down-after-milliseconds mymaster 30000
# 指定了在执行故障转移时,最多可以有多少个从服务器同时对新的主服务器进行同步,这个数字越小,完成故障转移所需的时间就越长.从服务器在载入主服务器发来的 RDB 文件时,仍然会造成从服务器在一段时间内不能处理命令请求: 如果全部从服务器一起对新的主服务器进行同步,那么就可能会造成所有从服务器在短时间内全部不可用的情况出现.可以通过将这个值设为1来保证每次只有一个从服务器处于不能处理命令请求的状态.
sentinel parallel-syncs mymaster 1
# 指定redis-master的认证密码
sentinel auth-pass mymaster 14YVeC0PToxRIAs_master_1
# 指定Sentinel认为服务器故障迁移超时时间所需的毫秒数
sentinel failover-timeout mymaster 30000
sentinel deny-scripts-reconfig yes
```

### 集群模式
```bash
docker准备9个redis服务(3主6从)，增加配置项，然后启动服务
## 配置文件
# 监听端口
port 7000
# 开启持久化存储
appendonly yes
### 使用密码开启保护模式 ###
# requirepass password
# masterauth password
### 不用密码关闭保护模式 ###
# 保护模式(defalult: yes),开启需要配置bind ip或者设置访问密码，关闭时外部网络可以直接访问
protected-mode no
# 开启集群模式
cluster-enabled yes
# 指定保存节点配置文件的路径(default: nodes.conf)，无需人为修改
cluster-config-file nodes.conf
# 指定集群节点超时时间(ms)
cluster-node-timeout 5

## 链接集群
# 创建网络
docker network create --attachable --subnet 10.0.10.0/24 --gateway 10.0.10.1 redis_net
# 链接集群，这个命令在这里用于创建一个新的集群, 选项–replicas 2 表示我们希望为集群中的每个主节点创建两个从节点。之后跟着的其他参数则是这个集群实例的地址列表,3个master6个slave
docker run --rm -it --network redis_net --env AUTH_PASSWORD=password rolesle/redis-trib redis-trib create --replicas 2 10.0.10.11:6379 10.0.10.12:6379 10.0.10.13:6379 10.0.10.14:6379 10.0.10.15:6379 10.0.10.16:6379 10.0.10.17:6379 10.0.10.18:6379 10.0.10.19:6379

# 客户端配置
## springcloud
spring.redis.cluster.nodes=redis-1:6379,redis-2:6379,redis-3:6379,redis-4:6379,redis-5:6379,redis-6:6379,redis-7:6379,redis-8:6379,redis-9:6379
spring.redis.database=0
spring.redis.password=password
spring.redis.timeout=6000
spring.redis.jedis.pool.max-active=8
spring.redis.jedis.pool.max-wait=-1
spring.redis.jedis.pool.max-idle=8
spring.redis.jedis.pool.min-idle=0
```

#### 集群模式说明:
  - 让集群正常运作至少需要三个主节点
  - 要保证集群中的 16384 个槽都有至少一个主节点在处理， 集群运作正常
  - Redis 集群不像单机版本的 Redis 那样支持多个数据库，集群只有数据库 0，而且也不支持 SELECT 命令
  - 所有的集群节点都通过TCP连接（TCP bus？）和一个二进制协议（集群连接，cluster bus）建立通信
  - Redis 集群是一个网状结构，每个节点都通过 TCP 连接跟其他每个节点连接。
  - 在一个有 N 个节点的集群中，每个节点都有 N-1 个流出的 TCP 连接，和 N-1 个流入的连接。 这些 TCP 连接会永久保持，并不是按需创建的。
  - 容忍集群中少数节点的出错,但对于要求大量网络分块（large net splits）的可用性的应用来说，这并不是一个合适的解决方案。
  - 键空间被分割为 16384 槽（slot），事实上集群的最大节点数量是 16384 个。（然而建议最大节点数量设置在1000这个数量级上）
  - 每个节点都有其他相关信息是所有节点都知道的：
  - 节点的 IP 地址和 TCP 端口号。
  - 各种标识。
  - 节点使用的哈希槽。
  - 最近一次用集群连接发送 ping 包的时间。
  - 最近一次在回复中收到一个 pong 包的时间。
  - 最近一次标识节点失效的时间。
  - 该节点的从节点个数。
  - 如果该节点是从节点，会有主节点ID信息。（如果它是个主节点则该信息置为0000000…）


+ 集群测试
    ```
    ===5 6
    1 5 6
    2 7 8
    3 9 4
    迁移后
    1 7
    2 8
    3 9 4
    恢复5,6后
    1 7 5 6
    2 8
    3 9 4
    关闭1后
    6 5 7
    2 8
    3 9 4
    恢复1后
    6 5 7 1
    2 8
    3 9 4
    关闭8后
    6 5 7
    2 1
    3 9 4
    恢复8后
    6 5 7
    2 1 8
    3 9 4
    ===1 2 3 x
    1 5 6
    2 7 8
    3 9 4
    ===1 2 x
    1 5 6
    2 7 8
    3 9 4
    ===1
    1 5 6
    2 7 8
    3 9 4
    迁移后
    6 5
    2 7 8
    3 9 4

    ====4 9 x
    1 5 6
    2 7
    3 8
    4 9
    ====4
    1 5
    2 7
    3 8
    9 6
    ```