#!/bin/bash
set -e

logstash_user=elk
auseradd (){
  useradd ${logstash_user}
  echo "123qwe!@#QWE" | passwd ${logstash_user} --stdin
  grep "${logstash_user} ALL=(ALL) NOPASSWD: ALL" /etc/sudoers || echo "${logstash_user} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  grep "Defaults: ${logstash_user}  !requiretty" /etc/sudoers || echo "Defaults: ${logstash_user}  !requiretty" >> /etc/sudoers
}

install_logstash (){
  if [ ! -d /home/${logstash_user}/logstash-6.3.0 ]; then
    wget -q -O /tmp/logstash-6.3.0.tar.gz https://artifacts.elastic.co/downloads/logstash/logstash-6.3.0.tar.gz
    tar -zxf /tmp/logstash-6.3.0.tar.gz -C /home/${logstash_user}
    chown -R ${logstash_user}.${logstash_user} /home/${logstash_user}
  else
    echo "Directory /home/${logstash_user}/logstash-6.3.0 exists"
  fi
}

if [ 0 -eq $(grep ${logstash_user} /etc/passwd | wc -l ) ]; then
  auseradd
  echo "create logstash_user ${logstash_user}"
else 
  echo "logstash_user ${logstash_user} exists"
fi
install_logstash
