#!/bin/bash
set -e

echo -e "\e[033mThe script is exist BUG.\e[0m  \e[031mDon't perform\e[0m"
exit 1
cmake_install (){
make -j $(nproc)
make install
echo -n "path: $(pwd)"
}

check_system (){
  local bash_file=/tmp/check_system_version.sh
  wget -qO ${bash_file} https://github.com/mainiubaba/One/raw/master/bash/check_system_version.sh
  source ${bash_file}
}

libModSecurity_3_Centos7mini (){
  yum install gcc-c++ flex bison yajl yajl-devel curl-devel curl GeoIP-devel doxygen zlib-devel
  cd /opt/
  git clone https://github.com/SpiderLabs/ModSecurity
  cd ModSecurity
  git checkout -b v3/master origin/v3/master
  sh build.sh
  git submodule init
  git submodule update
  ./configure
  cmake_install
}

libModSecurity_3_Centos6 (){
  yum -y install libtool*
  cd /opt/
  git clone https://github.com/SpiderLabs/ModSecurity
  cd ModSecurity
  git checkout -b v3/master origin/v3/master
  sh build.sh
  git submodule init
  git submodule update
  ./configure
  cmake_install
}

connector_nginx_Centos7mini (){
  # ensure env vars are set
  export MODSECURITY_INC="/opt/ModSecurity/headers/"
  export MODSECURITY_LIB="/opt/ModSecurity/src/.libs/"
  cd /opt/
  git clone https://github.com/SpiderLabs/ModSecurity-nginx
  cp -f /usr/sbin/nginx /usr/sbin/nginx_original_bkp
}

connector_nginx_Centos6 (){
  cd /opt/
  git clone https://github.com/SpiderLabs/ModSecurity-nginx
  wget -qO ngx_openresty-1.9.7.2.tar.gz https://openresty.org/download/ngx_openresty-1.9.7.2.tar.gz
  tar -xzf ngx_openresty-1.9.7.2.tar.gz
  cd ngx_openresty-1.9.7.2
  ./configure --add-module=/opt/ModSecurity-nginx  
}

install_modsecurity (){
  check_system
  if [[ ${system_version} == "CentOS" ]];then
  [[ ${system_version_num} -eq 7 ]] && libModSecurity_3_Centos7mini
  [[ ${system_version_num} -eq 6 ]] && libModSecurity_3_Centos6
  else echo "system_version is ${system_version}, choose CentOS"; exit 1;fi
  cmake_install
}



