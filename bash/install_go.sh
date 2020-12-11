#!/bin/bash

proFile=/etc/profile
goPath=/usr/local
goVersion=1.13.1
goDownloadPath=https://dl.google.com/go/go${goVersion}.linux-amd64.tar.gz


centosGoInstall (){
  #安装go
  wget -N ${goDownloadPath} 2> /dev/null
  [[ -d ${goPath}/go ]] || sudo tar -C ${goPath} -zxf go${goVersion}.linux-amd64.tar.gz
  grep '#go path' ${proFile} > /dev/null|| echo '#go path' >> ${proFile}
  grep "export GOPATH=${goPath}/go"  ${proFile} > /dev/null|| echo "export GOPATH=${goPath}/go" >> ${proFile}
  grep 'export PATH=$PATH:$GOPATH/bin' ${proFile} > /dev/null|| echo 'export PATH=$PATH:$GOPATH/bin' >> ${proFile}
  source ${proFile}
  go version
  echo -e "...\ngo install successful."
}

centosGoInstall
