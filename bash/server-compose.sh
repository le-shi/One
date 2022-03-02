#!/bin/bash

# 第一个参数
i=${1}
# 参数左移，剔除第一个参数
shift
# 所有参数，上面有一次shift操作，表示从第二个参数开始到最后一个参数作为所有参数
j=${*}

# 打印帮助信息
help (){
  echo """Usage: $0 ACTION NAME
  
  ACTION:
    restart
    restart_all
    logs

  NAME:
    \`docker-compose ps --services\` or \`docker container ls --format "{{.Names}}"\`
"""
}

# 执行相关操作：单个多个服务的查看日志，重启；所有服务的重启
main_runner (){
  case $i in
    restart) 
      docker-compose restart $j
    ;;
    restart_all) 
      docker-compose down
      docker-compose up
    ;;
    logs)
      docker-compose logs -f --tail 20 $j
    ;;
    *)
      help
    ;;
  esac
}

# 打印辅助信息
echo -e "action: [$i] \nserver name: [$j]"
# 运行主方法
main_runner