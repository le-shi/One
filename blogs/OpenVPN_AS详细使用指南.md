
文章复制于: [OpenVPN AS详细使用指南](https://www.daehub.com/archives/5894.html)
OpenVPN官网: <https://openvpn.net>

VPN 技术成熟已久，可以提供更加安全的互联网访问。当然，国内用户也可以通过该技术轻松突破GFW的封锁，达到科学上网的目的。

OpenVPN不仅是令人信赖的VPN服务提供商，同时也是著名的开源VPN软件开发商。其OpenVPN软件因其出色的加密技术一直被社区所推崇。为了方便使用，开发商开发了OpenVPN Access Server（OpenVPN AS）作为OpenVPN软件的升级版本，解决了原软件配置复杂，难于推广的问题。

本文将详细讲解如何在Linux系统安装OpenVPN AS，并演示如何使用OpenVPN。OpenVPN软件分为服务端软件和客户端，服务端软件就是OpenVPN AS，客户端软件为OpenVPN。

 **1. Linux系统安装OpenVPN Access Server**

我们将演示两种常用的Linux系统发行版体系，即 CentOS/RHEL 和 Ubuntu 的安装。当然OpenVPN还支持其他类型的Linux发行版，需要的话可以查看其官方手册。

阿里云操作系统: Alibaba Cloud Linux (Aliyun Linux) release 2.1903 LTS (Hunting Beagle)，将按照 CentOS7 系统的安装方式进行

在安装OpenVPN AS之前，需要在系统安装一些工具：

```shell
# yum install net-tools wget             //CentOS/RHEL
$ sudo apt-get install net-tools wget    //Ubuntu
```

由于OpenVPN要求服务端和客户端要严格同步，否则会出现认证失败的问题，所以我们还需要在服务器上安装 chrony 软件包：

```
# yum install chrony             //CentOS/RHEL
$ sudo apt-get install chrony    //Ubuntu
```

安装完成后，就可以从OpenVPN的官方网站下载服务器软件包了：

```
# wget https://openvpn.net/downloads/openvpn-as-latest-CentOS7.x86_64.rpm     //CentOS/RHEL
$ wget https://openvpn.net/downloads/openvpn-as-latest-ubuntu18.amd_64.deb    //Ubuntu
```

如果使用了其他版本的系统，可自行下载对应的软件包。下载成功后，就可以使用如下命令安装OpenVPN AS：

```
# rpm -Uvh openvpn-as-latest-CentOS7.x86_64.rpm         //CentOS/RHEL
$ sudo dpkg -i openvpn-as-latest-ubuntu18.amd_64.deb    //Ubuntu
```

![img](https://www.daehub.com/wp-content/uploads/2019/04/install-latest-openvpn-as-in-linux.jpg)

安装完成后，OpenVPN AS会自动启动，如果担心启动不成功，可以使用如下命令重新启动服务端：

```
# systemctl restart openvpnas
```

服务端启动成功后，我们就可以通过GUI界面来管理和使用OpenVPN了，不过在使用GUI界面前，我们需要设置OpenVPN管理账户的密码：
(因为管理界面默认的管理员登录用户就是操作系统的openvpn用户，所以密码要设置的复杂一些)

```
# passwd openvpn
```

密码设置完成后，就可以通过浏览器访问如下URL来打开GUI管理页面：

```
https://IP_OF_AS_SERVER:943/admin
```

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-as-admin-portal.jpg)

Username填入”openvpn”，Password填入之前设置用openvpn用户密码，然后点击Sign In登录，就会见到OpenVPN用户授权许可页面：
(点完登录，你可能会发现页面加载很慢，通过浏览器F12打开开发者工具，可以看到有两个 https://fonts.googleapis.com/css 的请求，国内是不能访问这个地址的所以需要绕过一下。解决方法：现在浏览器安装一个 AdBlock 扩展程序，创建自定义拦截规则-拦截更多广告-根据URL拦截广告，在url的输入框内填写 fonts.googleapis.com/css，应用的域名填写vpn的地址，点击"拦截它"。 现在刷新vpn的页面，发现页面可以很快的加载了，然后通过F12可以看到google的那两个请求已经被拦截了，PS: 去了不影响正常功能，具体的作用待查询 /usr/local/openvpn_as/lib/python2.7/site-packages/docutils/utils/math/math2html.py)

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-as-tos-page.jpg)

这些内容想必大家也不关心，反正只有Agree按钮可以点，点击同意继续，就会进入AS的管理页面：

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-as-admin-page.jpg)

-- 自定义配置
配置-网络设置，把 "VPN Server"-"Hostname or IP Address:" 换成域名，点击页面最下方的保存按钮，同时更新运行的服务。这个会影响最终生成的 client.ovpn 文件中服务端的地址
配置-VPN设置，在 "Routing"，指定可访问的内网地址，点击页面最下方的保存按钮，同时更新运行的服务。这个影响客户端连上VPN后，可以访问的网段
配置-客户端设置，在 "Customize Client Web Server UI"，关闭 "user-locked profile" 选项，点击页面最下方的保存按钮，同时更新运行的服务。

说是管理页面，其实AS的配置已经做的非常完善了，我们基本不需要修改其中的配置。修改的话也比较简单，基本都是些开关选项，需要设置数据的内容较少。示例起见，本次就保持默认配置不做修改。从状态页可以看出，此次安装的AS服务器含有两台设备的授权，同和客户端使用tcp/443和udp/1194端口通信。

如果系统启用了防火墙，会出现管理页面不能访问等问题，所以要配置防火墙放行tcp/443、tcp/943和udp/1194端口。

 **2. Windows安装和配置OpenVPN客户端

**

我们需要访问AS服务器的客户端页面来下载客户端和客户配置文件，通过浏览器访问如下URL：

```
https://IP_OF_AS_SERVER:943/
```

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-as-user-ui.jpg)

输入用户名和密码后，点击”Login”按钮：

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-as-user-manage-page.jpg)

可以看到，可能通过该页面下载不同系统的客户端，并且可以下载客户端配置文件。点击链接”Yourself (user-locked profile)”会下载一个名为”client.ovpn”的文件，这是客户端需要使用的配置文件。同样，也可以点击客户端的链接下载对应平台的客户端，我们将使用Windows平台的客户端。

Windows平台的客户端软件是一个安装程序，双击打开并安装即可。由于比较简单，这里不再演示。

启动客户端后，会在系统任务栏生成一个OpenVPN软件的图标：

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-client-icon.jpg)

此时显示客户端为”disconnected”，表示并未与AS服务器连接。现在就配置AS服务器。在客户端图标上单击鼠标右键，会弹出功能菜单:

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-client-menu.jpg)

点击”Import>”菜单项中的”From local file…”菜单，就会弹出对话框，请求选择配置文件，这时选择之前从AS端下载的”client.ovpn”文件导入，就会把之前创建的AS服务器导入客户端，以便客户端连接使用。

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-client-connect-to-as-server.jpg)

AS服务器导入成功后，客户端会显示该服务器，点击该服务器的菜单基，然后点击”Connect as openvpn”，就会弹出对话框要求输入密码：

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-client-connect-verify.jpg)

正确输入密码后，点击”Connect”按钮就可让客户端连接到AS服务器了。

连接成功后，客户端的图标会变成绿色对号，表示客户端可用了。最后还需要设置一下代理选项。点击功能菜单的”Options>”->”HTTP Proxy”->”Set”菜单，就会弹出IE代理的设置项，这是浏览器同OpenVPN通信的配置内容，如果不明晰的话，按推荐输入”auto”即可，这样在浏览器中设置”自动选择代理”就可以同客户端通信。

![img](https://www.daehub.com/wp-content/uploads/2019/04/openvpn-client-set-proxy-mode.jpg)

最后，当然是使用浏览器访问一下被墙的网站，看OpenVPN是否工作正常。当然访问AS的管理页面也可以看到相应的信息。

至此，一个OpenVPN代理系统就全部部署完成，是不是很简单呢。

总体来说，OpenVPN使用效果不错，安装配置也简单，非适合在VPS上部署用于科学上网。如果自己使用的话也不需购买许可，推荐大家尝试。

PS：由于官方网站下载安装包经常不成功，特提供本地下载，方便大家将安装包上传到VPS后安装使用。

- [Ubuntu 18](https://www.daehub.com/download/Tools/openvpn-as-2.7.4-Ubuntu18.amd_64.deb)
- [Debian 9](https://www.daehub.com/download/Tools/openvpn-as-2.7.4-Debian9.amd_64.deb)
- [RHEL/CentOS 7](https://www.daehub.com/download/Tools/openvpn-as-2.7.4-CentOS7.x86_64.rpm)

PS2: 防止上面提供的包不能正常下载，再提供一些下载地址，方便大家下载使用。

- Github的地址
- [Ubuntu 18](https://github.com/le-shi/packages/raw/master/openvpnas/openvpn-as-2.7.4-Ubuntu18.amd_64.deb)
- [Debian 9](https://github.com/le-shi/packages/raw/master/openvpnas/openvpn-as-2.7.4-Debian9.amd_64.deb)
- [RHEL/CentOS 7](https://github.com/le-shi/packages/raw/master/openvpnas/openvpn-as-2.7.4-CentOS7.x86_64.rpm)

- Gitee的地址，文件超过1M，登录后可以快速下载
- [Ubuntu 18](https://gitee.com/Roles_le/packages/raw/master/openvpnas/openvpn-as-2.7.4-Ubuntu18.amd_64.deb)
- [Debian 9](https://gitee.com/Roles_le/packages/raw/master/openvpnas/openvpn-as-2.7.4-Debian9.amd_64.deb)
- [RHEL/CentOS 7](https://gitee.com/Roles_le/packages/raw/master/openvpnas/openvpn-as-2.7.4-CentOS7.x86_64.rpm)

- Codeberg的地址
- [Ubuntu 18](https://codeberg.org/le/packages/raw/branch/master/openvpnas/openvpn-as-2.7.4-Ubuntu18.amd_64.deb)
- [Debian 9](https://codeberg.org/le/packages/raw/branch/master/openvpnas/openvpn-as-2.7.4-Debian9.amd_64.deb)
- [RHEL/CentOS 7](https://codeberg.org/le/packages/raw/branch/master/openvpnas/openvpn-as-2.7.4-Ubuntu18.amd_64.deb)



---
关于OpenVPN AS两个设备的限制 --没成功

1. 安装工具 https://github.com/rocky/python-uncompyle6
2. 解压 /usr/lib/python2.7/site-packages/pyovpn-2.0-py2.7.egg
3. 重命名 pyovpn/lic/uprop.pyo -> pyovpn/lic/uprop2.pyo
4. 新建 uprop.py ，写入文本

```python
import uprop2
old_figure = None

def new_figure(self, licdict):
    ret = old_figure(self, licdict)
    ret['concurrent_connections'] = 1024
    return ret

for x in dir(uprop2):
    if x[:2] == '__':
        continue
    if x == 'UsageProperties':
        exec 'old_figure = uprop2.UsageProperties.figure'
        exec 'uprop2.UsageProperties.figure = new_figure'
    exec '%s = uprop2.%s' % (x, x)
```

5. 编译成字节码 python -O -m compileall uprop.py
6. 重新zip打包，只要文件名前缀相同就能运行
7. 上传到服务器对应路径,直接将修改后的目录 zip 后覆盖回该 egg 的原本路径，重新初始化 OAS 即可生效
8. 重新初始化操作 /usr/local/openvpn_as/bin/ovpn-init
   1. 输入DELETE
   2. 输入yes同意协议
   3. 一路回车
9. 登录查看 `License Status`