# [Gitlab + Jenkins + Pipeline + WebHook+ Multibranch] - 实现持续集成和自动发布
本文的实现：
+ 代码提交gitlab，自动触发Jenkins构建
+ gitlab开发分支merge后自动发布到dev环境
+ gitlab master分支merge后自动构建，需手动更新prod环境
---
1. [Jenkins准备工作](#Jenkins准备工作)
1. [Jenkinsfile准备工作](#Jenkinsfile准备工作)
1. [Gitlab准备工作](#Gitlab准备工作)
1. [选择Jenkins任务的触发方式](#选择Jenkins任务的触发方式)
1. [验证](#验证)

## Jenkins准备工作
+ 安装插件
 1. `gitlab`
 1. `pipeline`
+ 配置Gitlab的连接
 1. 打开`系统管理 - 系统设置 - gitlab`
 1. 去掉此选项的勾选`Enable authentication for '/project' end-point`
 1. 配置GitLab connections
   1. 设置`Connection name`和`Gitlab host URL`
   1. Credentials的配置
       1. 添加Jenkins凭据
       1. 类型选择`Gitlab API token`
       1. API token的获取
           1. 在Gitlab上拥有一个用户并具有developer角色
           1. 获取方法：`登录用户 - User settings - Access Tokens`,创建一个Token记录
       1. 复制Token值并保存到Jenkins的凭据中
       1. 点击下面的`Test Connection`测试
           1. 成功会提示`Success`
           1. 如果失败检查gitlab的url地址是否正确
+ 配置多分支流水线任务
1. 新建任务，选择`多分支流水线`
1. 配置任务
   1. 添加一个仓库，类型选`Git`
   1. Credentials的配置
      1. 添加Jenkins凭据
      1. 类型选择`Username with Password`
      1. 用户的获取
         1. 在Gitlab上拥有一个用户并具有developer角色
         1. 如果你的项目类型属于`Private`，这个用户必须是这个项目的成员
   1. 行为
       - 发现分支
       - 发现标签
   1. Property strategy
       - 所有分支获取同样的属性
   1. Build strategies
       1. 新增: `Any Strategies Match`
           1. 新增: 
               1. `Change requests`
               1. `Tags`
               1. `Regular branches`
   1. 其他默认读取根目录下的Jenkinsfile文件

## Jenkinsfile准备工作
[参考 Jenkinsfile Demo](https://github.com/mainiubaba/code-quality-verify-demo/blob/master/Jenkinsfile)

主要配置：
```
// 获取gitlab connection, 填写我们之前配置gitlab connection
properties([gitLabConnection('gitlab-bigdata')])
// 拉取代码
checkout scm
// 告诉gitlab job状态
updateGitlabCommitStatus name: 'build', state: 'pending'
// 根据不同的分支触发不同的步骤
if (env.BRANCH_NAME == 'master' || env.BRANCH_NAME == 'dev' ) {
        stage("Build Docker Image"){
            echo "build docker image"
            echo "Only dev/master branch can build docker image"
        }

        if(env.BRANCH_NAME == 'dev'){
            stage("Deploy to test"){
                echo "branch dev to deploy to environment test"
            }

            stage("Integration test"){
                echo "test环境集成测试"
            }

        }

        if(env.BRANCH_NAME == 'master'){
            stage("Deploy to prod"){
                echo "branch master to deploy to environment prod"
            }

            stage("Health check"){
                echo "prod检查"
            }

        }
    }
```

## Gitlab准备工作
+ 修改默认的安全请求
  0. 注意： 当Jenkins和Gitlab在同一台机器时
  1. 使用root登录，`管理中心 - 设置 - 网络 - 外发请求(Admin Area - settings - Network - Outbound requests)`
  1. 加上此选项的勾选`Allow requests to the local network from hooks and services`， 保存

## 选择Jenkins任务的触发方式
+ 手动触发
+ 定时触发
+ Gitlab trigger
  1. 进入项目，`Settings - Integrations`
  1. 填写Jenkins任务的地址，选中`Push events`和`Merge request events`
  1. Jenkins url格式：`http://JENKINS_URL/project/PROJECT_NAME`

    ```
    When you configure the plugin to trigger your Jenkins job, by following the instructions below depending on job type, it will listen on a dedicated URL for JSON POSTs from GitLab's webhooks. That URL always takes the form http://JENKINS_URL/project/PROJECT_NAME, or http://JENKINS_URL/project/FOLDER/PROJECT_NAME if the project is inside a folder in Jenkins. You should not be using http://JENKINS_URL/job/PROJECT_NAME/build or http://JENKINS_URL/job/gitlab-plugin/buildWithParameters, as this will bypass the plugin completely.
    ```  

## 验证
1. 提交代码
1. 查看状态 - 进入项目
    1. WebHook状态
      1. 依次点击`Settings - Integrations`
      1. 编辑触发Jenkins的那条记录
      1. 查看`Recent Deliveries`部分，显示了最近的Trigger状态
    1. Pipelines状态
    1. Jenkins Job状态
1. 成功状态
    1. WebHook状态 - `200`
    1. Pipelines状态 - `passed`
    1. Jenkins Job状态 - `成功`


## 感谢
+ [CI/CD之Gitlab集成Jenkins多分支pipeline实现质量检测和自动发布](https://www.centos.bz/2019/06/ci-cd%E4%B9%8Bgitlab%E9%9B%86%E6%88%90jenkins%E5%A4%9A%E5%88%86%E6%94%AFpipeline%E5%AE%9E%E7%8E%B0%E8%B4%A8%E9%87%8F%E6%A3%80%E6%B5%8B%E5%92%8C%E8%87%AA%E5%8A%A8%E5%8F%91%E5%B8%83/)
