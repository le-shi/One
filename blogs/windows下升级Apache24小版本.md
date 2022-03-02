windows下升级Apache24小版本



> 运行 Apache 2.4 的主要 Windows 平台是 Windows 2000 或更高版本。
> 
> Apache HTTP Server 2.2 之后的版本不能在 Windows 2000 之前的任何操作系统上运行。


准备工作
---

1. 查看当前 Apache 安装路径
    1. 在右下方任务托盘里，找到 "Apache Monitor" 服务, 右击，选择 "Open Services"，打开 "服务" 窗口
    2. 在服务列表，找到 "Apache24" 服务, 右击，查看属性
    3. 找到 "可执行文件的路径:" "D:\Apache24\bin\httpd.exe" -k runservice
    4. 当前 Apache 的安装路径是: D:\Apache24
2. 查看当前 Apache 的版本信息
    1. 在安装路径的 bin 目录下，空白处按着 shift+鼠标右击, 在此处打开命令窗口
    2. 查看版本号: httpd.exe -v
    3. 查看编译信息: httpd.exe -V
        1. 通过 "Distributed by:" 可以得知 Apache提供商
        2. 通过 "Compiled with:" 可以得知当前 Apache 的编译环境
3. 查看当前 Apache 使用的 ssl 类型，
    1. 在 bin 目录下，使用命令 `dir | findstr ssl.exe` 查找 exe 结尾的文件
    2. 存在 libressl.exe 文件，说明 Apache 使用的 Libressl
    3. 存在 openssl.exe 文件，说明 Apache 使用的 Openssl
4. Apache HTTP Server 项目本身不提供软件的二进制版本，只提供源代码。个别供应商可能会提供二进制包以方便使用
5. 根据上面查询的 Apache供应商 和 ssl 类型，去对应的网站下载对应的二进制包(安装包)
    1. 显示: "Distributed by: The Apache Haus", 对应的下载地址: <http://www.apachehaus.com/cgi-bin/download.plx>
       1. 下载的安装包: httpd-2.4.52-lre342-x64-vs16.zip
    2. 其他版本，请到 [官网说明](https://httpd.apache.org/docs/current/platform/windows.html) 查看对应的下载地址

备份
---

1. 将原目录进行备份(logs目录除外)

升级
---

- 升级前
  - 原Apache目录: `D:\Apache24`
  - 新Apache目录: `D:\Apache2452`(解压后重命名产生)

1. 将 新下载的安装包 `httpd-2.4.52-lre342-x64-vs16.zip` 上传到服务器后解压, 解压后的目录结构大概是这样 httpd-2.4.52-lre342-x64-vs16\Apache24
2. 重命名 新版本的Apache目录为 Apache2452
3. 将 新Apache目录 放到 原Apache目录 的同级目录
4. 切换目录到 新Apache目录
5. 使用命令行查看新版本: `.\bin\httpd.exe -v`
6. 重命名新版本的 conf 目录为 conf-bak
7. 将 原 Apache 的 conf 目录，复制到 新 Apache 目录下
8. 修改拷贝过来的 conf\httpd.conf ，将 ServerRoot 改为现在的目录
9. 运行 `.\bin\httpd.exe -t` 检查语法
10. 遇到报错1 缺少 mod_js.so ，拷贝 原 Apache 的 modules\mod_jk.so 文件 到 新 Apache 的 modules 目录下面
11. 再次运行 `.\bin\httpd.exe -t` 检查语法
12. 遇到报错2 缺少 证书文件 `SSLCertificateFile: file 'D:/Apache2452/cert/5758300__zzcqwq.com_public.crt' does not exist or is empty` ，拷贝 原 Apache 的 cert 目录 到 新 Apache 目录下
13. 再次运行 `.\bin\httpd.exe -t` 检查语法
14. 提示 Syntax OK ，说明使用新版本的 Apache 可以正常加载配置文件
15. 停止原服务，在 "服务" 窗口，右击 Apache24 服务，选择停止
16. 卸载原服务，在原Apache目录，进入命令行，执行 `httpd.exe -k uninstall` 进行卸载
17. 右下角任务栏托盘，退出 ApacheMonitor
18. 关闭所有 原Apache 的目录和文件(包括: 服务，文件夹，文件)
19. 重命名 原Apache 目录为 Apache24-bak
20. 重命名 新Apache 目录为 Apache24
21. 双击启动 新Apache 目录下的 ApacheMonitor.exe
22. 进入 新Apache 目录 Apache24 的命令行，安装新版本的Apache `httpd.exe -k install`
23. 需要手动启动新服务，在 "服务" 窗口，右击 Apache24 服务，选择启动
24. 启动完成后，进行验证操作

- 升级后
  - 新Apache目录: `D:\Apache24`
  - 原Apache目录: `D:\Apache24-bak`


验证
---

1. 访问系统，检查是否正常显示、跳转

清理
---

1. 保证新的Apache版本工作正常后，删除 conf-bak, Apache24-bak 等备份文件
