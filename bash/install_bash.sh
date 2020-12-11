#!/bin/bash
# https://www.gnu.org/software/bash/manual/html_node/Basic-Installation.html#Basic-Installation

cd /tmp
wget -N http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz
tar -zxf bash-5.0.tar.gz
cd bash-5.0/
./configure
make
make tests
make install
