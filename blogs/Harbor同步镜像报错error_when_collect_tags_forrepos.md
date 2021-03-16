# Harbor同步镜像报错: FetchArtifacts error when collect tags for repos

gayhub issue在`2020年5月22日`提到了是由于postgresql数据库连接数太少导致的，issue链接：<https://github.com/goharbor/harbor/issues/12003>

也给了解决方法：

1. 修改 postgresql 配置文件: `sed 's/max_connections =.*/max_connections=999/g' /data/database/postgresql.conf`
2. 重启 harbor-db 生效: `docker restart harbor-db`

> Postgresql:
如果max_connections设置的太大，就需要操作系统内核kernel.sem配置的越大，不然postgresql会报错, 官网解释: <https://www.postgresql.org/docs/9.6/kernel-resources.html>

相关错误日志:

```log
Mar 16 10:46:52 192.168.48.1 postgresql[5140]: FATAL:  could not create semaphores: No space left on device
Mar 16 10:46:52 192.168.48.1 postgresql[5140]: DETAIL:  Failed system call was semget(5432129, 17, 03600).
Mar 16 10:46:52 192.168.48.1 postgresql[5140]: HINT:  This error does *not* mean that you have run out of disk space.  It occurs when either the system limit for the maximum number of semaphore sets (SEMMNI), or the system wide maximum number of semaphores (SEMMNS), would be exceeded.  You need to raise the respective kernel parameter.  Alternatively, reduce PostgreSQL's consumption of semaphores by reducing its max_connections parameter.
Mar 16 10:46:52 192.168.48.1 postgresql[5140]: #011The PostgreSQL documentation contains more information about configuring your system for PostgreSQL.
Mar 16 10:46:52 192.168.48.1 postgresql[5140]: LOG:  database system is shut down
```

解决方法是:

1. 减小max_connections的值
2. 配置kernel.sem的值
