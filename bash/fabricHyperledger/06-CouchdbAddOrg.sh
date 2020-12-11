#!/bin/bash
###初始化couchdb
listFile=~/orgList

AddOrg1 (){
  curl -s -X POST http://localhost:4000/channels/mychannel/chaincodes/chain -H "authorization: Bearer ${TOKEN}" -H "content-type: application/json" -d '{"fcn":"addOrg","args":["org1","{\"name\":\"zbx1\",\"certNo\":\"zbx1\",\"certDate\":\"2018-11-09\",\"legalPerson\":\"liuqingbo1\",\"email\":\"zbx1@zbxsoft.com\",\"mobile\":\"18900099889\",\"level\":\"1\",\"certValidityStart\":\"2017-11-09\",\"certValidityEnd\":\"2019-11-09\",\"province\":\"beijing\"}"]}'
}

AddOrg2 (){
  curl -s -X POST http://localhost:4000/channels/mychannel/chaincodes/chain -H "authorization: Bearer ${TOKEN}" -H "content-type: application/json" -d '{"fcn":"addOrg","args":["org2","{\"name\":\"zbx2\",\"certNo\":\"zbx2\",\"certDate\":\"2018-11-09\",\"legalPerson\":\"liuqingbo2\",\"email\":\"zbx2@zbxsoft.com\",\"mobile\":\"18900099889\",\"level\":\"1\",\"certValidityStart\":\"2017-11-09\",\"certValidityEnd\":\"2019-11-09\",\"province\":\"beijing\"}"]}'
}

AddOrg3 (){
  curl -s -X POST http://localhost:4000/channels/mychannel/chaincodes/chain -H "authorization: Bearer ${TOKEN}" -H "content-type: application/json" -d '{"fcn":"addOrg","args":["org3","{\"name\":\"zbx3\",\"certNo\":\"zbx3\",\"certDate\":\"2018-11-09\",\"legalPerson\":\"liuqingbo3\",\"email\":\"zbx3@zbxsoft.com\",\"mobile\":\"18900099889\",\"level\":\"1\",\"certValidityStart\":\"2017-11-09\",\"certValidityEnd\":\"2019-11-09\",\"province\":\"beijing\"}"]}'
}

AddOrg4 (){
  curl -s -X POST http://localhost:4000/channels/mychannel/chaincodes/chain -H "authorization: Bearer ${TOKEN}" -H "content-type: application/json" -d '{"fcn":"addOrg","args":["org4","{\"name\":\"zbx4\",\"certNo\":\"zbx4\",\"certDate\":\"2018-11-09\",\"legalPerson\":\"liuqingbo4\",\"email\":\"zbx4@zbxsoft.com\",\"mobile\":\"18900099889\",\"level\":\"1\",\"certValidityStart\":\"2017-11-09\",\"certValidityEnd\":\"2019-11-09\",\"province\":\"天津\"}"]}'
}


grep -Ev "#|^$" $listFile | while read portlist
do
  org=$(echo ${portlist}| awk -F ";" '{print $1}')
  Org=$(echo ${org} | sed 's/^[a-z]/\U&/')
  user=$(echo ${org} | sed 's/org/sufang/')
  TOKEN=$(curl -s -X POST http://localhost:4000/users -H "content-type: application/x-www-form-urlencoded" -d "username=${user}&orgName=${Org}" | jq .token)
  TOKEN=$(echo ${TOKEN} | sed 's/"//g')
  echo ${org} ${Org} ${TOKEN}
  case ${org} in
    ${org})  Add${Org};;
  esac
  echo -e "\n"
done

