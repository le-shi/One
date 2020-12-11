#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/chain/go"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/example_cc/node"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "POST request Enroll on Ceea  ..."
echo
CEEA_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Ceea-qJim&orgName=Ceea')
echo $CEEA_TOKEN
CEEA_TOKEN=$(echo $CEEA_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "CEEA token is $CEEA_TOKEN"
echo

echo "POST request Enroll on Amazingsys  ..."
echo
AMAZINGSYS_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Amazingsys-qJim&orgName=Amazingsys')
echo $AMAZINGSYS_TOKEN
AMAZINGSYS_TOKEN=$(echo $AMAZINGSYS_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "AMAZINGSYS token is $AMAZINGSYS_TOKEN"
echo

echo "POST request Enroll on Ccid  ..."
echo
CCID_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Ccid-qJim&orgName=Ccid')
echo $CCID_TOKEN
CCID_TOKEN=$(echo $CCID_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "CCID token is $CCID_TOKEN"
echo

echo "POST request Enroll on Sinobasalt  ..."
echo
SINOBASALT_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Sinobasalt-qJim&orgName=Sinobasalt')
echo $SINOBASALT_TOKEN
SINOBASALT_TOKEN=$(echo $SINOBASALT_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "SINOBASALT token is $SINOBASALT_TOKEN"
echo

echo
echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:4000/channels \
  -H "authorization: Bearer $CEEA_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../artifacts/channel/mychannel.tx"
}'
echo
echo

echo "POST request Join channel on Ceea"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $CEEA_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.ceea.unichain.org.cn","peer1.ceea.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Amazingsys"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $AMAZINGSYS_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.amazingsys.unichain.org.cn","peer1.amazingsys.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Ccid"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $CCID_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.ccid.unichain.org.cn","peer1.ccid.unichain.org.cn"]
}'
echo
echo

echo "POST request Join channel on Sinobasalt"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/peers \
  -H "authorization: Bearer $SINOBASALT_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.sinobasalt.unichain.org.cn","peer1.sinobasalt.unichain.org.cn"]
}'
echo
echo

echo "POST Install chaincode on Ceea"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $CEEA_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.ceea.unichain.org.cn\",\"peer1.ceea.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Amazingsys"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $AMAZINGSYS_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.amazingsys.unichain.org.cn\",\"peer1.amazingsys.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Ccid"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $CCID_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.ccid.unichain.org.cn\",\"peer1.ccid.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST Install chaincode on Sinobasalt"
echo
curl -s -X POST \
  http://localhost:4000/chaincodes \
  -H "authorization: Bearer $SINOBASALT_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"peers\": [\"peer0.sinobasalt.unichain.org.cn\",\"peer1.sinobasalt.unichain.org.cn\"],
	\"chaincodeName\":\"chain\",
	\"chaincodePath\":\"$CC_SRC_PATH\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"chaincodeVersion\":\"v0\"
}"
echo
echo

echo "POST instantiate chaincode on Ceea"
echo
curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes \
  -H "authorization: Bearer $CEEA_TOKEN" \
  -H "content-type: application/json" \
  -d "{
	\"chaincodeName\":\"chain\",
	\"chaincodeVersion\":\"v0\",
	\"chaincodeType\": \"$LANGUAGE\",
	\"args\":[\"a\",\"100\",\"b\",\"200\"]
}"
echo
echo

echo "GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

#echo "GET query Transaction by TransactionID"
#echo
#curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.unichain.org.cn \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "content-type: application/json"
#echo
#echo

############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ORG1_TOKEN"
#echo
#echo

echo "GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.unichain.org.cn" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total execution time : $(($(date +%s)-starttime)) secs ..."
