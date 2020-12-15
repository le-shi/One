#!/bin/bash
#Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-117-generic x86_64)

set -e

UserName=org1
UserPass=org1
UserHome=/home/${UserName}
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
DockerComposePath=${DownloadUrl}/docker-compose
FabricSamplesPath=${DownloadUrl}/${SamplesPackage}

fabricEcho (){
  echo "###Starting Install...############################################### [$*]"
}

fabricCheckServer (){
 if type "${1}" > /dev/null 2>&1;then :;else "${2}";fi
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
  else
    :
  fi
}

fabricDockerInstall (){
  #安装docker环境
  fabricEcho Docker
  su - ${UserName} -c "curl -sSL ${DockerInstallPath} | bash -s "
}

fabricUpdateApt (){
  #apt 更新升级
  fabricEcho apt-upgrade
  sudo apt install make g++ jq tree -y
}

fabricDockerComposeInstall (){
  #安装docker-compose
  fabricEcho docker-compose
  sudo curl -L ${DockerComposePath} -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
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
  sudo apt install -y python
  python -V
}


fabricRemove (){
  #清理无用的包
  fabricEcho autoremove
  sudo apt autoremove -y
}


fabricCleanPackages (){
  #清理软件包
  fabricEcho clean packages
  mv ${GoPackage} ${NodePackage} ${SamplesPackage} /tmp
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
  wget -N https://zbx-fabric.oss-cn-beijing.aliyuncs.com/pull_images.sh -P ${UserHome} 2> /dev/null
  echo "安装完成，镜像下载文件路径:${UserHome}/pull_images.sh"
}

fabricSamplseInstall (){
  #安装fabric-samples
  fabricEcho fabric-samples
  wget -N ${FabricSamplesPath} 2> /dev/null
  [[ -d ${UserHome}/fabric-samples ]] || sudo tar -C ${UserHome} -zxf fabric-samples-${SamplesVersion}.tar.gz
  grep "export PATH=\$PATH:${UserHome}/fabric-samples/bin" ${UserHome}/.bashrc || (echo "export PATH=\$PATH:${UserHome}/fabric-samples/bin" >> ${UserHome}/.bashrc)
}

if [[ $USER == "root" ]];then
  :
  #root用户建普通用户
else
  echo "Placse use su root."
  exit 1
fi

#创建用户
fabricUseradd
#关闭防火墙
fabricClose
#安装docker
fabricCheckServer docker fabricDockerInstall
#更新源
fabricUpdateApt
#进入用户目录
cd ${UserHome}
#安装docker-compose
fabricCheckServer docker-compose fabricDockerComposeInstall
#安装go
fabricCheckServer go fabricGoInstall
#安装node和npm
fabricCheckServer node fabricNodeInstall
#安装python
fabricPythonInstall
#清理无用的apt包
#fabricRemove
#安装fabric-samples
fabricSamplseInstall
#授权用户目录
sudo chown ${UserName}.${UserName} -R ${UserHome}
#清理安装软件包
fabricCleanPackages
#输出插件版本
fabricVersion
