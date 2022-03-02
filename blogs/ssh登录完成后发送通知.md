# ssh登录服务器自动触发脚本进行微信通知

1. 开始之前要了解Linux下配置文件的加载顺序

    在登录Linux系统并启动一个 bash shell 时，默认情况下 bash 会在若干个文件中查找环境变量的设置，这些文件可统称为系统环境文件，bash 检查的环境变量文件的情况取决于系统运行 Shell 的方式，系统运行 Shell 的方式有 3 种。

    （1）通过系统用户登录后默认运行的 Shell

    （2）非登录交互式运行 Shell

    （3）执行脚本运行非交互是 Shell

    1、登录shell方式进入Linux

    账号和密码——>/etc/profile（全局文件G1）——>/etc/profile.d/（全局脚本目录F1）——> ~/.bash_profile（用户文件U1）——> ~/.bashrc（用户文件U2）——>/etc/bashrc（全局文件G2）

    当用户登录 Linux 系统时，Shell 会作为登录 Shell 启动，此时的登录 Shell 加载环境变量的顺序如上图。

    用户登录系统后首先会加载 /etc/profile 全局环境变量文件，这是 Linux 系统上默认的 Shell 主环境变量文件，系统上每个用户登录都会加载这个文件。

    当加载完 /etc/profile 文件后，才会执行 /etc/profile.d/目录下的脚本文件，这个目录下的脚本文件由很多，例如：系统的字符集设置（/etc/sysconfig/i18n）等，以便用户登录后即可运行脚本

    之后开始运行 ~/.bash_profile（用户环境变量文件），在这个文件中，又会去找  ~/.bashrc（用户环境变量文件），如果有，则执行，如果没有，则不执行，在  ~/.bashrc文件中又会去找/etc/bashrc（全局环境变量文件），如果有，则执行，如果没有，则不执行。

    2、非登录Shell方式进入Linux

    不需要输入密码的登录及远程 SSH 连接——>  ~/.bashrc（用户文件U2）——>/etc/bashrc（全局文件G2）

    如果用户的Shell 不是登录时启动的（比如手动敲下 bash 时启动或者其他不需要输入密码的登录及远程 SSH 连接情况）那么这种非登录 Shell 只会加载  ~/.bashrc（用户环境变量文件），并会去找 /etc/bashrc（全局环境变量文件），因此如果希望在非登录 Shell 下也可读到设置的环境变量等内容，就需要将变量设定写入  ~/.bashrc 或者 /etc/bashrc，而不是  ~/.bash_profile或/etc/profile。

    1、/etc/profile：系统配置文件，用户登录时读取一次
    2、/etc/bash.bashrc：（Ubuntu）系统配置文件，用户登录时读取一次，每次打开一个新终端会话时读取一次。
    /etc/bashrc： （Centos）系统配置文件，用户登录时读取一次，每次打开一个新终端会话时读取一次。
    3、~/.profile（~/.bash_profile、~/.bash_login）：用户配置文件，用户登录时读取一次
    4、~/.bashrc：用户配置文件，用户登录时读取一次，每次打开一个新终端会话时读取一次

    对于 ~/.bash_profile、~/.bash_login、~/.profile，如果终端绑定的是 bash，则按照我书写的顺序进行读取（如果存在，就不继续读取）

    1、系统配置文件作用于全局，而用户配置文件仅针对当前登录的用户
    2、先读取系统配置文件，再读取用户配置文件，用户配置文件的变量和表达式等都继承自系统配置文件

2. 添加脚本，在ssh登录成功时，会自动执行

    - 放到 `/etc/profile.d/`: [获取登录信息，组织语言](../bash/login_ssh_notice_wechat.sh)
    - 放到 `/opt/`: [请求企业微信接口](../bash/notice_wechat.sh)
      - 使用之前确保接口发送正常

3. 新打开SSH窗口，查看微信接受情况
4. 其他的感想
   1. 上面提到的这种方法对于企业微信的应用安全性没有保障，因为每个脚本中都包含敏感信息，每个机器都有这个脚本
   2. 不限于这一种方式进行通知，也可以使用WebHook，PrometheusAlert(告警全家桶，敏感信息只存一份)