
> 原有机器故障，将 整个数据库软件和实例 迁移到新机器

1. 为了减少实例迁移产生其他问题，新旧机器的操作系统都是 `CentOS 7` (同一种包管理系列的操作系统，理论上这种迁移操作方法是通用的，但是没有测试过)

2. 在旧机器上停止 dm 相关服务

   ```bash
   # 停止数据库
   systemctl stop DmAPService.service DmServiceDMSERVER.service

   ## 检查是否使用 "MAL 系统"(MAL系统信息视图) ##
   # 获取数据库安装目录
   export $(su - dmdba -c "env | grep DM_HOME")
   # 找到配置文件路径
   dm_config_path=$(dirname $(find ${DM_HOME} -name dm.ini))
   # 检查是否开启，0表示关闭，1表示开启
   grep "MAL_INI" ${dm_config_path}/dm.ini
   # 如果是0，跳过 "检查 MAL系统"
   # 如果是1，继续检查配置文件 ${dm_config_path}/dmmal.ini
   # 相关参数如下: 更多详细内容，请参考: DMx系统管理员手册.pdf
   # MAL_INST_HOST 是 "MAL系统" 监听的达梦服务地址
   # MAL_INST_PORT 是 "MAL系统" 监听的达梦服务端口
   # MAL_HOST 是 "MAL系统" 的监听IP
   # MAL_PORT 是 "MAL系统" 的监听端口；没有缺省值，需要自定义

   # 检查 - 确认已停止服务，查不到 5236 即可
   ss -anplt | grep 5236
   ss -anplt | grep MAL_PORT
   ```

3. 在新机器上创建对应的普通用户账号

   ```bash
   # 创建用户组
   groupadd -g 12349 dinstall
   useradd -u 12345 -g dinstall -m -d /home/dmdba -s /bin/bash dmdba
   # 设置 dmdba 用户密码
   echo -n 'dmdba:复杂的密码' | chpasswd
   ```

4. 同步相关文件

   ```bash
   # 在旧机器操作

   # 获取数据库安装目录
   su - dmdba -c "env | grep DM_HOME"
   # 同步数据库安装目录
   rsync -avzPh DM_HOME NEW_HOST_IP:/home/
   
   # 同步声明文件
   rsync -avzPh /etc/dm_svc.conf NEW_HOST_IP:/etc/
   rsync -avzPh /usr/lib/systemd/system/DmServiceDMSERVER.service NEW_HOST_IP:/usr/lib/systemd/system/DmServiceDMSERVER.service
   rsync -avzPh /usr/lib/systemd/system/DmAPService.service NEW_HOST_IP:/usr/lib/systemd/system/DmAPService.service
   ```

5. 其他配置

   ```bash
   # 如果使用 "MAL 系统"，继续当前步骤，不使用跳过
   # 使用 "MAL系统" 需要安装 libicu 工具包(国际Unicode组件)
   yum install libicu
   # 修改配置文件 dmmal.ini 的参数: MAL_INST_HOST 和 MAL_HOST ，将旧机器的IP地址更换为新机器的IP地址，其他配置不需要改动
   ${dm_config_path}/dmmal.ini
   # 和旧机器相关的 MAL实例 ，也需要同步修改 ${dm_config_path}/dmmal.ini ，将旧机器的IP地址更换为新机器的IP地址，然后重启达梦实例
   ```

6. 启动新机器的数据库

    ```bash
    systemctl enable --now DmAPService.service DmServiceDMSERVER.service
    systemctl status DmAPService.service DmServiceDMSERVER.service
    ```

7. 验证操作

    ```bash
    # 查看端口监听
   ss -anplt | grep 5236
   ss -anplt | grep MAL_PORT

    # 通过客户端工具连接
    # 查询数据
    ```
