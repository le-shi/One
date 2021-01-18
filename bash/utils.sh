#!/bin/bash
#all server funtion
#Use:. /path/to/utils.sh

countCpu=$(grep -c "processor" /proc/cpuinfo)
proFile=/etc/profile
goRoot=/usr/local
goPath=/tmp
goVersion=1.11.1
goDownloadPath=https://dl.google.com/go/go${goVersion}.linux-amd64.tar.gz
glicVersion=2.16.0


#System
getSystemName (){
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        system_version_num=$(uname -r | awk -F "el" '{print $2}' |  awk -F '.' '{print $1}')
        system_version='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release; then
        system_version='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release; then
        system_version='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release; then
        system_version='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release; then
        system_version='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release; then
        system_version='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release; then
        system_version='Raspbian'
        PM='apt'
    else
        system_version='unknow'
    fi
#echo  "System_version : ${system_version}"
#echo  "System_version_num : ${system_version_num}"
}

judgeDirectory (){
  dName=${1}
  [[ -d ${dName} ]] || mkdir -pv ${dName}
}

judgeCommandRename (){
  # 判断rename命令的版本: C & Perl
  local rename_version=$(rename --version)
  if [[ $(echo ${rename_version} | grep 'util-linux') ]];then
      rename -v ${new_text} ${old_text} ${new_text}.file1 ${new_text}.file2
  else
      rename -v "s/${new_text}/${old_text}/g" ${new_text}.file1 ${new_text}.file2
  fi
}

checkServer (){
 if type "${1}" > /dev/null 2>&1;then :;else "${2}";fi
 #Use: checkServer go centosInstallGo
}

installEcho (){
  echo "###Starting Install...############################################### [$*]"
}




#Packages server
centos7YumApache (){
  #centos 7
  yum -y install wget tree vim lrzsz mlocate gcc gcc-c++ make cmake zlib zlib-devel openssl openssl-devel nss telnet nmap iotop strace net-tools lsof git rsync gdb bzip2 expat-devel libtool libxml2-devel libcurl-devel
}



#Path
centosInstallGo (){
  installEcho Go
  cd ${goRoot}
  wget -N ${goDownloadPath} 2> /dev/null
  [[ -d ${goRoot}/go ]] || sudo tar -C ${goRoot} -zxf go${goVersion}.linux-amd64.tar.gz
  grep '#go path' ${proFile} > /dev/null|| echo '#go path' >> ${proFile}
  grep "export GOROOT=${goRoot}/go"  ${proFile} > /dev/null|| echo "export GOROOT=${goRoot}/go" >> ${proFile}
  grep "export GOPATH=${goPath}/go"  ${proFile} > /dev/null|| echo "export GOPATH=${goPath}/go" >> ${proFile}
  grep 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' ${proFile} > /dev/null|| echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> ${proFile}
  source ${proFile}
  go version
  echo -e "...\ngo install successful."
}

centosinstallGlibc (){
  glibcpath=/tmp/glibc
  judgeDirectory ${glibcpath}
  cd ${glibcpath}
  wget -N http://ftp.gnu.org/gnu/glibc/glibc-${glicVersion}.tar.xz 2>/dev/null
  tar -Jxf glibc-${glicVersion}.tar.xz
  mkdir -p glibc-${glicVersion}/build
  cd glibc-${glicVersion}/build
  ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
  make -j ${countCpu}
  make install
  ldd -version
}
