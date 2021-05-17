# 容器化部署时，容器的IP不是真实IP，如何查找注册到Eureka的服务，来自哪个真实主机

1. 在Eureka机器上，使用 tcpdump 命令抓取请求端口是8761的数据: `sudo tcpdump -i eth0 -n port 8761 -w eureka.log`
2. 把数据包文件拿到 wireshark 解析
3. 设置过滤条件: `ip.dst == 10.10.10.14` ，其中 *10.10.10.14* 是Eureka的IP地址，只显示目的地址是Eureka的请求
4. 导出分析结果: `文件`-`导出分组解析结果`-`为纯文本`，分组格式选择 `详情`-`全部收起`，保存后的文件叫 eureka_request.txt
5. 通过查看文件头信息可以发现，第三个(Source)字段表示源地址，第七个(Info)字段表示请求详情: `head -n 2 eureka_request.txt`
6. 查找符合条件的记录: `awk '/PUT \/eureka\/apps\/大写服务注册名字/{print $3,$8}' eureka_request.txt | awk -F '/' '{print $1,$4}' | sort | uniq`
   1. 查看所有服务的主机IP地址: `awk '/PUT \/eureka\/apps\//{print $3,$8}' eureka_request.txt | awk -F '/' '{print $1,$4}' | sort | uniq`
   2. 同时查看多个指定服务的主机IP地址: `awk '/PUT \/eureka\/apps\//{print $3,$8}' eureka_request.txt | awk -F '/' '{print $1,$4}' | sort | uniq | grep -Ei '服务1|服务2|服务3'`
7. 显示结果是 `172.30.1.9 TEST` 这种形式，第一列就是服务的主机IP地址，第二列是服务名，如果是多副本(多实例)显示的真实主机IP地址可能是多个
