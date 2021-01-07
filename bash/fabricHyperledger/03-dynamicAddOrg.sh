#!/bin/bash
#set -e
#支持动态获取当前cc的版本
domainName=DOMAINNAME
ordererDomainName=orderer.${domainName}
unionRootCa=$(echo $domainName | awk -F "." '{print $NF}')
unionSecond=${unionRootCa}.$(echo $domainName | awk -F "." '{print $(NF-1)}')
unionOrderer=${unionSecond}.$(echo $domainName | awk -F "." '{print $(NF-2)}')
org=ORGNAME
Org=$(echo ${org} | sed "s/^[a-z]/\U&/")
CHAINCODE_NAME=CCNAME
nodeAppAddress=NODEADDRESS

CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
VERBOSE="$5"
#获取当前cc版本号
CC_VERSION=$(peer chaincode list --instantiated -C mychannel | grep Version | awk '{print $4}' | awk -F ',' '{print $1}')
#获取已经安装的cc数；如果是1，则使用node安装cc；如果大于1，则使用cli安装cc
CC_NUM=$(peer chaincode list --installed | grep Version -c)

: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
: ${VERBOSE:="false"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5

CC_SRC_PATH="github.com/chain/go/"
if [ "$LANGUAGE" = "node" ]; then
        CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi



ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/${domainName}/orderers/${ordererDomainName}/msp/tlscacerts/tlsca.${domainName}-cert.pem

###################################################################



#fetch channel配置 | cli
fetchChannelConfig() {
  CHANNEL=$1
  OUTPUT=./${org}/mychannel_config.json

  echo "Fetching the most recent configuration block for the channel"
  if [ -z "${CORE_PEER_TLS_ENABLED}" -o "${CORE_PEER_TLS_ENABLED}" = "false" ]; then
    set -x
    #获取当前channel的配置，输出为protobuf格式的文件config_block.pb
    peer channel fetch config config_block.pb -o ${ordererDomainName}:7050 -c ${CHANNEL} --cafile ${ORDERER_CA}
    set +x
  else
    set -x
    #获取当前channel的配置，输出为protobuf格式的文件config_block.pb
    cd /opt/gopath/src/github.com/hyperledger/fabric/peer
    peer channel fetch config config_block.pb -o ${ordererDomainName}:7050 -c ${CHANNEL} --tls --cafile ${ORDERER_CA}
    set +x
  fi

  echo "Decoding config block to JSON and isolating config to ${OUTPUT}"
  set -x
  #将pb格式转换为json格式，重新存放到一个新json文件中config_block.pb --> mychannel_config.json
  configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config >"${OUTPUT}"
  set +x
}

verifyResult () {
  if [ $1 -ne 0 ]; then
    echo "!!!!!!!!!!!!!!! "$2" !!!!!!!!!!!!!!!!"
    echo "========= ERROR !!! FAILED to execute New Org Scenario ==========="
    echo
    exit 1
  fi
}

#
joinChannelWithRetry () {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  set -x
  peer channel join -b $CHANNEL_NAME.block >& peer${PEER}.${ORG}.jcclog.txt
  res=$?
  set +x
  cat peer${PEER}.${ORG}.jcclog.txt
  if [ $res -ne 0 -a $COUNTER -lt $MAX_RETRY ]; then
    COUNTER=$(expr $COUNTER + 1)
    echo "peer${PEER}.org${ORG} failed to join the channel, Retry after $DELAY seconds"
    sleep $DELAY
    joinChannelWithRetry $PEER $ORG
  else
    COUNTER=1
  fi
  verifyResult $res "After $MAX_RETRY attempts, peer${PEER}.${ORG} has failed to join channel '$CHANNEL_NAME' "
  echo "===================== peer${PEER}.${ORG} joined channel '$CHANNEL_NAME' ===================== "
}

# --暂时停用
installChaincode () {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG
  VERSION=${3:-1.0}
  echo "Installing chaincode ${VERSION} on peer${PEER}.${ORG}..."
  set -x
  peer chaincode install -n ${CHAINCODE_NAME} -v ${VERSION} -l ${LANGUAGE} -p ${CC_SRC_PATH} >& peer${PEER}.${ORG}.icclog.txt
  res=$?
  set +x
  cat peer${PEER}.${ORG}.icclog.txt
  verifyResult $res "Chaincode installation on peer${PEER}.${ORG} has failed"
  echo "===================== Chaincode is installed on peer${PEER}.${ORG} ===================== "
  echo
}

# --暂时停用
upgradeChaincode() {
  PEER=$1
  ORG=$2
  setGlobals $PEER $ORG

  set -x
  peer chaincode upgrade -o ${ordererDomainName}:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "AND ('Org1MSP.peer','Org2MSP.peer','${OrgName}MSP.peer')"
  res=$?
  set +x
  # cat peer${PEER}.${ORG}log.txt
  verifyResult $res "Chaincode upgrade on peer${PEER}.${ORG} has failed"
  echo "===================== Chaincode is upgraded on peer${PEER}.${ORG} on channel '$CHANNEL_NAME' ===================== "
  echo
}

createConfigUpdate () {
  CHANNEL=$1
  ORIGINAL=$2
  MODIFIED=$3
  OUTPUT=$4

  set -x
  #将mychannel-config.json转换为pb格式文件 mychannel_config.pb
  configtxlator proto_encode --input "./${org}/${ORIGINAL}" --type common.Config > ./${org}/mychannel_config.pb
  #将合并后的josn文件modified_config.json，转换为pb格式modified_config.pb
  configtxlator proto_encode --input "./${org}/${MODIFIED}" --type common.Config > ./${org}/modified_config.pb
  #比较mychannel_config.pb和modified_config.json，将计算出的差异部分输出到一个新的pb文件里org_update.pb
  configtxlator compute_update --channel_id "${CHANNEL}" --original ./${org}/mychannel_config.pb --updated ./${org}/modified_config.pb > ./${org}/${org}_update.pb
  #将差异pb文件 org_update.pb 转换为json格式 org_updte.json
  configtxlator proto_decode --input ./${org}/${org}_update.pb --type common.ConfigUpdate | jq . > ./${org}/${org}_update.json
  #用jq工具修改payload，生成org__update_in_envelope.json文件
  echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL'", "type":2}},"data":{"config_update":'$(cat ./${org}/${org}_update.json)'}}}' | jq . > ./${org}/${org}_update_in_envelope.json
  #将org_update_in_envelope.json文件转码为pb文件 org_update_in_envelope.pb
  configtxlator proto_encode --input ./${org}/${org}_update_in_envelope.json --type common.Envelope >"./${org}/${OUTPUT}"
  set +x
}

#使用node安装cc，在初始化后，升级cc之前可以使用
nodeInstallChainCode (){
  echo "POST request Enroll on ${Org}  ..."
  echo
  ORG_TOKEN=$(curl -s -X POST \
    http://${nodeAppAddress}:4000/users \
    -H "content-type: application/x-www-form-urlencoded" \
    -d "username=${Org}-qJim&orgName=${Org}")
  echo $ORG_TOKEN
  ORG_TOKEN=$(echo $ORG_TOKEN | jq ".token" | sed "s/\"//g")
  echo
  echo "${Org} token is $ORG_TOKEN"

  echo "POST Install chaincode on ${Org}"
  echo
  curl -s -X POST \
    http://${nodeAppAddress}:4000/chaincodes \
    -H "authorization: Bearer $ORG_TOKEN" \
    -H "content-type: application/json" \
    -d "{
    \"peers\": [\"peer0.${org}.${domainName}\",\"peer1.${org}.${domainName}\"],
    \"chaincodeName\":\"${CHAINCODE_NAME}\",
    \"chaincodePath\":\"$CC_SRC_PATH\",
    \"chaincodeType\": \"$LANGUAGE\",
    \"chaincodeVersion\":\"${CC_VERSION}\"
  }"
}

setGlobals (){
  peerNum=${1}
  orgName=${2}
  OrgName=$(echo ${orgName} | sed 's/^[a-z]/\U&/')

  CORE_PEER_ID=cli
  CORE_PEER_ADDRESS=peer${peerNum}.${orgName}.${domainName}:7051
  CORE_PEER_LOCALMSPID=${OrgName}MSP
  CORE_PEER_TLS_ENABLED=true
  CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/server.crt
  CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/server.key
  CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/peers/peer${peerNum}.${orgName}.${domainName}/tls/ca.crt
  CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${orgName}.${domainName}/users/Admin@${orgName}.${domainName}/msp
}


# cli处理新加org操作
fabircCliDynamicAddOrg (){
  echo
  echo "========= Starting add org =========== "
  echo
  # ---New---取块
  peer channel fetch 0 mychannel.block -o ${ordererDomainName}:7050 -c mychannel --tls --cafile ${ORDERER_CA}
  # 获取当前channel的配置，并转码为json
  fetchChannelConfig ${CHANNEL_NAME}
#  peer channel fetch config config_block.pb -o orderer.unichain.org.cn:7050 -c mychannel --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/unichain.org.cn/orderers/orderer.unichain.org.cn/msp/tlscacerts/tlsca.unichain.org.cn-cert.pem
  # 修改新json文件，加入新org
  set -x
  jq -s ".[0] * {"channel_group":{"groups":{"Application":{"groups": {"${Org}MSP":.[1]}}}}}" ./${org}/mychannel_config.json ./${org}/${org}.json > ./${org}/modified_config.json
  set +x
  # 通过对比原来的channel和新加入org的配置pb文件，最终生成org_update_in_envelope.pb文件
  createConfigUpdate ${CHANNEL_NAME} mychannel_config.json modified_config.json  ${org}_update_in_envelope.pb

################################################################################
  #1.查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  #使用org1的身份对其进行签名
  set -x
  peer channel signconfigtx -f ./${org}/${org}_update_in_envelope.pb
  res=$?
  set +x
  verifyResult ${res} "|| 1 || update channel failed ${org}"

  #2.切换org身份到org2
  setGlobals 0 org2
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  set -x
  #使用org2的身份对其进行签名
  peer channel signconfigtx -f ./${org}/${org}_update_in_envelope.pb
  res=$?
  set +x
  verifyResult ${res} "|| 2 || update channel failed ${org}"

  #3.切换org身份到org3
  setGlobals 0 org3
  #查看当前Org身份
  echo "${CORE_PEER_LOCALMSPID}"
  set -x
  #update操作隐含了signconfigtx操作
  #使用org3的身份对其进行签名并进行update操作
  peer channel update -f ./${org}/${org}_update_in_envelope.pb -c ${CHANNEL_NAME} -o ${ordererDomainName}:7050 --tls --cafile ${ORDERER_CA}
  res=$?
  set +x
  verifyResult ${res} "|| 3 || update channel failed ${org}"
################################################################################

  #执行新org的peer0节点的Join channel
  joinChannelWithRetry 0 ${org}
  #执行新org的peer1节点的Join channel
  joinChannelWithRetry 1 ${org}
  
  #执行新org的install chaincode
  # nodeInstallChainCode
  if [ ${CC_NUM} -eq 1 ];then
    #_判断当前的cc是不是通过node安装的
    nodeInstallChainCode
  elif [ ${CC_NUM} -gt 1 ];then
    #_执行新org的peer0节点的install chaincode
    installChaincode 0 ${org} ${CC_VERSION}
    #_执行新org的peer1节点的install chaincode
    installChaincode 1 ${org} ${CC_VERSION}
  else
    echo "Check that the number of chain codes installed is wrong (less than 1)"   
  fi
  # installChaincode 0 ${org} ${CC_VERSION}
  # #执行新org的peer1节点的install chaincode
  # installChaincode 1 ${org} ${CC_VERSION}

  echo
  echo "Is Good."
  echo "Dynamic Add Org END -- OrgName [${org}]"
}

############调用运行##############
fabircCliDynamicAddOrg
