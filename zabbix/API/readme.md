
`Python 2.7`

screen_hosts.py --生成单台主机的所有聚合图形

create_screen.py --生成某个监控项的聚合图形

disk_create_screen.py --生成磁盘监控的聚合图形

两个脚本（create_screen.py and disk_create_screen.py）唯一不同的就是width和height的值不一样。

---
# creen_hosts.py

执行命令

`python screen_hosts.py '主机名' '自定义名'`

输出结果

```
Screen Name: 10.0.1.4
Total Number of Graphs: 10
{"screenids": ["47"]}
```

---
# create_screen.py

执行命令

`python create_screen.py -g 'Linux servers' -G '内存使用率[Memory usage]' -c 2 -n '内存'`

`python create_screen.py -g 'Linux servers' -G '网卡流量[Network traffic on eth1]' -c 2 -n '网卡流量'`

`python create_screen.py -g '主机群组名' -G '图形名称全称' -c(列/单位) 2 -n '自定义名'`

'width': ，'height': 参数来设置大小。

---
# disk_create_screen.py

执行命令

`python disk_create_screen.py -g 'Linux servers' -G '磁盘使用情况[Disk space usage /home]' -c 3 -n 'Serve_disk'`

`python disk_create_screen.py -g '要显示的群组' -G '要显示的图形' -c 3 -n '在screen 里面显示的名称'`

