###初始化couchdb
listFile=./orgList

grep -Ev "#|^$" $listFile | while read portlist
do
  port1=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $1}' | awk -F ',' '{print $1}'`
  port2=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $1}' | awk -F ',' '{print $2}'`
  passw=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $2}'`
  echo $port1 $port2 $passw
  if [ ${port1} == 7981 ];then
          curl -XPUT http://localhost:$port1/mychannel_chain/_design/contractView  -H "content-type: application/json" -d '{"_id":"_design/contractView","views":{"ranking":{"reduce":"_stats","map":"function (doc) {\r\n  if(doc.docType=='contract' && (doc.status=='released' || doc.status=='closed') ){\r\n    emit(doc.createOrg, parseFloat(doc.contractAmount));\r\n  }\r\n}"}},"language":"javascript"}'
  else
          curl -XPUT http://admin:${passw}@localhost:$port1/mychannel_chain/_design/contractView  -H "content-type: application/json" -d '{"_id":"_design/contractView","views":{"ranking":{"reduce":"_stats","map":"function (doc) {\r\n  if(doc.docType=='contract' && (doc.status=='released' || doc.status=='closed') ){\r\n    emit(doc.createOrg, parseFloat(doc.contractAmount));\r\n  }\r\n}"}},"language":"javascript"}'
  fi
  exit
# curl -XPUT http://admin:admin@172.30.1.31:7981/xx/_design/contractView  -H "content-type: application/json" -d '{"_id":"_design/contractView","views":{"ranking":{"reduce":"_stats","map":"function (doc) {\r\n  if(doc.docType=='contract' && (doc.status=='released' || doc.status=='closed') ){\r\n    emit(doc.createOrg, parseFloat(doc.contractAmount));\r\n  }\r\n}"}},"language":"javascript"}'

done

