#!/bin/bash
set -e

jdk_install_path=/usr/java/
yum -y install wget

fun_jdk8_install (){
  jdk_version=181
  jdk_downlaod_url="http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u${jdk_version}-linux-x64.tar.gz?AuthParam=1535614924_20b819890973b15ddf6969280d5bd74b"
  #下载安装包
  if [ -f /tmp/jdk-8u${jdk_version}-linux-x64.tar.gz ];then :;else wget -O /tmp/jdk-8u${jdk_version}-linux-x64.tar.gz ${jdk_downlaod_url};fi
  #检查安装目录
  mkdir -pv ${jdk_install_path}
  #执行安装
  tar -zxf /tmp/jdk-${jdk_version}-linux-x64.tar.gz -C ${jdk_install_path}
  #增加环境变量
  grep "export JAVA_HOME=/usr/java/jdk1.8.0_${jdk_version}" /etc/profile || echo "export JAVA_HOME=/usr/java/jdk1.8.0_${jdk_version}" >> /etc/profile
  grep 'export JRE_HOME=$JAVA_HOME/jre' /etc/profile ||  echo 'export JRE_HOME=$JAVA_HOME/jre'  >> /etc/profile
  grep 'export JAVA_BIN=$PATH:$JAVA_HOME/bin' /etc/profile || echo 'export JAVA_BIN=$PATH:$JAVA_HOME/bin' >> /etc/profile
  grep 'export PATH=$JAVA_HOME/bin:$PATH' /etc/profile || echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
  grep 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib:$JAVA_HOME/lib' /etc/profile || echo 'export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JAVA_HOME/jre/lib:$JAVA_HOME/lib' >> /etc/profile
  grep 'export JAVA_HOME JAVA_BIN PATH CLASSPATH' /etc/profile || echo 'export JAVA_HOME JAVA_BIN PATH CLASSPATH' >> /etc/profile
  #保存环境变量
  source /etc/profile
  echo "Install Java SE Version : ${jdk_version}"
  javah -version
}

fun_jdk8_install
