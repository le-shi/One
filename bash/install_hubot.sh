#!/bin/bash
set -e
rpm -qa | grep wget || yum -y install wget
#安装node版本
node_version=8.11.4
#安装node路径
node_home_path=/usr/local
#Toekn ID
Slack_Token=xxxx-000000000000-000000000000-xxxxxxxxxxxxxxxxxxxxxxxx

function node_install (){
  echo "Install Node..."
  #安装node和npm
  if [ ! -d ${node_home_path}/node ];then
    if [ ! -f /tmp/node-v${node_version}-linux-x64.tar.xz ];then
    wget -O /tmp/node-v${node_version}-linux-x64.tar.xz https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz;fi
    xz -d /tmp/node-v${node_version}-linux-x64.tar.xz
    tar -xf /tmp/node-v${node_version}-linux-x64.tar
    mv node-v${node_version}-linux-x64/ ${node_home_path}/node
    grep "export NODE_HOME=${node_home_path}/node" /etc/profile || echo "export NODE_HOME=${node_home_path}/node" >> /etc/profile
    grep 'export PATH=$NODE_HOME/bin:$PATH' /etc/profile ||  echo 'export PATH=$NODE_HOME/bin:$PATH' >> /etc/profile
    source /etc/profile
    echo "node : $(node -v)"
    echo "npm : $(npm -v)"
    echo "Node Install Finished: SUCCESS"
  else
    :
  fi
}

function userad_node (){
  if  grep -Eq "node" /etc/passwd ;then :;else useradd node;  echo "node" | passwd node --stdin;fi
}

function Hubot_install_yo (){
  node_install
  echo "Install Hubot..."
  npm i -g npm to update
  if type yo > /dev/null 2>&1; then :;else npm install -g yo generator-hubot;fi
}

function Hubot_install (){
  export node_data=/home/node/Hubot/node-$(date '+%F')
  if [ -d ${node_data} ];then :;else mkdir -pv ${node_data};fi
  chmod g+rwx ${node_data}
  chown node.node -R ${node_data}
  echo "++根据提示填写相关信息: [Email, HuhotName, Bs]";
  su - node -c "cd ${node_data} && yo hubot --adapter=slack"
  echo "Hubot Install Finished: SUCCESS"
  sleep 1
  echo "++输入机器人连接Slack的Token："
  echo "++Ps: [登陆slack，添加app，进入app商店搜索hubot，然后安装，如果已经安装就是可以添加机器人，下滑有这个机器人的Token值]"
  grep "export HUBOT_SLACK_TOKEN=" /etc/profile || echo "export HUBOT_SLACK_TOKEN=${Slack_Token}" >> /etc/profile
  source /etc/profile > /dev/null
  echo "Start Hubot_slack..."
  su - node -c "cd ${node_data} && nohup ./bin/hubot --adapter slack 2&>1 >> /dev/null &"
}

userad_node
Hubot_install_yo
Hubot_install

