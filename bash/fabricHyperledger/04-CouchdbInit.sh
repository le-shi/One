###初始化couchdb
listFile=./orgList

grep -Ev "#|^$" $listFile | while read portlist
do
  port1=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $1}' | awk -F ',' '{print $1}'`
  port2=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $1}' | awk -F ',' '{print $2}'`
  passw=`echo $portlist | awk '{print $4}' | awk -F ';' '{print $2}'`
  echo $port1 $port2 $passw
  # if [ ${port1} == 7981 ];then
	#   curl -X POST http://admin:$passw@localhost:$port1/mychannel_chain/_index -H "content-type: application/json" -d '{"index": {"fields": [ {"createTime": "desc"}]},"name":"createTime","type": "json"}'
	#   # curl -X POST http://localhost:$port1/mychannel_chain/_index -H "content-type: application/json" -d '{"index": {"fields": [ {"createTime": "desc"}]},"name":"createTime","type": "json"}'
  # else
	#   curl -X POST http://admin:$passw@localhost:$port1/mychannel_chain/_index -H "content-type: application/json" -d '{"index": {"fields": [ {"createTime": "desc"}]},"name":"createTime","type": "json"}'
  # fi
  curl -X POST http://admin:$passw@localhost:$port1/mychannel_chain/_index -H "content-type: application/json" -d '{"index": {"fields": [ {"createTime": "desc"}]},"name":"createTime","type": "json"}'
  curl -X POST http://admin:$passw@localhost:$port2/mychannel_chain/_index -H "content-type: application/json" -d '{"index": {"fields": [ {"createTime": "desc"}]},"name":"createTime","type": "json"}'
done

