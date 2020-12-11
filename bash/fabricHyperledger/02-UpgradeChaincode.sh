#!/bin/bash
#在宿主机执行，需要启动cli容器
#传参： 域名 链码名 链码版本
# Upgrade: scripts.sh Upgrade - unichain.org.cn chain v2
# Query: scripts.sh Query
# query: scripts.sh query

#1.获取现有cc版本
#2.设置更新的cc版本
#3.安装new_cc --每个org；2peer
#4.实例化cc
#5.每个org执行query(应用新的cc)

DOMAIN_NAME=${3}
CHAINCODE_NAME=${4}
CHAINCODE_VERSION=${5}
: ${DOMAIN_NAME:="unichain.org.cn"}
: ${CHAINCODE_NAME:="chain"}
: ${CHAINCODE_VERSION:="v1"}
ORDERER_DOMAIN_NAME=orderer.${DOMAIN_NAME}
CHANNEL_NAME=mychannel
CHAINPATH=github.com/chain/go
ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}/orderers/${ORDERER_DOMAIN_NAME}/msp/tlscacerts/tlsca.${DOMAIN_NAME}-cert.pem
STATIC_FILE=~/orgList


starttime=$(date +%s)
#检查org列表文件是否存在
[ -f ${STATIC_FILE} ] || (echo -e "Not Found File ${STATIC_FILE} ,Placse prepare the file.\nFormat: orgname;peer0 port1,port2;peer1 port3,port4\n\nDefault: org1;peer0 7051,7053;peer1 7056,7058\n         org2;peer0 8051,8053;peer1 8056,8058\n         org3;peer0 9051,9053;peer1 9056,9058\n" && exit 1)

# 遍历org列表
fabricFor (){
  listFile=${STATIC_FILE}
  funName=${1}
  grep -Ev '#|^$' ${listFile} | while read line
  do
    org=$(echo ${line} | awk -F ";" '{print $1}')
    Org=$(echo $org | sed 's/^[a-z]/\U&/')
    peer_count=$(echo ${line} | grep -o "peer" | wc -l)
    for((peer=0;peer<${peer_count};peer++));do
        ${funName}
        if [[ ${funName} == "fabircUpgradeChaincode" ]];then break;fi
        if [[ ${funName} == "fabircInvokeChaincode" ]];then break;fi
    done
    if [[ ${funName} == "fabircUpgradeChaincode" ]];then break;fi
    if [[ ${funName} == "fabircInvokeChaincode" ]];then break;fi
    if [[ ${funName} == "fabircQueryChaincode" ]];then sleep 30;fi
  done
}

# cli命令传变量
fabricSetCliCommand (){
    CLI_COMMAND=${*}
    docker exec \
    -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.${DOMAIN_NAME}/peers/peer${peer}.${org}.${DOMAIN_NAME}/tls/ca.crt \
    -e CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.${DOMAIN_NAME}/peers/peer${peer}.${org}.${DOMAIN_NAME}/tls/server.key \
    -e CORE_PEER_LOCALMSPID=${Org}MSP \
    -e CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.${DOMAIN_NAME}/peers/peer${peer}.${org}.${DOMAIN_NAME}/tls/server.crt \
    -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${org}.${DOMAIN_NAME}/users/Admin@${org}.${DOMAIN_NAME}/msp \
    -e CORE_PEER_ADDRESS=peer${peer}.${org}.${DOMAIN_NAME}:7051 \
    -e ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${DOMAIN_NAME}/orderers/${ORDERER_DOMAIN_NAME}/msp/tlscacerts/tlsca.${DOMAIN_NAME}-cert.pem \
    cli ${CLI_COMMAND}
    # -ti cli peer chaincode query -C mychannel -n mycc -c '{"Args":["query","a"]}'
}

# 清理旧dev容器,镜像
fabricCleanOldDev (){
    echo "Clean Old Dev (Images AND Container)"
    docker rm -f $(docker ps -f name=dev-* -aq)
    docker rmi $(docker images dev* -q)
    echo
}

# 安装cc * all
fabircInstallChaincode (){
    echo "CLI Installing chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    fabricSetCliCommand peer chaincode install -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -l golang -p ${CHAINPATH}
    echo
}

# 升级cc * one
fabircUpgradeChaincode (){
    echo "CLI Upgradeing chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    fabricSetCliCommand peer chaincode upgrade -o ${ORDERER_DOMAIN_NAME}:7050 --tls --cafile ${ORDERER_CA} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -v ${CHAINCODE_VERSION} -c '{"Args":["init","a","100","b","20"]}' -P 'AND("Org1MSP.member","Org2MSP.member")'
    echo
}

# 执行query * all
fabircQueryChaincode (){
    echo "CLI GET query chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    fabricSetCliCommand peer chaincode query -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} -c '{"Args":["queryObj","seq"]}'
    echo
}

# 执行ivoke * all --暂时停用
fabircInvokeChaincode (){
    echo "CLI GET ivoke chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    fabricSetCliCommand peer chaincode invoke -o ${ORDERER_DOMAIN_NAME}:7050 --tls --cafile ${ORDERER_CA} -C ${CHANNEL_NAME} -n ${CHAINCODE_NAME} \
    --peerAddresses peer0.org1.unichain.org.cn:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.unichain.org.cn/peers/peer0.org1.unichain.org.cn/tls/ca.crt \
    --peerAddresses peer0.org2.unichain.org.cn:7051 \
    --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.unichain.org.cn/peers/peer0.org2.unichain.org.cn/tls/ca.crt \
    -c '{"Args":["move","a","b","10"]}'
    
    echo
}

# cli Query Installed chaincodes
fabricQueryInstalledChaincodes (){
    echo "CLI GET query Installed chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    echo
    fabricSetCliCommand peer chaincode list --installed
    echo
}

# cli Query Instantiated chaincodes
fabricQueryInstantiatedChaincodes (){
    echo "CLI GET query Instantiated chaincodes -- peer${peer}.${org}.${DOMAIN_NAME}"
    echo
    fabricSetCliCommand peer chaincode -C ${CHANNEL_NAME} list --instantiated
    echo
}

# cli Query Channels
fabricQueryChannels (){
    echo "CLI GET query Channels -- peer${peer}.${org}.${DOMAIN_NAME}"
    echo
    fabricSetCliCommand peer channel list
    echo    
}

#################################### Upgrade Start #####################################
fabricUpgrade (){
    # 清理旧dev容器,镜像
    fabricCleanOldDev

    #安装新版本cc * all
    fabricFor fabircInstallChaincode

    # 升级cc * one
    fabricFor fabircUpgradeChaincode

    # 执行query * all
    #升级完等待10s
    sleep 10
    fabricFor fabircQueryChaincode

    # 执行ivoke * all --暂时停用
    # fabricFor fabircInvokeChaincode
}
#################################### Upgrade End #########################################
#################################### Query Start #########################################
fabricquery (){
    fabricFor fabircQueryChaincode
}
fabricQuery (){
    # cli Query Installed chaincodes
    fabricFor fabricQueryInstalledChaincodes

    # cli Query Instantiated chaincodes
    fabricFor fabricQueryInstantiatedChaincodes

    # cli Query Channels
    fabricFor fabricQueryChannels
}
#################################### Query End ###########################################
echo "=> START <="
#################################### Command Start #######################################

caseme=${1}
case ${caseme} in
Upgrade)fabricUpgrade;;
Query)fabricQuery;;
query)fabricquery;;
*)echo "$0 [Upgrade|Query|query]";;
esac
#################################### Command End #########################################

echo "=> A Good End. <="
echo "Total execution time : $(($(date +%s)-starttime)) secs ..."

# ########################
# 1.第一个peer安装新版本cc
# 执行upgrade --慢
# 执行query
# 2.第二个安装新cc
# 执行query --慢
# 3.第三个安装新cc
# 执行query --慢
# ########################
# 1.第一个peer安装新版本cc
# 执行query --基于老cc
# 2.第二个安装新cc
# 执行query --基于老cc
# 3.第三个安装新cc
# 执行query --基于老cc
# ########################
# 1.第一个peer安装新版本cc
# 2.第二个安装新cc
# 3.第三个安装新cc
# 4.执行upgrade --当前节点·慢；升级完sleep 10
# 5.每个机构执行query --2节点·慢; sleep 30
# ########################

