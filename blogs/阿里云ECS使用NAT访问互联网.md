
搭建NAT网关就是为了实现在相同VPC内，没有公网IP的ECS借助有公网的ECS访问外网，或者是外网通过端口映射访问到内网服务器。
SNAT：实现没有公网IP的ECS实例借助有公网的ECS访问外网，但是外网无法访问到内网IP；
DNAT：实现外网通过端口映射访问到内网服务器，但是不能实现内网ECS访问到外网。

设置SNAT规则，在有公网IP的ECS实例上操作
```
# 开启转发
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
# 生效
sysctl -p
# 配置iptables做SNAT：iptables -t nat -I POSTROUTING -s VPC的IP段 -j SNAT --to-source 有公网IP的ECS内网IP
# 写 /20 会报 Time to live exceeded ，写 /24 可以正常做 SNAT 转发
iptables -t nat -I POSTROUTING -s 172.22.112.0/24 -j SNAT --to-source 172.22.112.243
# 如果没有安装iptables,#安装iptables-services 
yum install -y iptables iptables-services 
# iptables规则重启会清空，永久生效，还需要保存在iptables配置文件中：
# 生成有效的规则，供手动保存
iptables-save
# 保存规则到 /etc/sysconfig/iptables 文件，防止重启导致的规则丢失
service iptables save
# 检查是否安装了iptables
systemctl status iptables.service
# 设置防火墙开机启动
systemctl enable --now iptables.service
```
设置VPC路由条目

阿里云 -> 专有网络 -> 管理 -> 路由表 -> 管理 -> 添加路由条目(自定义)
目标网段: 0.0.0.0/0
下一跳类型: ECS实例
ECS实例选择: 有公网IP的ECS实例

---

设置DNAT规则
```
# 将192.168.0.81的公网 80 端口映射给192.168.0.82
# iptables -t nat -I PREROUTING -p tcp --dport 有公网IP的ECS端口号 -j DNAT --to 目标内网ECS的内网IP
# iptables -t nat -I POSTROUTING -p tcp --dport 有公网IP的ECS端口号 -j MASQUERADE
iptables -t nat -I PREROUTING -p tcp --dport 80 -j DNAT --to 192.168.0.82
iptables -t nat -I POSTROUTING -p tcp --dport 80 -j MASQUERADE
service iptables save
```

前后端口映射不一致，需在/etc/sysconfig/iptables文件nat表的dnat转发规则（目标IP）后面，直接加特定的端口号就行：
systemctl restart iptables.service

---

阿里云-NAT网关
使用场景：

iptables规则冲突。如果ECS内安装了docker，docker自带的nat转发规则会有影响，需要合理的网段规划和路由规划。
外网端口占用过大，加上需要部署如：Rancher这种容器集群平台，还是推荐搭建使用阿里云-NAT网关，以绑定弹性公网IP的方式实现，这样就不需要占用ECS实例上的公网端口
