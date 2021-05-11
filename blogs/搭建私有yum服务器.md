# 搭建yum源服务器
服务端启动nginx提供http服务,根目录指向镜像的rpm目录,使用createrepo初始化镜像源索引;更新镜像使用reposync;更新镜像源索引使用createrepo --update;添加一个镜像地址时将repo文件放到/etc/yum.repo.d/下
客户端的yum.repo.d文件指向服务端并重建缓存,安装测试

服务端

    web服务: nginx 暴露url
    本地源: 本地镜像一份远程,并创建仓库信息
    源同步: reposync定时更新
客户端

    配置web服务地址
    重建缓存 yum clean all && yum makecache

## 服务端配置
1. 装个nginx,配置如下
```conf
server {
    # 指定默认
    listen 80 default_server;
    # 指定字符集是utf-8
    charset utf-8;
    # 开启目录展示
    autoindex on;
    # 关闭详细文件大小统计，让文件大小显示MB，GB
    autoindex_exact_size off;

    location / {
        root /mnt/yum;
    }

}
```
2. 安装管理工具: yum -y install createrepo
3. 备份/etc/yum.repo.d/原有repo后清空
4. 下载阿里云的repo文件
    ```bash
    wget -O /etc/yum.repos.d/CentOS7-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
    wget -O /etc/yum.repos.d/CentOS7-epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    ```
5. 清理yum缓存并重建缓存: 
    yum clean all
    yum makecache
6. 查看repolist: 
    yum repolist
7. 同步下载包: 
    reposync -p /mnt/yum
8. 建仓(供客户端检索使用)
**初始化索引**
createrepo --database --pretty /mnt/yum/base/Packages
createrepo --database --pretty /mnt/yum/epel/Packages
createrepo --database --pretty /mnt/yum/extras/Packages
createrepo --database --pretty /mnt/yum/updates/Packages
**更新索引 - 以后每增加/删除一个rpm都需要执行**
createrepo --update /mnt/yum/base/Packages
createrepo --update /mnt/yum/epel/Packages
createrepo --update /mnt/yum/extras/Packages
createrepo --update /mnt/yum/updates/Packages
9. 定时更新
将同步命令放到crontab里, 同步完执行更新索引操作


## 客户端配置
1. 备份/etc/yum.repo.d/原有repo后清空
2. 新建new.repo, 内容如下
```shell
# 当前源的名字,不可以重复
[new_base]
# 名字
name=source_from_loaclserver
# 镜像地址
baseurl=http://服务端地址/yum/base/Packeages
# gpg检测(1-开启 0-不开启)
gpgcheck=0
# #yum源是否启用(1-启用 0-不启用)
enable=1
#检索优先级
priority=1
 
[new_extras]
name=source_from_loaclserver
baseurl=http://服务端地址/yum/extras/Packeages
gpgcheck=0
enable=1
priority=2
 
[new_updates]
name=source_from_loaclserver
baseurl=http://服务端地址/yum/updates/Packeages
gpgcheck=0
enable=1
priority=3
 
[new_epel]
name=source_from_loaclserver
baseurl=http://服务端地址/yum/epel/Packeages
gpgcheck=0
enable=1
priority=4
```
3. 清理yum缓存并重建缓存: 
    yum clean all
    yum makecache
4. 测试安装
   yum install gcc