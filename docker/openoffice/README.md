[Apache OpenOffice 官网](http://www.openoffice.org/) 

DockerHub地址: [rolesle/openoffice](https://hub.docker.com/r/rolesle/openoffice)

**build** *dockerhub的镜像采用离线方式构建,详情参考对应版本说明文档*

进入到\<version>目录

`docker build -t openoffice:<version> .`

**run**

`docker run -d -p 8100:8100 openoffice:<version>`

**docker-compose**

```
version: '3'

services:
  openoffice:
    container_name: openoffice
    image: rolesle/openoffice:4.1.7
    # 解决转PDF中文乱码问题
    #volume:
    #  - /path/to/fonts:/opt/openoffice4/share/fonts/truetype
    #  - /public/to/files:/other/server/path
    ports:
      - 8100:8100
```

**说明**
- word转PDF中文乱码问题，因为中文字体种类众多，所以需要手动挂载中文字体目录到office字体目录
- docker运行openoffice，数据目录需要和服务调用方(谁请求openoffice)共享，容器内的挂载路径和调用方保持一致；如果有共享存储，可以使用共享存储挂载；如果没有，尽量保证openoffice和调用方在同一台宿主机上运行(kubernetes根据自己实际情况调整)
- 附件的名字或路径不能有中文(客户端报的错,是说openoffice加载文件失败)


---
- 2019年11月8日: 修复只能本地连接的问题
- 2019年11月22日: 修复word文件转PDF中文乱码问题
- 2020年06月11日: 添加共享数据目录说明，添加volume挂载示例