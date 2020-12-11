# template
# 使用zabbix_discover_jvm.sh需要启动zabbix-agent和jvm进程的用户保持一致
jdk: 1.7,1.8
jvm分区:
  新生代
    伊甸园
    幸存区0
    幸存区1
  老生代
  永生代/元空间  (1.7/1.8)
- 获取当前机器正在运行的java程序，截取出一个或多个服务名;根据服务名查到PID，截取jstat [-gc|-gcutil] ,jinfo -sysprops PID输出结果
- 配置文件定义服务名称的key和监控项的key
- 模板自动发现，记录每个分区的总大小，已使用大小，使用百分比，GC回收次数，总回收次数，回收使用的时间，回收总时间，新生代回收次数，新生代回收使用时间,(java进程启动时间,~~tomat版本~~r,java版本,~~进程启动用户~~,~~服务存活~~,vm版本,java class版本)

1. zabbix_discover_jvm.sh
    - path:/etc/zabbix/scripts
1. zabbix_discover_jvm.conf
    - path: /etc/zabbix/zabbix-agentd.d
1. zbx_export_jvm_templates.xml
    - zabbix3.0监控jvm模板,web端导入模板用
1. zabbix_java_gateway.conf - server configure
    - path: /etc/zabbix/
>  ansible-playbook文件获取
>  https://github.com/mainiubaba/ansible_plus/blob/master/roles/zabbix/tasks/deploy_jvm.yml
>  User=name根据自己实际情况更改，name的值是java应用程序的运行用户
>  #ansible-playbook deploy_jvm.yml --extra-vars host_app=10.1.1.10
>  $ansible-playbook deploy_jvm.yml --extra-vars host_app=10.1.1.10 -s
>  执行后，在服务端测试,有返回值说明成功；没有的话，检查服务是否启动，启动用户是否一致
>  zabbix-get -s 10.0.0.10 -k custom.discover.jvm_app | jq .
>  然后在web端导入模板文件
>  最后在对应的主机添加模板，等会看有没有数据，没数据看监控项详情，会有提示。
