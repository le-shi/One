> **这个脚本适用Ubuntu, Centos**

     Ubuntu 16.04.5 LTS (GNU/Linux 4.4.0-117-generic x86_64)
     Centos 7.6.1810 (GNU/Linux 3.10.0-957.1.3.el7.x86_64)

使用方法
---

1. 安装基础环境: bash 00-initalFabricEnv.sh offlineAll && bash 00-initalFabricEnv.sh offline
2. 加载环境变量: source /etc/profile
3. 启动CA: bash 01.1-initalFabricMspCert.sh startca
4. 初始化fabricMspCert: bash 01.1-initalFabricMspCert.sh inital solo swarm
5. 切换目录: cd ~/fabricHyperledger/fabric-samples/balance-cau
6. 上传链码: cp ~/fabricHyperledger/chain.go artifacts/src/github.com/chain/go/chain.go
7. 运行APP: ./runApp.sh
8. 生成testApi.sh脚本: bash ~/fabricHyperledger/testAPIs/01-initalTestApis.sh
9. 运行testApi: bash ~/fabricHyperledger/testAPIs/testAPIs.sh
10. 初始化索引: bash ~/fabricHyperledger/04-CouchdbInit.sh

如果过程中遇到问题
停止ca,清理balance和ca的文件
bash 1.1-initalFabricMspCert.sh clean
重新启动ca并运行初始化脚本
继续从上面步骤2开始执行
