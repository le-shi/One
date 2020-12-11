# template
.先测试redis能不能正常连接; <ping | grep -c PONG>
..使用命令查看redis服务信息，通过shell脚本对结果进行切割处理，截取出某某键的值(use_memory:10240); <info>
...zabbix_redis.conf文件定义键值，调用并接收shell脚本处理输出的结果.

1. zabbix_redis.conf
path:/etc/zabbix/zabbix_agentd.d
2. zabbix_redis.sh
path:/etc/zabbix/scrips
3. zbx_export_redis_templates.xml
zabbix3.0监控redis模板,web端导入模板用
