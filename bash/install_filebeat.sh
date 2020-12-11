#!/bin/bash
FILEBEAT_VERSION=https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.3.0-x86_64.rpm
if [ "$USER" == "root" ]; then
 echo "filebeat installing... [rpm] "
 rpm -ivh ${FILEBEAT_VERSION}
 cp /etc/filebeat/filebeat.yml /etc/filebeat/filebeat.ybak
 if [ $? -eq 0 ];then filebeat version;else echo "filebeat install filed.";fi
else
 echo -e "User is \e[033m$USER\e[0m, placse use \e[035mroot\e[0m install."
 exit 0
fi

