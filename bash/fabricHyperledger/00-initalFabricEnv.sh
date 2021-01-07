#!/bin/bash
#Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-117-generic x86_64)

# set -e

## Docker Image Setting
# if version not passed in, default to latest released version
export VERSION=1.3.0
# if ca version not passed in, default to latest released version
export CA_VERSION=$VERSION
# current version of thirdparty images (couchdb, kafka and zookeeper) released
export THIRDPARTY_IMAGE_VERSION=0.4.13
export ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')")
export MARCH=$(uname -m)

UserName=org1
UserPass=org1
UserHome=/home/${UserName}/fabricHyperledger
GoVersion=1.10.2
NodeVersion=8.9.4
SamplesVersion=1.3

###
# file: fabric-samples/balance-transfer/package.json
# {
#   ...
#   "dependencies": {
#     "fabric-ca-client": "unstable",
#     "fabric-client": "unstable",
#     ...
#   }
# }

# to -->

# {
#   ...
#   "dependencies": {
#     "fabric-ca-client": "1.3.0",
#     "fabric-client": "1.3.0",
#     ...
#   }
# }
###

#ComposeVersion=1.20.1
GoPackage=go${GoVersion}.linux-amd64.tar.gz
NodePackage=node-v${NodeVersion}-linux-x64.tar.gz
SamplesPackage=fabric-samples-${SamplesVersion}.tar.gz
#外网地址
DownloadUrl=https://zbx-fabric.oss-cn-beijing.aliyuncs.com
GoDownloadPath=${DownloadUrl}/${GoPackage}
NodeDownloadPath=${DownloadUrl}/${NodePackage}
DockerInstallPath=${DownloadUrl}/docker-install.sh
DockerComposePath=https://software-factory.oss-cn-beijing.aliyuncs.com/docker-compose
FabricSamplesPath=${DownloadUrl}/${SamplesPackage}

fabricEcho (){
  echo "###Starting Install...############################################### [$*]"
}

fabricCheckServer (){
 if type "${1}" > /dev/null 2>&1;then :;else "${2}";fi
}

Get_System_Name (){
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release; then
        system_version_num=$(uname -r | awk -F "el" '{print $2}' |  awk -F '.' '{print $1}')
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

wgetSet(){
  wget -Nc -nv -t 3 ${@}
  # wget --timestamping --continue  --no-verbose --tries=3 ${1}
}

doCentosInstallDocker(){
  #解压拷贝docker二进制文件
  tar -xf docker-19.03.14.tgz
  mv docker/* /usr/bin/ && rm docker -rf
  #生成docker服务文件并添加到自启动
  cat > /etc/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock
ExecReload=/bin/kill -s HUP $MAINPID
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TimeoutStartSec=0
Delegate=yes
KillMode=process
Restart=on-failure
StartLimitBurst=3
StartLimitInterval=60s

[Install]
WantedBy=multi-user.target
EOF

  chmod +x /etc/systemd/system/docker.service
  # 优化docker日志
  mkdir -p /etc/docker
  cat > /etc/docker/daemon.json <<EOF
{
  "max-concurrent-downloads": 10,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "20m",
    "max-file": "100"
  },
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com"
  ]
}
EOF
  systemctl start docker
  systemctl enable docker

  # docker swarm init
  # docker network create --attachable --driver overlay microservices
}

fabricUseradd (){
  #useradd hpyer
  if grep ${UserName} /etc/passwd;then
    echo "Useradd: user '${UserName}' already exists."
  else
    useradd -m -s /bin/bash -d ${UserHome} ${UserName}
    echo "User ${UserName}..."
    echo "${UserName}:${UserPass}" | chpasswd    
  fi
  echo "${UserName} ALL=(ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/${UserName}
  #su - ${UserName}
}

fabricClose (){
  fabricEcho 关闭路由[针对阿里云]
  if [ -f /etc/resolvconf/resolv.conf.d/tail ];then
    sed -i "s/options timeout:2 attempts:3 rotate single-request-reopen//g" /etc/resolvconf/resolv.conf.d/tail && service resolvconf restart
  elif [ -f /etc/resolv.conf ];then
    sed -i "s/options timeout:2 attempts:3 rotate single-request-reopen//g" /etc/resolv.conf
  else
    :
  fi
}

fabricDockerInstall (){
  #安装docker环境
  fabricEcho Docker
  if [[ ${system_version} == "Ubuntu" ]];then
    su - ${UserName} -c "curl -sSL ${DockerInstallPath} | bash -s "
  elif [[ ${system_version} == "CentOS" ]];then
    doCentosInstallDocker
  fi
}

fabricUpdate (){
  #apt 更新升级
  fabricEcho upgrade
  if [[ ${system_version} == "Ubuntu" ]];then
    sudo apt install make g++ jq tree -y
  elif [[ ${system_version} == "CentOS" ]];then
    yum install -y -q make gcc-c++ jq tree 
  fi
}

fabricDockerComposeInstall (){
  #安装docker-compose
  fabricEcho docker-compose
  sudo cp docker-compose /usr/bin/docker-compose
  sudo chmod +x /usr/bin/docker-compose
  docker-compose -v
}

fabricGoInstall (){
  #安装go
  fabricEcho go
  wget -N ${GoDownloadPath} 2> /dev/null
  [[ -d /usr/local/go ]] || sudo tar -C /usr/local -zxf go${GoVersion}.linux-amd64.tar.gz
  [[ -d ${UserHome}/go ]] || mkdir ${UserHome}/go
  grep "export GOPATH=/home/${UserName}/go" /etc/profile ||  echo "export GOPATH=/home/${UserName}/go" >> /etc/profile
  grep 'export GOROOT=/usr/local/go' /etc/profile || echo 'export GOROOT=/usr/local/go' >> /etc/profile
  grep 'export GOARCH=amd64' /etc/profile || echo 'export GOARCH=amd64' >> /etc/profile
  grep 'export GOOS=linux' /etc/profile || echo 'export GOOS=linux' >> /etc/profile
  grep 'export GOTOOLS=$GOROOT/pkg/tool' /etc/profile || echo 'export GOTOOLS=$GOROOT/pkg/tool' >> /etc/profile
  grep 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' /etc/profile || echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> /etc/profile
  source /etc/profile
  source .bashrc
  go version
}

fabricNodeInstall (){
  #安装node和npm
  fabricEcho node
  wget -N ${NodeDownloadPath} 2> /dev/null
  tar zxf node-v${NodeVersion}-linux-x64.tar.gz
  sudo mv node-v${NodeVersion}-linux-x64 /usr/local/node
  sudo ln -s /usr/local/node/bin/npm /usr/local/bin/npm
  sudo ln -s /usr/local/node/bin/node /usr/local/bin/node
  node -v
  npm -v
}

fabricPythonInstall (){
  #安装python
  fabricEcho python
  if [[ ${system_version} == "Ubuntu" ]];then
    sudo apt install -y python
  elif [[ ${system_version} == "CentOS" ]];then
    yum install -y -q python
  fi
}

fabricOrgListGenerate(){
  echo """org1;peer0 7051,7053;peer1 7056,7058;couchdb 7981,7986;123456
org2;peer0 8051,8053;peer1 8056,8058;couchdb 8981,8986;123456
org3;peer0 9051,9053;peer1 9056,9058;couchdb 9981,9986;123456
""" > orgList
  echo """org4;peer0 10051,10053;peer1 10056,10058;couchdb 10981,10986;123456
""" >> dynamicList
}

fabricCleanPackages (){
  #清理软件包
  fabricEcho clean packages
  mv ${GoPackage} ${NodePackage} ${SamplesPackage} /tmp 2>/dev/null || true
}

fabricVersion (){
  echo "Docker version: "
  docker version
  docker-compose -v
  go version
  echo "node : $(node -v)"
  echo "npm : $(npm -v)"
  python -V
  echo "..."
  # wget -N https://zbx-fabric.oss-cn-beijing.aliyuncs.com/pull_images.sh -P ${UserHome} 2> /dev/null
  # echo "安装完成，镜像下载文件路径:${UserHome}/pull_images.sh"
}

fabricSamplseInstall (){
  #安装fabric-samples
  fabricEcho fabric-samples
  [[ -d fabric-samples-${SamplesVersion}.tar.gz ]] ||wget -N ${FabricSamplesPath} 2> /dev/null
  [[ -d ${UserHome}/fabric-samples ]] || sudo tar -C ${UserHome} -zxf fabric-samples-${SamplesVersion}.tar.gz
  grep "export PATH=\$PATH:${UserHome}/fabric-samples/bin" ${UserHome}/.bashrc || (echo "export PATH=\$PATH:${UserHome}/fabric-samples/bin" >> ${UserHome}/.bashrc)
}


dockerFabricPull() {
  local FABRIC_TAG=$1
  for IMAGES in peer orderer ccenv tools; do
      echo "==> FABRIC IMAGE: $IMAGES"
      echo
      docker pull cr.xuanwuku.com/hyperledger/fabric-$IMAGES:$FABRIC_TAG || true
      docker tag cr.xuanwuku.com/hyperledger/fabric-$IMAGES:$FABRIC_TAG hyperledger/fabric-$IMAGES
  done
}

dockerThirdPartyImagesPull() {
  local THIRDPARTY_TAG=$1
  for IMAGES in couchdb kafka zookeeper; do
      echo "==> THIRDPARTY DOCKER IMAGE: $IMAGES"
      echo
      docker pull cr.xuanwuku.com/hyperledger/fabric-$IMAGES:$THIRDPARTY_TAG || true
      docker tag cr.xuanwuku.com/hyperledger/fabric-$IMAGES:$THIRDPARTY_TAG hyperledger/fabric-$IMAGES
  done
}

dockerCaPull() {
      local CA_TAG=$1
      echo "==> FABRIC CA IMAGE"
      echo
      docker pull cr.xuanwuku.com/hyperledger/fabric-ca:$CA_TAG || true
      docker tag cr.xuanwuku.com/hyperledger/fabric-ca:$CA_TAG hyperledger/fabric-ca
}

dockerInstall() {
  which docker >& /dev/null
  NODOCKER=$?
  if [ "${NODOCKER}" == 0 ]; then
    if [[ -f "offline_images.tar" ]]
    then
      docker load -i offline_images.tar
    fi
	  echo "===> Pulling fabric Images"
	  dockerFabricPull ${FABRIC_TAG}
	  echo "===> Pulling fabric ca Image"
	  dockerCaPull ${CA_TAG}
	  echo "===> Pulling thirdparty docker images"
	  dockerThirdPartyImagesPull ${THIRDPARTY_TAG}
	  echo
	  echo "===> List out hyperledger docker images"
	  docker images | grep hyperledger*
  else
    echo "========================================================="
    echo "Docker not installed, bypassing download of Fabric images"
    echo "========================================================="
  fi
}

fabricDockerImagePull(){
  # prior to 1.2.0 architecture was determined by uname -m
  if [[ $VERSION =~ ^1\.[0-1]\.* ]]; then
    export FABRIC_TAG=${MARCH}-${VERSION}
    export CA_TAG=${MARCH}-${CA_VERSION}
    export THIRDPARTY_TAG=${MARCH}-${THIRDPARTY_IMAGE_VERSION}
  else
    # starting with 1.2.0, multi-arch images will be default
    : ${CA_TAG:="$CA_VERSION"}
    : ${FABRIC_TAG:="$VERSION"}
    : ${THIRDPARTY_TAG:="$THIRDPARTY_IMAGE_VERSION"}
  fi

  dockerInstall
}

fabricddd(){
  docker save \
  cr.xuanwuku.com/hyperledger/nodeapp \
  cr.xuanwuku.com/hyperledger/fabric-ca \
  cr.xuanwuku.com/hyperledger/fabric-tools \
  cr.xuanwuku.com/hyperledger/fabric-ccenv \
  cr.xuanwuku.com/hyperledger/fabric-orderer \
  cr.xuanwuku.com/hyperledger/fabric-peer \
  cr.xuanwuku.com/hyperledger/fabric-zookeeper \
  cr.xuanwuku.com/hyperledger/fabric-kafka \
  cr.xuanwuku.com/hyperledger/fabric-couchdb \
  cr.xuanwuku.com/hyperledger/fabric-baseos \
  hyperledger/fabric-ca \
  hyperledger/fabric-tools \
  hyperledger/fabric-ccenv \
  hyperledger/fabric-orderer \
  hyperledger/fabric-peer \
  hyperledger/fabric-zookeeper \
  hyperledger/fabric-kafka \
  hyperledger/fabric-couchdb \
  hyperledger/fabric-baseos \
  -o base_images_01.tar
}

fabricOffline(){
  # base_images_01.tar
  # docker-19.03.14.tgz
  # docker-compose
  # fabric-samples-1.3.tar.gz
  # ntr-chain.go

  set -e
  if [[ $1 == "all" ]];then
    fabricCheckServer docker doCentosInstallDocker
    chmod 777 /var/run/docker.sock
    fabricCheckServer docker-compose fabricDockerComposeInstall
    echo "docker & docker-compose install done."
    exit 0
  fi

  # check docker action
  $(docker ps 2>&1>/dev/null) || (echo "curr user no docker action"; exit 1)
  # docker swarm
  echo "docker swarm..."
  docker_swarm=$(docker info | grep -i swarm)
  if [[ ${docker_swarm} == " Swarm: active" ]];then
    :
  else
    docker swarm init
  fi
  # docker network overlay
  echo "docker swarm network create..."
  docker_swarm_network=$(docker network ls | grep microservices -c)
  if [[ ${docker_swarm_network} == "1" ]];then
    :
  else
    docker network create --attachable --driver overlay microservices
  fi

  # load images
  echo "docker load images..."
  docker load -i base_images_01.tar
  # unpack fabric-samples-1.3.tar.gz
  [[ -d $(pwd)/fabric-samples ]] || tar -C $(pwd) -zxf fabric-samples-1.3.tar.gz
  grep "export PATH=\$PATH:$(pwd)/fabric-samples/bin" /etc/profile || (echo "export PATH=\$PATH:$(pwd)/fabric-samples/bin" >> /etc/profile)
  grep "export PATH=\$PATH:${UserHome}/fabric-samples/bin" ~/.bashrc || (echo "export PATH=\$PATH:${UserHome}/fabric-samples/bin" >> ~/.bashrc)
  # generate orgList
  fabricOrgListGenerate
  # 
}



if [[ $USER == "root" ]];then
  :
  #root用户建普通用户
else
  if [[ $1 == "offline" ]];then
      :
  else
    echo "Placse use su root."
    exit 1
  fi
fi

main(){
  Get_System_Name
  #创建用户
  fabricUseradd
  #关闭防火墙
  fabricClose
  #安装docker
  fabricCheckServer docker fabricDockerInstall
  #更新源
  fabricUpdate
  #进入用户目录
  cd ${UserHome}
  #安装docker-compose
  fabricCheckServer docker-compose fabricDockerComposeInstall
  #安装go
  fabricCheckServer go fabricGoInstall
  #安装node和npm
  fabricCheckServer node fabricNodeInstall
  #安装fabric-samples
  fabricSamplseInstall
  #授权用户目录
  sudo chown ${UserName}.${UserName} -R ${UserHome}
  #清理安装软件包
  fabricCleanPackages
  #输出插件版本
  fabricVersion
  # 生成org列表
  fabricOrgListGenerate
  # 下载docker镜像
  fabricDockerImagePull
}

case $1 in
  offline)fabricOffline;;
  offlineAll)fabricOffline all;;
  main)main;;
  *) echo "Input offline|main";;
esac
