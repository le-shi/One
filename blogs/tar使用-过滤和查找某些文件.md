# tar使用-过滤和查找某些文件

项目动静分离，服务和页面都用到了版本控制，服务使用容器化进行管理，静态页面需要单独打包处理(提交了代码，直接rsync到运行环境也不太合适)，检出打包上传解压就可以完成更新操作，但是架不住服务多、更新频繁，所以用了jenkins来做自动化打包这件事。

但是打包过程中，可能会有开发提交一些(不干净的)文件，比如.idea,.project,xx.iml什么的，代码检出时还有.svn信息，这时候就要在打包好的tar.gz之前，过滤掉(不想要的).开头的文件或目录

jenkins操作流程:

1. 源码管理，分别配置了每个服务页面的地址和检出目录(虽然麻烦，但是可以保护版本库的账号和密码；检出用户不用担心，需要一个所有项目的只读用户)
2. 构建触发器，因为用的是svn的同一个代码库，所有目录共享版本号，就用了"轮询SCM" `H/2 * * * *` 每两分钟检查一次版本库，有变化会触发构建操作(虽然每个服务使用单独的代码库比较优雅，已经这样了，改动的工作量也比较大[就是懒])
3. 构建，执行shell

    ```bash
    # 获取当前路径
    DIRPATH=$(pwd)
    # 获取所有的服务页面
    LIST=$(ls new/)

    # 遍历所有服务页面
    for ENV in ${LIST[@]}; do
    # 切换到单个服务页面目录
    cd ${DIRPATH}/new/${ENV}
    # 写入版本文件，作用是在更新后，可以通过看version文件确认更新的版本时间
    echo "$(date +%FT%H-%M-%S.%N)" > ${ENV}/VERSION
    # 将页面打包，--exclude过滤掉不需要发布的文件或目录，会有一些以.开头的目录或文件不想跟页面文件一起打包，所以在打包过程中，将这些文件过滤掉
    tar -zcf ${ENV}.tar.gz  --exclude=*.svn --exclude=*.idea --exclude=*.project --exclude=*.editorconfig ${ENV}
    # 打包后，同步到远程文件服务器或者oss
    rsync -avz --delete --chmod=755 ${ENV}.tar.gz file.update.com:/mnt/update_file/
    done
    ```

4. 构建后操作，触发通知任务，通知相关人

5. 回归正题，如何才能确保打包好的tar.gz中，不会包含.开头的文件或目录呢；通过下面的命令进行查询，有的话，整理到过滤规则中，当然如果想查询其他关键字，可以替换掉grep的表达式或者启用-E(--extended-regexp)可扩展的正则表达式同时查询多个条件

    ```bash
    # tar命令 -f 使用归档文件或 ARCHIVE 设备  -t 列出归档内容；这样可以看到tar中的文件列表，再以.开头过滤就可以查到啦
    for tar in $(ls *.tar.gz)
    do
    echo $tar
    tar tf $tar | grep "/\."
    # 启用-E(--extended-regexp)可扩展的正则表达式同时查询多个条件
    # tar tf $tar | grep -E "/\.|error"
    echo '---'
    done
    ```
