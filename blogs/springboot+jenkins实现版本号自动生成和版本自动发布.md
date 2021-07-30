springboot+jenkins实现版本号自动生成和版本自动发布

用到的: springboot项目,jenkins,mvn,svn,docker,harbor,自定义shell脚本,文件服务器

1. 使用mvn管理springboot的版本和依赖
2. jenkins添加svn凭证，安装插件`parameterized-trigger`，做好文件服务器的单向ssh免密
3. 生成的制品会有: jar包,war包,tar(docker离线镜像),docker镜像(harbor)的格式 war可以参考 [springboot支持war并且同时支持jar和war.md](https://gitee.com/Roles_le/One/blob/main/blogs/springboot支持war并且同时支持jar和war.md)
4. 创建生成版本job，取名 `build_baseline_boot` ，是参数化job，需要传入 [项目名-版本号-构建人]，默认情况下自动触发发布版本的job进行构建并传入当前job的参数

```xml
<?xml version="1.1" encoding="UTF-8" standalone="no"?>
<project>
    <actions/>
    <description/>
    <keepDependencies>false</keepDependencies>
    <properties>
        <jenkins.model.BuildDiscarderProperty>
            <strategy class="hudson.tasks.LogRotator">
                <daysToKeep>1</daysToKeep>
                <numToKeep>1</numToKeep>
                <artifactDaysToKeep>3</artifactDaysToKeep>
                <artifactNumToKeep>3</artifactNumToKeep>
            </strategy>
        </jenkins.model.BuildDiscarderProperty>
        <org.jenkinsci.plugins.mavenrepocleaner.MavenRepoCleanerProperty plugin="maven-repo-cleaner@1.2">
            <notOnThisProject>false</notOnThisProject>
        </org.jenkinsci.plugins.mavenrepocleaner.MavenRepoCleanerProperty>
        <com.sonyericsson.rebuild.RebuildSettings plugin="rebuild@1.32">
            <autoRebuild>false</autoRebuild>
            <rebuildDisabled>false</rebuildDisabled>
        </com.sonyericsson.rebuild.RebuildSettings>
        <hudson.model.ParametersDefinitionProperty>
            <parameterDefinitions>
                <hudson.model.StringParameterDefinition>
                    <name>service_name</name>
                    <description>服务名</description>
                    <defaultValue/>
                    <trim>true</trim>
                </hudson.model.StringParameterDefinition>
                <hudson.model.StringParameterDefinition>
                    <name>service_version</name>
                    <description>服务版本</description>
                    <defaultValue/>
                    <trim>true</trim>
                </hudson.model.StringParameterDefinition>
                <hudson.model.StringParameterDefinition>
                    <name>commit_user</name>
                    <description>提交人</description>
                    <defaultValue/>
                    <trim>true</trim>
                </hudson.model.StringParameterDefinition>
            </parameterDefinitions>
        </hudson.model.ParametersDefinitionProperty>

    </properties>
    <scm class="hudson.scm.SubversionSCM" plugin="subversion@2.13.1">
        <locations>
            <hudson.scm.SubversionSCM_-ModuleLocation>
                <remote>http://dev.code.com:8011/code/${service_name}/boot@HEAD</remote>
                <credentialsId>2</credentialsId>
                <local>.</local>
                <depthOption>infinity</depthOption>
                <ignoreExternalsOption>true</ignoreExternalsOption>
                <cancelProcessOnExternalsFail>true</cancelProcessOnExternalsFail>
            </hudson.scm.SubversionSCM_-ModuleLocation>
        </locations>
        <excludedRegions/>
        <includedRegions/>
        <excludedUsers/>
        <excludedRevprop/>
        <excludedCommitMessages/>
        <workspaceUpdater class="hudson.scm.subversion.UpdateUpdater"/>
        <ignoreDirPropChanges>false</ignoreDirPropChanges>
        <filterChangelog>false</filterChangelog>
        <quietOperation>true</quietOperation>
    </scm>
    <canRoam>true</canRoam>
    <disabled>false</disabled>
    <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
    <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
    <triggers/>
    <concurrentBuild>false</concurrentBuild>
    <builders>
        <hudson.plugins.descriptionsetter.DescriptionSetterBuilder plugin="description-setter@1.10">
            <regexp/>
            <description>服务: ${service_name} 版本: ${service_version} 提交人: ${commit_user}</description>
        </hudson.plugins.descriptionsetter.DescriptionSetterBuilder>
        <hudson.tasks.Shell>
            <command># 设置boot的版本和当前设置的版本一致
/usr/local/maven3.5.4/bin/mvn versions:set -DgenerateBackupPoms=false -DnewVersion=${service_version}</command>
            <configuredLocalRules/>
        </hudson.tasks.Shell>
        <hudson.tasks.Shell>
            <command># 消除配置文件中的真实IP配置
sed -i 's/^eureka.instance.ip-address=/#eureka.instance.ip-address=/g' src/main/resources/application.properties</command>
            <configuredLocalRules/>
        </hudson.tasks.Shell>
        <hudson.tasks.Shell>
            <command>svn import . http://dev.code.com:8011/code_baseline/${service_name}/boot_${service_version} -m "[$(date +%FT%H-%M-%S.%N)] 服务: ${service_name} 版本: ${service_version} 提交人: ${commit_user}"</command>
            <configuredLocalRules/>
        </hudson.tasks.Shell>
    </builders>
    <publishers>
        <hudson.plugins.parameterizedtrigger.BuildTrigger plugin="parameterized-trigger@2.39">
            <configs>
                <hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
                    <configs>
                        <hudson.plugins.parameterizedtrigger.CurrentBuildParameters/>
                    </configs>
                    <projects>build_boot</projects>
                    <condition>SUCCESS</condition>
                    <triggerWithNoParameters>false</triggerWithNoParameters>
                    <triggerFromChildProjects>false</triggerFromChildProjects>
                </hudson.plugins.parameterizedtrigger.BuildTriggerConfig>
            </configs>
        </hudson.plugins.parameterizedtrigger.BuildTrigger>
    </publishers>
    <buildWrappers>
        <hudson.plugins.ws__cleanup.PreBuildCleanup plugin="ws-cleanup@0.38">
            <deleteDirs>false</deleteDirs>
            <cleanupParameter/>
            <externalDelete/>
            <disableDeferredWipeout>false</disableDeferredWipeout>
        </hudson.plugins.ws__cleanup.PreBuildCleanup>
        <org.jenkinsci.plugins.builduser.BuildUser plugin="build-user-vars-plugin@1.7"/>
    </buildWrappers>
</project>
```

4. 发布版本job，取名 `build_boot` ，是参数化job，和生成版本的job保持一致

```xml
<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description></description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.mavenrepocleaner.MavenRepoCleanerProperty plugin="maven-repo-cleaner@1.2">
      <notOnThisProject>false</notOnThisProject>
    </org.jenkinsci.plugins.mavenrepocleaner.MavenRepoCleanerProperty>
    <com.sonyericsson.rebuild.RebuildSettings plugin="rebuild@1.32">
      <autoRebuild>false</autoRebuild>
      <rebuildDisabled>false</rebuildDisabled>
    </com.sonyericsson.rebuild.RebuildSettings>
    <hudson.model.ParametersDefinitionProperty>
      <parameterDefinitions>
        <hudson.model.StringParameterDefinition>
          <name>service_name</name>
          <description>服务名</description>
          <defaultValue></defaultValue>
          <trim>true</trim>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>service_version</name>
          <description>服务版本</description>
          <defaultValue></defaultValue>
          <trim>true</trim>
        </hudson.model.StringParameterDefinition>
        <hudson.model.StringParameterDefinition>
          <name>commit_user</name>
          <description>提交人</description>
          <defaultValue></defaultValue>
          <trim>true</trim>
        </hudson.model.StringParameterDefinition>
      </parameterDefinitions>
    </hudson.model.ParametersDefinitionProperty>
    <jenkins.model.BuildDiscarderProperty>
      <strategy class="hudson.tasks.LogRotator">
        <daysToKeep>1</daysToKeep>
        <numToKeep>1</numToKeep>
        <artifactDaysToKeep>3</artifactDaysToKeep>
        <artifactNumToKeep>3</artifactNumToKeep>
      </strategy>
    </jenkins.model.BuildDiscarderProperty>
  </properties>
  <scm class="hudson.scm.SubversionSCM" plugin="subversion@2.13.1">
    <locations>
      <hudson.scm.SubversionSCM_-ModuleLocation>
        <remote>http://dev.code.com:8011/code_baseline/${service_name}/boot_${service_version}@HEAD</remote>
        <credentialsId>2</credentialsId>
        <local>.</local>
        <depthOption>infinity</depthOption>
        <ignoreExternalsOption>true</ignoreExternalsOption>
        <cancelProcessOnExternalsFail>true</cancelProcessOnExternalsFail>
      </hudson.scm.SubversionSCM_-ModuleLocation>
    </locations>
    <excludedRegions></excludedRegions>
    <includedRegions></includedRegions>
    <excludedUsers></excludedUsers>
    <excludedRevprop></excludedRevprop>
    <excludedCommitMessages></excludedCommitMessages>
    <workspaceUpdater class="hudson.scm.subversion.UpdateUpdater"/>
    <ignoreDirPropChanges>false</ignoreDirPropChanges>
    <filterChangelog>false</filterChangelog>
    <quietOperation>true</quietOperation>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.plugins.descriptionsetter.DescriptionSetterBuilder plugin="description-setter@1.10">
      <regexp></regexp>
      <description>服务: ${service_name} 版本: ${service_version} 提交人: ${commit_user}</description>
    </hudson.plugins.descriptionsetter.DescriptionSetterBuilder>
    <hudson.tasks.Shell>
      <command>/home/infra/add-bootstrap.sh ${service_name}</command>
      <configuredLocalRules/>
    </hudson.tasks.Shell>
    <hudson.tasks.Shell>
      <command>/usr/local/maven3.5.4/bin/mvn clean package</command>
      <configuredLocalRules/>
    </hudson.tasks.Shell>
    <hudson.tasks.Shell>
      <command>/home/infra/docker_tag_push.sh ${service_name} ${service_version}</command>
      <configuredLocalRules/>
    </hudson.tasks.Shell>
  </builders>
  <publishers/>
  <buildWrappers>
    <hudson.plugins.ws__cleanup.PreBuildCleanup plugin="ws-cleanup@0.38">
      <deleteDirs>false</deleteDirs>
      <cleanupParameter></cleanupParameter>
      <externalDelete></externalDelete>
      <disableDeferredWipeout>false</disableDeferredWipeout>
    </hudson.plugins.ws__cleanup.PreBuildCleanup>
  </buildWrappers>
</project>
```

5. 可以关联发送通知的job，发版完成后通知相关人员

---

相关shell脚本

```shell
[centos@zbx-cn-02 - cn - jenkins-scripts]$ cat add-bootstrap.sh
#!/bin/bash
SERVICE_NAME=$1
VERSION=${2}

[[ ${SERVICE_NAME} == 'sc' ]] && exit 0

#rm -f src/main/resources/application.*

base (){
cat > src/main/resources/bootstrap.yml <<EOF
spring:
  cloud:
    config:
      profile: config
      uri: http://sc:8762/
      name: $SERVICE_NAME
eureka:
  client:
    serviceUrl:
      defaultZone: http://rc:8761/eureka/
  instance:
    prefer-ip-address: true
EOF
}

alpha (){
cat > src/main/resources/bootstrap.yml <<EOF
spring:
  cloud:
    config:
      profile: alpha
      uri: http://sc:8762/
      name: $SERVICE_NAME
eureka:
  client:
    serviceUrl:
      defaultZone: http://rc:8761/eureka/
  instance:
    prefer-ip-address: true
EOF
}

if [[ ${VERSION} == "alpha" ]];then
   alpha
else
   base
fi

```

```shell
[centos@zbx-cn-02 - cn - jenkins-scripts]$ cat docker_tag_push.sh
#!/bin/bash
set -x
nameSpace=zbx
serviceVersion=${2:-latest}
imageName=$1
export JOB_NAME=${JOB_NAME}


dockerPush (){
  registryUrl=${1}
  nameSpace=zbxsoft
  image=${imageName}
  
  if [[ ${imageName} == web ]];then
   sed -i '2a\[[ -f /usr/local/tomcat/bin/catalina.sh ]] && chmod +x /usr/local/tomcat/bin/catalina.sh' /opt/wait-for-it.sh
  fi
  docker build . -t $registryUrl/$nameSpace/$image:${serviceVersion}
  docker push $registryUrl/$nameSpace/$image:${serviceVersion}
  docker save cr.zbxsoft.com/$nameSpace/$image:${serviceVersion} -o /tmp/${imageName}-${serviceVersion}.tar
  chmod 644 /tmp/${imageName}-${serviceVersion}.tar
  ls -lh /tmp/${imageName}-${serviceVersion}.tar
  if [[ ${serviceVersion} == 'license' ]]; then
      scp  /tmp/${imageName}-${serviceVersion}.tar root@192.168.9.202:/mnt/update_file/update/${imageName}-${serviceVersion}-license-amd64.tar
  else
      scp  /tmp/${imageName}-${serviceVersion}.tar root@192.168.9.202:/mnt/update_file/update
  fi

  rm -f /tmp/${imageName}-${serviceVersion}.tar
}


# main
dockerPush harbor.code.com


# echo "$[serviceVersion]"
/home/infra/scp_jar.sh ${imageName}

```

```shell
[centos@zbx-cn-02 - cn - jenkins-scripts]$ cat scp_jar.sh 
#!/bin/bash
set -xe

if [[ -d target ]]
then
    rsync -az target/*.jar root@192.168.9.202:/mnt/update_file/update/ || true
    rsync -az target/*.xjar root@192.168.9.202:/mnt/update_file/update/ || true
    rsync -az target/*.war root@192.168.9.202:/mnt/update_file/update/ || true
fi
```