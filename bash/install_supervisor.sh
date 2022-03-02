#!/bin/bash
set -e

funtion_centos6 (){
##Centos 6
yum -y install libevent memcached libmemcached libmemcached-devel gcc gcc-c++ nss zlib zlib-devel openssl openssl-devel python-devel wget --skip-broken
#升级Python
wget -P /tmp https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tgz
tar -zxvf  /tmp/Python-2.7.11.tgz -C  /tmp/
cd  /tmp/Python-2.7.11 && ./configure
make -j $(nproc) && make install
mv -f /usr/bin/python /usr/bin/python2.6_bak
ln -s /usr/local/bin/python2.7 /usr/bin/python
#Install pip
curl https://bootstrap.pypa.io/get-pip.py | python
pip install --upgrade pip
#安装supervisor
pip install supervisor
dir=`find / -name echo_supervisord_conf`
$dir > /etc/supervisord.conf
echo -n "$(python -V)"
echo "$(pip -V | awk '{print $1,$2}')"
echo "Supervisor $(supervisord -v)"
pwd
}

funtion_censot7 (){
##Centos 7
yum -y install libevent memcached libmemcached libmemcached-devel gcc gcc-c++ nss zlib zlib-devel openssl openssl-devel python-devel wget
#Install pip
curl https://bootstrap.pypa.io/get-pip.py | python
pip install --upgrade pip
#安装supervisor
pip install supervisor
dir=`find / -name echo_supervisord_conf`
$dir > /etc/supervisord.conf
wget -q -O /usr/lib/systemd/system/supervisord.service https://raw.githubusercontent.com/mainiubaba/ansible_plus/master/roles/supervisor/templates/supervisord_systemctl.j2
echo -n "$(python -V)"
echo "$(pip -V | awk '{print $1,$2}')"
echo "Supervisor $(supervisord -v)"
pwd
}

fun_init (){
  supervisord_conf=/etc/supervisord.conf
  inet_num=$(grep -n "\[inet_http_server\]" /etc/supervisord.conf | awk -F ":" '{print $1}')
  grep "^\[inet_http_server\]" ${supervisord_conf} || sed -i 's/;\[inet_http_server\]/\[inet_http_server\]/g' ${supervisord_conf}
  grep "^password" ${supervisord_conf} || sed -i "${inet_num}a\password=1234567" ${supervisord_conf}
  grep "^username" ${supervisord_conf} || sed -i "${inet_num}a\username=admin" ${supervisord_conf}
  grep "^port=127.0.0.1:9001" ${supervisord_conf} || sed -i "${inet_num}a\port=0.0.0.0:9901" ${supervisord_conf}
  grep "^user" ${supervisord_conf} || sed -i "s/;user=chrism/user=${running_user}/g" ${supervisord_conf}
  grep "^\[include\]" ${supervisord_conf} || sed -i 's/;\[include\]/\[include\]/g' ${supervisord_conf}
  grep "^files" ${supervisord_conf} || sed -i 's/\;files \= relative\/directory\/\*.ini/files \= \/etc\/supervisor\/conf.d\/\*.ini/g' ${supervisord_conf}
  if [ ! -d /etc/supervisor/conf.d ];then mkdir -pv /etc/supervisor/conf.d/;else :;fi
}

Get_System_Name (){
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
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
}

Get_System_Name #system_version
system_version_num=$(uname -r | awk -F "el" '{print $2}' |  awk -F '.' '{print $1}')
running_user=elk
case ${system_version} in
  CentOS)
    case ${system_version_num} in
      7)
      funtion_censot7
      ;;
      6)
      funtion_centos6
      ;;
      *)
      echo "check system in [ CentOS7 | CentOS6 ]";;
    esac
    fun_init;;
  *)
  echo "you system version is ${system_version}, check system in [ CentOS ]";;
esac
