> **这个脚本适用Ubuntu, Centos**

     Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-117-generic x86_64)
     Centos 7.6.1810 (GNU/Linux 3.10.0-957.1.3.el7.x86_64)

使用方法
---

1. 自动安装基础环境(安装docker和docker-compose和fabric-sample): bash 00-initalFabricEnv.sh offlineAll && bash 00-initalFabricEnv.sh offline

2. 单独安装fabric-sample: wget -Nc https://zbx-fabric.oss-cn-beijing.aliyuncs.com/fabric-samples-1.3.tar.gz && tar -zxf fabric-samples-1.3.tar.gz && echo "export PATH=\$PATH:$(pwd)/fabric-samples/bin" >> /etc/profile
3. 单独创建网络: docker swarm init && docker network create --attachable --driver overlay microservices
4. 添加私服仓库认证信息: docker login cr.xxx.com
5. 安装 jq 工具: yum install jq -y
6. 拉取 ccenv 镜像: docker pull cr.xuanwuku.com/hyperledger/fabric-ccenv:1.3.0 && docker tag cr.xuanwuku.com/hyperledger/fabric-ccenv:1.3.0 hyperledger/fabric-ccenv:latest

7. 加载环境变量: source /etc/profile
8. 修改 01.1-initalFabricMspCert.sh 中的机器IP地址
9. 启动CA: bash 01.1-initalFabricMspCert.sh startca
10. 初始化fabricMspCert: bash 01.1-initalFabricMspCert.sh inital solo swarm
11. 切换目录: cd ~/fabricHyperledger/fabric-samples/balance-cau
12. 上传链码: cp ~/fabricHyperledger/chain.go artifacts/src/github.com/chain/go/chain.go

编辑 app/instantiate-chaincode.js 修改endorsement-policy下的mspId
CeeaMSP
AmazingsysMSP

将 artifacts/docker-compose.yaml 的 peer0和couchdb0的数据库认证密码去掉

7. 运行APP: ./runApp.sh
8. 生成testApi.sh脚本: bash ~/fabricHyperledger/testAPIs/01-initalTestApis.sh
9. 运行testApi.sh脚本: bash ~/fabricHyperledger/testAPIs/testAPIs.sh
10. 初始化索引(判断逻辑有待提高): bash ~/fabricHyperledger/04-CouchdbInit.sh
11. 初始化视图: bash ~/fabricHyperledger/05-CouchdbInitView.sh
12. 增加机构: bash ~/fabricHyperledger/06-CouchdbAddOrg.sh
13. 刷新状态(新增的记录需要30分钟以上才可以更新): bash ~/fabricHyperledger/07-CouchdbOrgUpdateStatus.sh
14. [前提: 12,13完成]可以在网页添加"重点关注","失信企业"

如果过程中遇到问题
停止ca,清理balance和ca的文件
bash 1.1-initalFabricMspCert.sh clean
重新启动ca并运行初始化脚本，继续从上面步骤3开始执行

如果其中一个peer和couchdb需要关闭认证; 必须重新加入channel: 使用testApis.sh执行joinChannel操作；然后再重新安装chaincode: 使用testApis.sh执行installChaincode操作
updateStatus: 动态报文，获取最新编号，找最大的编号 `curl -s 0.0.0.0:7981/mychannel_chain/_all_docs | grep contract_`

验证
---
nodeapp:
- nodeapp容器启动后，会有俩进程同时运行一个是node的sdk，另一个是sidecar进程，可以通过look.sh查看注册中心的CHAIIN服务，如果没有尝试启动一下sidecar进程
- 日志出现这个错误可以忽略: UnauthorizedError: jwt malformed
