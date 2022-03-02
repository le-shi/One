#!/bin/bash

# 功能: 通过查询制品存放目录下的文件-jar，过滤出最新的版本(有版本号)，软链接到单独的目录，方便相关人员查看和下载
# 使用: 手动执行，定时任务执行

# 定义制品的存放目录
products_root_dir=/mnt/update_file/update
# 定义最新版(有版本号)制品的目录名称
pro_stable_dir=latest_stable

if [[ ! -d ${products_root_dir} ]]
then
    echo "products_root_dir: [${products_root_dir}] does not exist."
    exit 1
else
    cd ${products_root_dir}
    mkdir -pv ${pro_stable_dir}
    echo '通过查询制品存放目录下的文件-jar，过滤出最新的版本(有版本号)，链接到单独的目录，方便相关人员查看和下载' > ${pro_stable_dir}/README.TXT
fi

# 定义要查询的服务，组成列表
jar_list=$(ls -1 | grep jar | sort | awk -F '-' '{print $1}' | uniq)

# # 查看每个服务的最新版
for jar_name in ${jar_list[@]};
do
  rm -f ${pro_stable_dir}/${jar_name}-*.jar 
  ls -av ${jar_name}-*.jar | grep -Ev 'SNAPSHOT|latest|arm|stable' | grep 'jar' | tail -n 1 | xargs -I {} ln -s ../{} ${pro_stable_dir}/
done
