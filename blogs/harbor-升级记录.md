> harbor 1.7.5升级1.9.3
<https://github.com/goharbor/harbor/blob/master/docs/migration_guide.md>

1. 停止harbor
1. 备份harbor, database目录
1. 下载1.9.3
1. 下载迁移工具 docker pull goharbor/harbor-migrator:v1.9.3
1. 转换配置文件，harbor.cfg to harbor.yml
docker run -it --rm -v ${harbor_cfg}:/harbor-migration/harbor-cfg/harbor.yml -v ${harbor_yml}:/harbor-migration/harbor-cfg-out/harbor.yml goharbor/harbor-migrator:v1.9.3 --cfg up
docker run -it --rm -v /home/centos/my_backup/harbor/harbor.cfg:/harbor-migration/harbor-cfg/harbor.yml -v /home/centos/harbor/harbor.yml:/harbor-migration/harbor-cfg-out/harbor.yml goharbor/harbor-migrator:v1.9.3 --cfg up
在harbor.yml最后加上
chart:
  absolute_url: disabled
1. 启动新的harbor

> harbor 1.9.3升级2.0.0
<https://github.com/goharbor/harbor/blob/a12bc4c6cdf1ef88c6ca7c2d33f15f10f8a94cc3/docs/administration/upgrade/_index.md>

1. 停止harbor1.9.3
1. 备份harbor, database目录
1. 下载2.0.0并解压
1. 下载迁移工具 docker pull goharbor/prepare:v2.0.0
1. 复制harbor.yml.tmp到harbor.yml准备升级(官方文档写的感觉没啥用)
1. 升级旧的配置文件,旧配置文件会被升级操作修改,上面已经备份harbor目录
docker run -it --rm -v /:/hostfs goharbor/prepare:v2.0.0 migrate -i ${旧harbor.yml的物理路径上}
1. 将升级后的配置文件拷贝到2.0.0的目录里
1. 启动新的harbor

\# 如果存储路径使用的不是默认的/data目录，需要修改docker-compose.yaml文件里面的./common路径，1.9.x后的版本每次执行./install.sh脚本都会重新生成一个新的compose文件，所以如果对compose有修改，请在执行./install.sh时提前进行备份
