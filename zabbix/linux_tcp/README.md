# template
Usage:
.查询当前机器的进程，存到/tmp/tcp_satus.txt文件 <bash zabbix_tcp_status.sh>
..查询机器有多少LISTEN的进程 <bash zabbix_tcp_status.sh LISTEN>

1. zabbix_tcp_status.conf
path:/etc/zabbix/zabbix_agentd.d
2. zabbix_tcp_status.sh
path:/etc/zabbix/scrips
3. zbx_export_linux_tcp_templates.xml
zabbix3.0监控linux tcp模板,web端导入模板用
