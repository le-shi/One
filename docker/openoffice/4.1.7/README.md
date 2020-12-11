DockerHub地址: [rolesle/openoffice](https://hub.docker.com/r/rolesle/openoffice)

- 离线：如果网络不畅或缓慢，请使用`Dockerfile`，手动`下载`[OpenOffice软件包](https://jaist.dl.sourceforge.net/project/openofficeorg.mirror/4.1.7/binaries/zh-CN/Apache_OpenOffice_4.1.7_Linux_x86-64_install-rpm_zh-CN.tar.gz)放到当前目录下，执行构建

- 在线：如果网络速度较快，使用`Dockerfile.online`，执行构建

<font color=red>注: OpenOffice软件包大小: 152.8MB</font>

**build** *dockerhub的镜像采用离线方式构建*

`docker build -t openoffice:4.1.7 .`
