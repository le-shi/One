
> 升级需谨慎，莫要两行泪
# Centos 7
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install kernel-lt kernel-lt-devel -y
grub2-set-default 0
uname -a
reboot
uname -a