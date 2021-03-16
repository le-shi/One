# 背景

低代码平台集成了版本管理工具和持续集成工具，为了增强兼容性，所以也拥抱了不那么流行的subversion(下面简称svn)。原来在jenkins上面的svn任务是通过`轮询 SCM`方式进行的，无可厚非，会造成jenkins压力过大，我发现jenkins卡的时候scm相关的job已经有**90**个了。

## 准备工作

- 提前准备服务: svn，jenkins。这里不会讲怎么安装
- 概念:
  - `轮询 SCM`: 是jenkins插件`subversion`带的一个功能(应该是带的)，意思是配置Jenkins以轮询SCM中的更改，[官网wiki](<https://wiki.jenkins.io/display/JENKINS/Building+a+software+project>)这说到了VCS的解决方法，但是没有说svn的
  - `svn hook`: 利用这些钩子, 管理员可以在 特定操作的特定时间点扩展 Subversion 的功能. 仓库钩子被实现成由 Subversion 在特定时间点执行的程序, 这些时间点包括在提交之前或之后, 用户锁定文件之前或之后, 等等. [Subversion 仓库钩子参考手册](<http://svnbook.red-bean.com/en/1.8/svn.ref.reposhooks.html>)
    - `hook`说明

        类型 | 触发时机 | 常见用途 | 备注
        -|-|-|-
        start-commit | 提交事务生成之前 | 一般可根据用户名对提交进行权限控制，一般多用于对svn版本功能check的检查 | 参数个数为2，svn 1.5为3个
        pre-commit | 事务已生成，但是尚未提交 | 可可根据提交的内容或者comment进行控制，比如提交日志不能为空 | -
        post-commit | 提交之后 | 数据进行备份，以及修改提示的mail操作，或者驱动自动构建 | -
        pre-revprop-change | 属性变更前，尚未变化 | 可以进行属性变更权限的控制 | -
        post-revprop-change | 属性变更前 | 进行版本属性的备份以及mail通知操作等 | -
        pre-lock | 加锁之前 | 可进行是否能加锁的控制 | -
        post-lock | 加锁之后 | 可进行mail通知，使开发成员了解此文件已经加锁 | 往往有时结合特定流程，比如有提交冻结期的结束，可结合这个属性进行使用
        pre-unlock | 解锁前 | 可进行是否能解锁的控制 | -
        post-unlock | 解锁之后 | 可进行mail通知，使开发成员了解此文件已经解锁 | 往往有时结合特定流程，比如有提交冻结期的结束，可结合这个属性进行使用

    - `hook`参数

        类型 | 参数1 | 参数2 | 参数3 | 参数4 | 参数5
        -|-|-|-|-|-
        start-commit | 代码库路径 | 用户名 | - | - | -
        pre-commit | 代码库路径 | 事务名 | - | - | -
        post-commit | 代码库路径 | 版本号 | 事务名 | - | -
        pre-revprop-change | 代码库路径 | 版本号 | 用户名 | 属性名 | ACTION
        post-revprop-change | 代码库路径 | 版本号 | 用户名 | 属性名 | ACTION
        pre-lock | 代码库路径 | 路径 | 用户名 | Comment | STEAL(1
        post-lock | 代码库路径 | 用户名 | - | - | -
        pre-unlock | 代码库路径 | 路径 | 用户名 | TOKEN | BREAK-UNLOCK(1
        post-unlock | 代码库路径 | 用户名 | - | - | -

## 开始

### svn服务端: 设置hook post-commit

1. 配置`post-commit`，确保文件名和hook名一致，确保有执行权限

    ```sh
    # cat post-commit

    #!/bin/sh
    # POST-COMMIT HOOK
    # following ordered arguments:
    #
    #   [1] REPOS-PATH   (the path to this repository)
    #   [2] REV          (the number of the revision just committed)
    #
    REPOS="$1"
    REV="$2"

    echo "log: $REPOS $REV" >> /tmp/hook.log
    ```

2. svn提交后确定`post-commit`执行

    ```sh
    #> 在client端执行
    svn ci -m 'test post-commit run'

    #> 正server端执行
    # cat /tmp/hook.log

    log: 仓库路径 当前版本号
    ```

3. 很棒: hook `post-commit` 成功执行。(我提交，它执行了)

### jenkins的job: 设置构建触发器

1. 打开jenkins的job配置
   - 找到 **构建触发器** 栏目
     - [勾上] **触发远程构建(例如,使用脚本)**
       - 身份验证令牌，输入令牌 **xyz**
   - 应用-保存
2. 调用
   - 命令行: `curl http://jenkins-ip/job/job-name/build?token=xyz`
   - 浏览器: 直接访问
3. 可以看到jenkins界面上`job-name`新触发的执行任务
   - 观察执行任务详情
     - 状态集，会显示 **由远程主机 xx.xx.xx.xx 启动**
4. 很棒: jenkins-job的触发器成功执行。(我请求，它执行了)

### 衔接起来SVN和Jenkins

1. 目标: 让开发人员提交代码后，自动进行代码的构建(不需要人工干预)
2. 再svn hook配置 `post-commit`，添加上面 `命令行` 执行的语句，然后处理一下项目名

    ```sh
    # cat post-commit

    #!/bin/sh
    # POST-COMMIT HOOK
    # following ordered arguments:
    #
    #   [1] REPOS-PATH   (the path to this repository)
    #   [2] REV          (the number of the revision just committed)
    #
    REPOS="$1"
    REV="$2"
    # 截取当前项目名
    JOB_NAME=$(basename ${REPOS})

    curl http://jenkins-ip/job/${JOB_NAME}/build?token=xyz
    ```

3. svn再提交一次，可以看到jenkins上面多了一条 **有远程机器 SVN_ADDR 启动** 的构建任务

### 项目多了怎么办?

- 要保证jenkins-job的命名有统一的规则；job的触发器token，可以所有项目用同样的，也可以跟job-name相同，但是一定要有规则，不然svn的`post-commit`就要写复杂的逻辑进行处理。内网嘛，安全性可以放在易用、易维护后面
- 要保证svn的项目都是单独的仓库，这样脚本截取项目名的时候才可以取得到，因为变量`${REPOS}`的值是仓库的路径，不包含下面的文件路径。
- 通过模板创建的Job统一设定触发器token的值
- 剩下的交给`post-commit`
- 黄金法则: 每个项目有单独的svn仓库-项目名和jenkins-job名字一致-模板化
