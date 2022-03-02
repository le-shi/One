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
DOCKER_COMPOSE=$(whereis docker-compose | awk '{print $2}')

# check user and wget and script file.
[[ ${USER} == 'root' ]] || ( echo "Hint: Use root execute." && exit 0 )
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
  # order start
  docker stop $(docker ps -q)
  docker rm -f $(docker ps -qa)
  sleep 3
  # 冗余作用
  chmod 666 /var/run/docker.sock
  cd /home/
  ${DOCKER_COMPOSE} up -d  # base server
}

# debug
set -x
while true;
do
  if dockerStatus;then
    sleep 5
  else
    chownSock
    exit 0
  fi
done >> /var/log/chownDocker.log 2>&1
