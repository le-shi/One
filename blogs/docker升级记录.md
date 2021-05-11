> 注意事项

    1. 升级docker会影响服务的运行
    2. 升级过程中服务需要停止
    3. 服务恢复正常工作的时间是: 重启docker时间 + 服务启动时间 = 总时间

1. 升级之前的确认
   1. 系统运行正常
   2. 使用 root 用户
2. 备份数据
3. 上传 docker 安装包到服务器上,使用 root 用户,上传目录是/root

4. 确定 docker 安装目录

   which docker

5. 备份旧版本的 docker

   mkdir docker_back
   cp -r $(dirname <尖括号内写步骤 4 的结果>)/{containerd,containerd-shim,ctr,docker,dockerd,docker-init,docker-proxy,runc} docker_back/

6. 确认 docker 版本

   docker -v

7. 确认 dockerd 版本

   dockerd -v

8. 确认 containerd 版本

   containerd -v

9. 解压 docker 安装包

   tar -xf docker-19.03.14.tgz

10. 停止运行的 docker 服务

    systemctl stop docker

11. 替换二进制安装包到 docker 的安装目录

    cp -rn docker/\* $(dirname <尖括号内写步骤 4 的结果>)

12. 启动 docker 服务

    systemctl start docker

13. 确认 docker 版本, 结果为: Docker version 19.03.14, build 5eb3275

    docker -v

14. 确认 dockerd 版本, 结果为: Docker version 19.03.14, build 5eb3275

    dockerd -v

15. 确认 containerd 版本, 结果为: containerd github.com/containerd/containerd v1.3.9 ea765aba0d05254012b0b9e595e995c09186427f

    containerd -v

16. 在 docker-compose.yaml 目录下, 启动应用程序

    docker-compose up -d

17. 检查服务是否都已经启动, 如果状态有 Exited 状态的服务, 需要手动执行启动: docker start <服务名>

    docker ps -a | grep -v portainer

18. 查看应用日志

    docker-compose logs -f --tail 1

19. 确保应用启动完成, 访问系统, 验证步骤 1.1 保障系统运行正常

20. docker升级完成
