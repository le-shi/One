#### 守护进行模式 Or docker异步设置
我想在容器中以流畅的方式聚合容器日志。要自动使用流畅的日志驱动程序，我可以使用该选项启动de docker守护程序

--log-driver=fluentd --log-opt fluentd-async-connect=true

#### 使用fluentd收集docker的日志-内有fluentd-docker异步设置链接

http://www.imekaku.com/2016/09/08/docker-log-fluentd/

https://segmentfault.com/a/1190000000730444

#### Github Fluentd-conf

https://github.com/fluent/fluentd/blob/master/fluent.conf

#### a file generator that renders templates using docker container meta-data.

https://github.com/jwilder/docker-gen

#### docker-gen fluentd模板

https://github.com/jwilder/docker-gen/blob/master/templates/fluentd.conf.tmpl

---

注意：这里最好需要再fluentd的选项中指定--log-opt fluentd-async-connect=true，如果没有指定，当你的fluentd进程挂了之后，容器就会立即终止，这样服务就挂了。

官网原文：”If container cannot connect to the Fluentd daemon on the specified address and fluentd-async-connect is not enabled, the container stops immediately.”

注意：运行fluentd时，如果遇到：

2016-09-18 11:35:00 -0400 [error]: unexpected error error_class=Errno::EADDRINUSE error=#< errno::eaddrinuse: Address already in use - bind(2) for "0.0.0.0" port 24224>

类似的错误，需要先关掉td-agent，在终端执行/etc/init.d/td-agent stop

提示：log tag支持如下，官网说明：

{{.ID}}，{{.FullID}}，{{.Name}}，{{.ImageID}}，{{.ImageFullID}}，{{.ImageName}}，{{.DaemonName}}
