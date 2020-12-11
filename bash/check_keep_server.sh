#!/bin/bash
#keepalived_app.sh
warning_timeout=300
interval=5
app_id=uc
http_port=8083
httpurl=http://192.168.9.209:${http_port}/${app_id}/
http_request_code=302

funtion_echo (){
    echo "[`date +%Y-%m-%d\ %H:%M:%S`] $*"
}

funtion_a (){
  keepalived_process=$(ps -ef| grep keepalived | grep -v grep | wc -l)
  if [ ${keepalived_process} -ge 3 ]; then
    funtion_echo "keepalived is alived. do nothing."
  else
    app_process=$(ps -ef| grep java | grep ${app_id}/bin | wc -l)
    if [ ${app_process} -lt 1 ]; then
      funtion_echo "pid of ${app_id} not exists. launch ${app_id}."
      /home/tomcat/${app_id}/bin/startup.sh > /dev/null 2>&1
      timeout=0
    else
      var=$(curl -I -m 1 -o /dev/null -s -w %{http_code} ${httpurl})
      if [ ${var} == ${http_request_code} ]; then
          funtion_echo "service status of ${app_id} is UP, launch keepalived."
        sudo service keepalived start > /dev/null 2>&1
      else
        timeout=$[ $interval + $timeout ]
          funtion_echo "service status of ${app_id} is DOWN, Waiting to become UP has been used for ${timeout}seconds."
        if [ $timeout -ge ${warning_timeout} ]; then
          funtion_echo "service status of ${app_id} is DOWN for more than ${warning_timeout} seconds. sending warning SMS."
        fi
      fi
    fi
  fi
  sleep $interval
}

while true;
do
 funtion_a
done

