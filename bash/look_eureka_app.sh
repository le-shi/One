#!/bin/bash
# command; registory server
for ID in $(curl -s -XGET -H 'Accept:application/json' localhost:8761/eureka/apps/ | jq .applications.application[].name)
do
  ID=$(echo ${ID} | sed 's/"//g')
  STATUS=$(curl -s -XGET -H 'Accept:application/json' localhost:8761/eureka/apps/${ID} | jq .application.instance[].status | tr "\n" "," | sed 's/,$//g')
  PageUrl=$(curl -s -XGET -H 'Accept:application/json' localhost:8761/eureka/apps/${ID} | jq .application.instance[].homePageUrl | tr "\n" "," | sed 's/,$//g')
  echo -e "ID: \"${ID}\"\t\tSTATUS: ${STATUS}\t\tPageUrl: ${PageUrl}"
  let i+=1
done
echo "Count: $i"
