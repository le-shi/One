CentOS系统内核的变动往往比较谨慎（用的都是老的），有时候安装比较潮流的软件时对内核版本的要求极高，所以我们需要升级内核！

> 升级需谨慎，莫要两行泪
## RHEL-7, SL-7 or CentOS-7

```bash
# 载入公钥，参考：http://elrepo.org/tiki/HomePage
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 升级安装 elrepo
yum install https://www.elrepo.org/elrepo-release-7.el7.elrepo.noarch.rpm
# 载入 elrepo-kernel 元数据
yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
# 安装在最新版本的内核 | ml为主线版本mainline，这个东西叫源代码标记=代号
yum --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml.x86_64 -y
# 删除旧版本内核工具包
yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 kernel-headers.x86_64 -y
# 安装新版本内核工具包
yum --disablerepo=\* --enablerepo=elrepo-kernel install kernel-ml-tools kernel-ml-devel kernel-ml-headers -y
# 查看内核插入顺序。默认新内核是从头插入，默认启动顺序也是从 0 开始
grep "^menuentry" /boot/grub2/grub.cfg | cut -d "'" -f2
# 查看当前实际启动顺序
grub2-editenv list
# 设置默认启动，也可以使用前面的序号进行操作
grub2-set-default 'CentOS Linux (5.15.0-1.el7.elrepo.x86_64) 7 (Core)'
# 重启前的检查
uname -a
# 最后重启检查
reboot
uname -a
```

## RHEL-8, CentOS-8 or Rocky 8

```bash
# 载入公钥，参考：http://elrepo.org/tiki/HomePage
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 升级安装 elrepo
yum install https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm
```