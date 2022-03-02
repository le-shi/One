
- [Drone推荐-Github排行](<https://github.com/topics/continuous-delivery>)   
- [集成 Gitea 方法](<https://docs.drone.io/server/provider/gitea/>)
- [集成 Gitlab 方法](<https://docs.drone.io/server/provider/gitlab/>)

1. Drone 分为 Server 和 Runner
   1. Server 只负责和 git 服务之间交互、pipeline 任务的调度
   2. Runner 是真正干活的
2. 使用 docker 运行 Runner 时注意
   1. 运行 pipeline 时 Runner 会另启动一个新容器并创建一个网络(缺省网段递增的)，需要修改 docker 的默认网段，保证和内网网段不冲突
   2. docker 网卡的默认网段
      - bridge: `172.17.0.1/16`
      - docker_gwbridge: `172.18.0.1/20`
