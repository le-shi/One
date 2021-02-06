# ELK

---

## 日志分析说明

1. 应用日志规范
2. 收集规范
3. 数据清洗
4. 数据量评估
5. 集群大小规划
6. 展示
7. 集成
8. 监控Es集群

## web(nginx)分析指标参考

> Grafana Dashboard ID: 13841
> nginx配置参考，[优化笔记](优化笔记.md)

```text
PV
UV

(需要$body_bytes_sent，$bytes_sent，$request_length对应的字段转换为整型)
请求总大小 0
返回总大小 0

HTTP 状态码
请求方法
访问 IP TOP 10
访问URL TOP 10
请求来源 TOP 10
客户端浏览器标识 TOP 10
访问主机 TOP 10
upstream响应时间 TOP 10 -0

访问量趋势
请求方法PV趋势
状态码PV趋势
响应时间趋势 0
upstream响应时间趋势 0
请求报文流量趋势 0
返回客户端流量趋势 0


(依赖GeoIP和第三方地图)
访问者城市
```

[!nginx日志分析效果图](null)

- IP库
- [ip2region - 准确率99.9%的离线IP地址定位库](https://github.com/lionsoul2014/ip2region)