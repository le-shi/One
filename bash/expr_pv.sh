#!/bin/bash
 
####获取输入
read -p "请输入日志名称: " log_name
####判断日志是否存在
if [[ -e $log_name ]];then
   echo "开始检查文件: $log_name"
else
   echo "文件不存在，请检查输入的路径."
   exit
fi
####将日志进行统计，每秒钟的请求数
cat ./$log_name | cut -d '"' -f4 | uniq -c | sort -n -r -o ./temp_sorted.log
###定义一天的pv，初始值为0 
all_pv=0
###循环24小时，一天
for hour in `seq 0 23`
do
#定义每分钟的pv
min_all_pv=0
#判断是不是0-9，如果是需要手动加0
if (( $hour <= 9 ));then
	#循环每一分钟
	for minute in `seq 0 59`
	do
           ##判断是不是前9分钟，如果是，需要手动加0
	   if (( $minute <= 9 ));then
		###将每分钟的请求数相加
		min_sum_pv=`cat temp_sorted.log |grep "0$hour:0$minute:"|awk '{sum += $1}END{print sum}'`
		#可以查看每分钟的请求数是多少
   		#echo "0$hour:0$minute的请求数是:   $min_sum_pv"
  	   ##不是前9分钟，不需要加0
	   else
		min_sum_pv=`cat temp_sorted.log |grep "0$hour:$minute:"|awk '{sum += $1}END{print sum}'`
		#echo "0$hour:$minute的请求数是:   $min_sum_pv"
 	  fi
	   min_all_pv=`expr $min_sum_pv + $min_all_pv`
	done
	#输出空行，可以有效的分隔出每小时的总pv
        #echo -e "\n"
	echo "0$hour时的总请求数是: $min_all_pv"
	all_pv=`expr $min_all_pv + $all_pv`
	#echo -e "\n"
else
        for minute in `seq 0 59`
        do
           if (( $minute <= 9 ));then
                min_sum_pv=`cat temp_sorted.log |grep "$hour:0$minute:"|awk '{sum += $1}END{print sum}'`
                #echo "$hour:0$minute的请求数是:   $min_sum_pv"
           else 
                min_sum_pv=`cat temp_sorted.log |grep "$hour:$minute:"|awk '{sum += $1}END{print sum}'`
                #echo "$hour:$minute的请求数是:   $min_sum_pv"
          fi
           min_all_pv=`expr $min_sum_pv + $min_all_pv`
        done
        #echo -e "\n"
        echo "$hour时的总请求数是: $min_all_pv"
	all_pv=`expr $min_all_pv + $all_pv`
        #echo -e "\n"
fi
done
echo "总pv是: $all_pv"
rm -f ./temp_sorted.log