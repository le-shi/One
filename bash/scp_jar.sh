#!/bin/bash
# Java|Maven|SpringBoot|SpringCloud - 上传制品(jar,war)到制品库
# 执行目录是 pom.xml 文件所在的目录
# 使用rsync方式上传制品，需要提前做好免密认证

set -e

# 定义制品类型
export type_list=(jar war)

# 判断制品目录
if [[ -d target ]]
then
    cd target
    # 遍历制品类型
    for pe in ${type_list[@]}
    do
        echo -n "[SCP_JAR]: ${pe}"
        # 获取制品名称
        archive_name=$(ls -1 *.${pe} 2>/dev/null | tail -n 1)
        # 校验是否存在对应类型的制品
        if [[ -f ${archive_name} ]]
        then
            echo " OK."
            # 计算md5，用于校验下载后的文件完整性
            md5sum ${archive_name} > ${archive_name}.md5
            set -x
            # 上传到update制品库
            rsync -az ${archive_name}{,.md5} root@192.168.9.202:/mnt/update_file/update/
            set +x
        else
            echo " Null."
        fi
    done
fi
