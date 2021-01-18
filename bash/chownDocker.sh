#!/bin/bash
#chkconfig: 2345 10 90
#description: check docker server status, Authorize centos.
# Use:
# 1. copy script file to /etc/rc.d/init.d/
# 2. Added executable privileges to scripts: chmod +x /etc/rc.d/init.d/chownDocker.sh
# 3. Increase to boot start item: chkconfig --add chownDocker.sh && chkconfig chownDocker.sh on
# 4. 'reboot' is test.
flag=0
INIT_PATH=/etc/rc.d/init.d

# check user and wget and script file.
[[ ${USER} == 'root' ]] || ( echo "Hint: Use root execute." && exit 0 )
( type wget  >/dev/null 2>&1) || yum -y install wget >/dev/null 2>&1
[[ -f ${INIT_PATH}/chownDocker.sh ]] || ( flag=1;wget -q 192.168.13.99:8000/chownDocker.sh -O ${INIT_PATH}/chownDocker.sh && chmod +x ${INIT_PATH}/chownDocker.sh )
if [[ ${flag} == 1 ]];then
   exec ${INIT_PATH}/chownDocker.sh
fi


SCRIPT_NAME=${0}
[[ ${SCRIPT_NAME} == "bash" ]] && SCRIPT_NAME=chownDocker.sh
if [[ ! -x ${SCRIPT_NAME} ]];then
   chmod +x ${INIT_PATH}/${SCRIPT_NAME}
fi

SCRIPT_NAME=$(basename ${SCRIPT_NAME})
CHK_NUM=$(chkconfig ${SCRIPT_NAME} --list 2>/dev/null | wc -l)
if [[ ${CHK_NUM} == 1 ]];then
   chkconfig ${SCRIPT_NAME} on
else
   chkconfig --add ${SCRIPT_NAME}
   chkconfig ${SCRIPT_NAME} on
fi

dockerStatus (){
  STATUS=$(systemctl status docker | grep "Active" | grep -wc "running")
  return ${STATUS}
}

chownSock (){
  CHOWN_USER=centos
  SOCK_FILE=/var/run/docker.sock
  SOCK_STATUS=$(ls -l /var/run/docker.sock | grep -c "${CHOWN_USER}")
  if [[ ${SOCK_STATUS} != 1 ]];then
    chown ${CHOWN_USER}.${CHOWN_USER} ${SOCK_FILE}
  fi
  # # order start
  # docker stop $(docker ps -q)
  # docker rm -f $(docker ps -qa)
  # sleep 3
  # cd /home/centos
  # /usr/local/bin/docker-compose up -d  # base server
  # /usr/local/bin/docker-compose -f docker-compose-prometheus.yaml up -d  # prometheus exporter
  # /usr/local/bin/docker-compose -f mainHost/prometheus/docker-compose.yaml up -d  # prometheus server
  # /usr/local/bin/docker-compose -f mainHost/filebeat/docker-compose.yaml up -d  # filebeat
  # # Software factories produce services
  # cd /opt
  # for out in $(ls *.yaml);then
  # do
  #   /usr/local/bin/docker-compose -f ${out} up -d
  #   sleep 5
  # done
}

while true;
do
  if dockerStatus;then
    sleep 5
  else
    chownSock
    exit 0
  fi
done
