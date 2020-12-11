#!/usr/bin/env bash
# 功能：
# 隐藏SSH版本信息
# 升级到高版本可以避免当前版本(OpenSSH_7.4p1，2019年10月30日)的漏洞

set -xe

VERSION=openssh-8.1p1
PATHTO=$(pwd)

# 清理源代码
clear(){
    cd ${PATHTO}
    rm -rf ${VERSION} ${VERSION}.tar.gz
}

# upgrade Centos7
upgradeCentos7(){
    # 查看当前版本
    # ssh -V
    # sshd -V
    # 先决条件
    # zlib >1.2.x
    # libcrypto(LibreSSL/OpenSSL)
    # Openssl 1.0.x >= 1.0.1 or 1.1.0 >= 1.1.0g or any 1.1.1
    yum -y install wget make gcc zlib-devel openssl-devel
    # 下载新版本
    wget -t 3 https://openbsd.hk/pub/OpenBSD/OpenSSH/portable/${VERSION}.tar.gz
    tar -zxf ${VERSION}.tar.gz
    cd ${VERSION}
    ./configure --prefix=/usr --sysconfdir=/etc/ssh
    sed -i 's/".*"/"Unix"/g' version.h
    make
    # 备份旧配置文件
    mv /etc/ssh/ssh_config{,.bak}
    mv /etc/ssh/sshd_config{,.bak}
    mv /etc/ssh/moduli{,.bak}
    chmod 600 /etc/ssh/{ssh_host_rsa_key,ssh_host_ecdsa_key,ssh_host_ed25519_key}
    cp contrib/redhat/sshd.init /etc/init.d/sshd
    make install
    # 支持root远程
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    mv /usr/lib/systemd/system/sshd.service{,.bak}
    systemctl daemon-reload
    systemctl restart sshd
    clear
}

upgradeCentos7
