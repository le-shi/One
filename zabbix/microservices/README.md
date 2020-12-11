# template
Usage:
- 查询当前Eureka中注册的服务,返回json体 `python zabbix_micro_discover.py`
- 查询当前Eureka中注册服务的健康状态,返回字符串 `python zabbix_micro_discover.py API`

1. zabbix_micro_services.conf
path:/etc/zabbix/zabbix_agentd.d
2. zabbix_micro_discover.py
path:/etc/zabbix/scrips
3. zbx_export_micro_services_templates.xml
zabbix3.0监控micro services模板,web端导入模板用
