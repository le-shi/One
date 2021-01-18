#!/bin/bash
eureka_addr=localhost
eureka_port=8761
# command; registory server
for ID in $(curl -s -XGET -H 'Accept:application/json' http://${eureka_addr}:${eureka_port}/eureka/apps/ | jq .applications.application[].name)
do
  ID=$(echo ${ID} | sed 's/"//g')
  STATUS=$(curl -s -XGET -H 'Accept:application/json' http://${eureka_addr}:${eureka_port}/eureka/apps/${ID} | jq .application.instance[].status | tr "\n" "," | sed 's/,$//g')
  PageUrl=$(curl -s -XGET -H 'Accept:application/json' http://${eureka_addr}:${eureka_port}/eureka/apps/${ID} | jq .application.instance[].homePageUrl | tr "\n" "," | sed 's/,$//g')
  echo -e "ID: \"${ID}\"\t\tSTATUS: ${STATUS}\t\tPageUrl: ${PageUrl}"
  let i+=1
done
echo "Count: $i"