#!/bin/bash
#Usage: tomcat_app status
# app jinfo version
#Last Modified:
#  S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT   
#  S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT  

#  S0     S1     E      O      P     YGC     YGCT    FGC    FGCT     GCT
#  S0     S1     E      O      M     CCS    YGC     YGCT    FGC    FGCT     GCT    

# 定义变量
app=$1
status=$2

function base_server (){
  # 获取运行的服务列表
  a=$(for i in `ps -fC java | tail -n +2| awk '{print $2}'`;do ls -l /proc/$i/cwd | awk '{print $NF}'|awk -F '/' '{print $4}';done | grep -Ev "^$")
  # 输出头信息
  echo "{\"data\":["
  # 输出主体信息
  count=1
  # 遍历应用列表
  for i in ${a[@]}
  do
    # 如果值有1个，直接输出
    if [ $count == 1 ];then
       echo """
      {
          \"{#APP_NAME}\":\"${i}\"
      }
            """
    # 如果值有多个，持续输出
    else
       echo """
         ,{
             \"{#APP_NAME}\":\"${i}\"
         }
            """
    fi
    # 自增数1
    count=$(expr $count + 1)
  done
  # 输出尾信息
  echo "]}"
}

function jinfo_config (){
 jinfo_file=/tmp/jinfo_${pid}.txt
 # 如果文件在10分钟之内被修改过，则不重新查看Jvm进程信息，避免多次查看影响服务性能(zabbix_server服务端采取间隔为10分钟)
 if [ $(find ${jinfo_file} -mmin -10 | wc -l) == 0 ];then
   ${envpath}/jinfo -sysprops ${pid} > ${jinfo_file}
 else
   :
 fi
}

function help (){
  app_name=${app:-app_name}
  echo -e "\e[033mUsage: $0 $app_name [S0C|S1C|S0U|S1U|EC|EU|OC|OU|YGC|YGCT|FGC|FGCT|GCT|S0|S1|E|O|uptime]\n\t\t\t\t[1.7|PC|PU|P]\n\t\t\t\t[1.8|MC|MU|CCSC|CCSU|M|CCS]\e[0m" 
  exit 1
}

function java_env (){
  check=${1}
  num=${2}
  if (echo ${envpath} | grep -c "1.7" >/dev/null);then
  # gc: PC PU
    if [ $check == gc ];then
       if [ $num == PC ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $9}' | tail -n 1
       elif [ $num == PU ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $10}' | tail -n 1
       fi
  # gcutil: P
    elif [ $check == gcutil ];then
       if [ $num == P ];then
          ${envpath}/jstat -${check} "$pid" | awk '{print $5}' | tail -n 1
       fi
    fi
  elif (echo ${envpath} | grep -c "1.8" >/dev/null);then
  # gc: MC MU CCSC CCSU
    if [ $check == gc ];then
       if [ $num == MC ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $9}'| tail -n 1
       elif [ $num == MU ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $10}' | tail -n 1
       elif [ $num == CCSC ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $11}' | tail -n 1
       elif [ $num == CCSU ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $12}' | tail -n 1
       fi
  # gcutil: M CCS
    elif [ $check == gcutil ];then
       if [ $num == M ];then
          ${envpath}/jstat -${check} "$pid" | awk '{print $5}' | tail -n 1
       elif [ $num == CCS ];then
         ${envpath}/jstat -${check} "$pid" | awk '{print $6}' | tail -n 1
       fi
    fi
  fi
}

function tatol_time (){
  # 计算进程运行时间(seconds)
  # 获取进程运行总时间
  all_time=$(ps -o etime ${pid} | grep -v ELAPSED)
  # 判断天数是否有值
  DAYS_COUNT=$(echo $all_time | grep -o "-" | wc -l) # == 1 or == 0
  # 判断小时是否有值
  HOURS_COUNT=$(echo $all_time | grep -o ":" | wc -l) # == 2 or == 1
  
  # 主要判断
  if [ $DAYS_COUNT == 1 ];then
    days=$(echo $all_time | awk -F "-" '{print $1}')
    hours=$(echo $all_time | awk -F "-" '{print $2}' |awk -F ":" '{print $1}')
    minutes=$(echo $all_time | awk -F "-" '{print $2}' |awk -F ":" '{print $2}')
    seconds=$(echo $all_time | awk -F "-" '{print $2}' |awk -F ":" '{print $3}')
  elif [ $DAYS_COUNT == 0 ];then
    days=0
    if [ $HOURS_COUNT == 2 ];then
       hours=$(echo $all_time | awk -F ":" '{print $1}')
       minutes=$(echo $all_time | awk -F ":" '{print $2}')
       seconds=$(echo $all_time | awk -F ":" '{print $3}')
    elif [ $HOURS_COUNT == 1 ];then
       hours=0
       minutes=$(echo $all_time | awk -F ":" '{print $1}')
       seconds=$(echo $all_time | awk -F ":" '{print $2}')
    fi
  fi
  
  # 输出进程启动总时间(s)
  TOTAL_TIME=$(expr $days \* 86400 + $hours \* 3600 + $minutes \* 60 + $seconds)
  echo ${TOTAL_TIME}
}

# 判断是否传参数
if [ -z $app ];then
  base_server
  exit
elif [ $app == h -o $app == help ];then
  help
fi

pid=$(ps -fC java | tail -n +2| grep "${app}/conf" | grep -v "$0"| awk '{print $2}')
envpath=$(dirname $(ps -fC java | tail -n +2  | grep "$app/conf" | grep -v "$0" | awk '{print $8}'))
envpath=$(echo $envpath | sed 's/jre\///g')

case $status in
# -gc (KB)
#  S0C    S1C    S0U    S1U      EC       EU        OC         OU       PC     PU    YGC     YGCT    FGC    FGCT     GCT   
#  S0C    S1C    S0U    S1U      EC       EU        OC         OU       MC     MU    CCSC   CCSU   YGC     YGCT    FGC    FGCT     GCT  
    # 当前幸存者空间0容量(KB)
    S0C)
        ${envpath}/jstat -gc "$pid" | awk '{print $1}' | tail -n 1
        ;;
    # 当前幸存者空间1容量(kB)
    S1C)
        ${envpath}/jstat -gc "$pid" | awk '{print $2}' | tail -n 1
        ;;
    # 幸存者空间0利用率(kB)
    S0U)
        ${envpath}/jstat -gc "$pid" | awk '{print $3}' | tail -n 1
        ;;
    # 幸存者空间1利用率(kB)
    S1U)
        ${envpath}/jstat -gc "$pid" | awk '{print $4}' | tail -n 1
        ;;
    # 当前的伊甸园空间容量(kB)
    EC)
        ${envpath}/jstat -gc "$pid" | awk '{print $5}' | tail -n 1
        ;;
    # 当前的伊甸园空间利用率(kB)
    EU)
        ${envpath}/jstat -gc "$pid" | awk '{print $6}' | tail -n 1
        ;;
    # 当前旧空间容量(kB)
    OC)
        ${envpath}/jstat -gc "$pid" | awk '{print $7}' | tail -n 1
        ;;
    # 当前旧空间利用率(kB)
    OU)
        ${envpath}/jstat -gc "$pid" | awk '{print $8}' | tail -n 1
        ;;
####
    # 1.7
    # 当前永久空间容量(KB)
    PC)
        java_env gc PC
        ;;
    # 当前永久空间利用率(KB)
    PU)
        java_env gc PU
        ;;
    # 1.8
    # 元空间容量(KB)
    MC)
        java_env gc MC
        ;;
    # 元空间利用率(KB)
    MU)
        java_env gc MU
        ;;
    # 压缩类空间容量(KB)
    CCSC)
        java_env gc CCSC
        ;;
    # 压缩类利用率(KB)
    CCSU)
        java_env gc CCSU
        ;;
####
    # 垃圾收集总时间
    GCT)
        ${envpath}/jstat -gc "$pid" | awk '{print $NF}' | tail -n 1
        ;;
    # 完整垃圾收集时间
    FGCT)
        ${envpath}/jstat -gc "$pid" | awk '{print $(NF-1)}' | tail -n 1
        ;;
    # 完整GC事件的数量
    FGC)
        ${envpath}/jstat -gc "$pid" | awk '{print $(NF-2)}' | tail -n 1
        ;;
    # 新生代垃圾收集时间
    YGCT)
        ${envpath}/jstat -gc "$pid" | awk '{print $(NF-3)}' | tail -n 1
        ;;
    # 新生代垃圾收集活动的数量
    YGC)
        ${envpath}/jstat -gc "$pid" | awk '{print $(NF-4)}' | tail -n 1
        ;;

# -gcutil (%)
#  S0     S1     E      O      P     5
#  S0     S1     E      O      M     CCS     5 6
    # 幸存者空间0利用率占空间当前容量的百分比
    S0)
        ${envpath}/jstat -gcutil "$pid" | awk '{print $1}' | tail -n 1
        ;;
    # 幸存者空间1利用率占空间当前容量的百分比
    S1)
        ${envpath}/jstat -gcutil "$pid" | awk '{print $2}' | tail -n 1
        ;;
    # 伊甸园空间利用率占空间当前容量的百分比
    E)
        ${envpath}/jstat -gcutil "$pid" | awk '{print $3}' | tail -n 1
        ;;
    # 老生代利用率占空间当前容量的百分比
    O)
        ${envpath}/jstat -gcutil "$pid" | awk '{print $4}' | tail -n 1
        ;;
####
    # 1.7
    # 永久空间利用率占空间当前容量的百分比
    P)
        java_env gcutil P
        ;;
    # 1.8
    # 元空间利用率占空间当前容量的百分比
    M)
        java_env gcutil M
        ;;
    # 压缩的类空间利用率百分比
    CCS)
        java_env gcutil CCS
        ;;
####
    # time
    uptime)
        tatol_time
        ;;
    java_version)
        jinfo_config
        java_version=$(cat ${jinfo_file} | grep -w "java.version" | awk -F " = " '{print $2}')
        echo ${java_version}
        ;;
    class_version)
        jinfo_config
        class_version=$(cat ${jinfo_file} | grep -w "java.class.version" | awk -F " = " '{print $2}')
        echo ${class_version}
        ;;
    vm_version)
        jinfo_config
        vm_version=$(cat ${jinfo_file} | grep -w "java.vm.version" | awk -F " = " '{print $2}')
        echo ${vm_version}
        ;;
###
    *)
	help
        ;;
esac

