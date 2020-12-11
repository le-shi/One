#!/bin/bash
py_version=3.7.0

yum -y install libevent memcached libmemcached libmemcached-devel gcc gcc-c++ nss zlib zlib-devel openssl openssl-devel python-devel readline-static openssl-static bzip2-devel ncurses-devel sqlite-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel
#升级Python
wget https://www.python.org/ftp/python/${py_version}/Python-${py_version}.tgz
tar -zxvf Python-${py_version}.tgz
cd Python-${py_version} && \
./configure --enable-optimizations
make -j $(grep -c "core" /proc/cpuinfo) && make install
# 不对原来的python环境做修改
# mv /usr/bin/python /usr/bin/python.old
# ln -s /usr/local/bin/python3.7 /usr/bin/python
#Install pip
curl https://bootstrap.pypa.io/get-pip.py | python
pip install --upgrade pip