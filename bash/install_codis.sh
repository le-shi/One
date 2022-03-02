#!/bin/bash
set -e
dirpath=/home/codis
profile=/etc/profile

insGo (){
  #下载go源码
  wget -N https://dl.google.com/go/go1.11.1.linux-amd64.tar.gz 2>/dev/null
  [[ -d go ]] || tar -zxf go1.11.1.linux-amd64.tar.gz
  cd go
  export gopath=$(pwd)
  grep '#go path' ${profile} > /dev/null|| echo '#go path' >> ${profile}
  grep "export GOPATH=${gopath}"  ${profile} > /dev/null|| echo "export GOPATH=${gopath}" >> ${profile}
  grep 'export PATH=$PATH:$GOPATH/bin' ${profile} > /dev/null|| echo 'export PATH=$PATH:$GOPATH/bin' >> ${profile}
  source ${profile}
  go version
  echo -e "...\ngo install successful."
}
insCodis (){
  #创建codis目录
  mkdir -pv ${gopath}/src/github.com/CodisLabs
  #下载codis源码
  cd $_ && git clone https://github.com/CodisLabs/codis.git -b release3.2
  #编译codis源码
  cd ${gopath}/src/github.com/CodisLabs/codis
  #直接make编译
  make
}
insGo
insCodis
