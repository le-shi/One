
如果使用Python3.x，请采用 <https://github.com/Chasii/ZabbixCli> 项目

`Python 2.7`

create_screen_for_hosts.py --生成单台主机的所有聚合图形

create_screen_for_item.py --生成某个监控项的聚合图形

create_screen_for_disk.py --生成磁盘监控的聚合图形

两个脚本(create_screen_for_item.py and create_screen_for_disk.py)唯一不同的就是width和height的值不一样。

---
# create_screen_for_hosts.py

执行命令

```bash
# 例子
# 现在zabbix前端确定主机名是什么，再进行填写
# python create_screen_for_hosts.py '主机名称' '自定义名'

python create_screen_for_hosts.py 'bid-1' 'host - bid-1'
python create_screen_for_hosts.py 'bid-2' 'host - bid-2'
python create_screen_for_hosts.py 'www-1' 'host - www-1'
python create_screen_for_hosts.py 'www-2' 'host - www-2'
python create_screen_for_hosts.py 'manage-1' 'host - manage-1'
python create_screen_for_hosts.py 'manage-2' 'host - manage-2'

输出结果

Screen Name: host - bid-1
Total Number of Graphs: 10
{"screenids": ["100"]}
```

---
# create_screen_for_item.py

执行命令

```bash
# 例子
# python create_screen_for_item.py -g '主机群组名' -G '图形名称全称' -c(列/单位) 2 -n '自定义名'

python create_screen_for_item.py -g 'Linux servers' -G 'Memory usage' -c 2 -n 'screen - 内存使用'

python create_screen_for_item.py -g 'Linux servers' -G 'CPU usage' -c 2 -n 'screen - CPU使用'

python create_screen_for_item.py -g 'Linux servers' -G '/: Disk space usage' -c 2 -n 'screen - 硬盘使用: /'

python create_screen_for_item.py -g 'Linux servers' -G 'TCP Status' -c 2 -n 'screen - TCP连接'

python create_screen_for_item.py -g 'Linux servers' -G 'Interface eth0: Network traffic' -c 2 -n 'screen - 网卡流量: eth0'

# 'width': ，'height': 参数来设置大小。
```

---
# create_screen_for_disk.py

执行命令

```bash
# 例子
# python create_screen_for_disk.py -g '主机群组名' -G '图形名称全称' -c 3 -n '自定义名'

python create_screen_for_disk.py -g 'Linux servers' -G '磁盘使用情况[Disk space usage /home]' -c 3 -n 'Serve_disk'
```
