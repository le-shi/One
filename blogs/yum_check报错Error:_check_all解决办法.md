错误信息:

```
➜  ~  yum check
Loaded plugins: fastestmirror
glibc-2.12-1.107.el6_4.5.x86_64 is a duplicate with glibc-2.12-1.107.el6_4.4.x86_64
glibc-common-2.12-1.107.el6_4.5.x86_64 is a duplicate with glibc-common-2.12-1.107.el6_4.4.x86_64
glibc-devel-2.12-1.107.el6_4.5.x86_64 is a duplicate with glibc-devel-2.12-1.107.el6_4.4.x86_64
glibc-devel-2.12-1.107.el6_4.5.x86_64 has missing requires of glibc-headers = ('0', '2.12', '1.107.el6_4.5')
iputils-20071127-17.el6_4.2.x86_64 is a duplicate with iputils-20071127-17.el6_4.x86_64
nspr-4.9.5-2.el6_4.x86_64 is a duplicate with nspr-4.9.2-1.el6.x86_64
nss-3.14.3-4.el6_4.x86_64 is a duplicate with nss-3.14.0.0-12.el6.x86_64
nss-softokn-3.14.3-3.el6_4.x86_64 is a duplicate with nss-softokn-3.12.9-11.el6.x86_64
nss-util-3.14.3-3.el6_4.x86_64 is a duplicate with nss-util-3.14.0.0-2.el6.x86_64
tzdata-2013g-1.el6.noarch is a duplicate with tzdata-2013c-2.el6.noarch
2:xinetd-2.3.14-39.el6_4.x86_64 is a duplicate with 2:xinetd-2.3.14-38.el6.x86_64
Error: check all
```

原因:

引起上述错误的原因是升级软件包的过程中重新启动计算机(或崩溃或手动终止Ctrl+C)。导致安装了新的软件包, 但旧的软件包没有删除。


解决办法:


首先安装 yum 软件包清除工具

```bash
yum -y install yum-utils
```

继续处理未完成的安装:

```bash
yum-complete-transaction
```

如果上述没有解决问题，那么请使用yum-utils软件包中的软件包清除工具。

```bash
# 列出重复的包
package-cleanup --dupes

# 删除重复的包
rpm -e [duplicated packages]

# 如果遇到互相依赖的包，使用 --nodeps 参数，忽略依赖关系
rpm -e [duplicated packages] --nodeps
```

运行删除命令之前请一定做好备份工作。

