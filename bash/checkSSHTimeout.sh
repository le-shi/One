#!/bin/bash
# 设置ssh无操作自动断开连接，超时时间300秒(5分钟)

count=$(grep -c "TMOUT" /etc/profile)

if [[ ${count} == 0 ]]
then
   echo "export TMOUT=300" >> /etc/profile
   echo "OK."
else
   echo "PASS [${count}]."
fi

echo
echo "Before"
grep ClientAlive /etc/ssh/sshd_config
sed -i -e "s/#ClientAliveInterval.*/ClientAliveInterval 300/g" -e "s/#ClientAliveCountMax.*/ClientAliveCountMax 2/g" /etc/ssh/sshd_config
echo "After"
grep ClientAlive /etc/ssh/sshd_config
echo
service sshd restart
