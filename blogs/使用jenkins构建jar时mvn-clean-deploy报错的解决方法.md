使用 jenkins pipeline 构建 jar 时 mvn clean deploy 报错

```
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 31.344 s
[INFO] Finished at: 2022-02-10T17:09:53+08:00
[INFO] ------------------------------------------------------------------------
[INFO] [jenkins-event-spy] Generated /var/jenkins_home/workspace/xwkweb_2.3.12@tmp/withMaven3b6c9a74/maven-spy-20220210-170921-5977180113193882053983.log
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-install-plugin:2.5.2:install (default-install) on project xwkweb: Failed to install metadata com.zbxsoft:xwkweb/maven-metadata.xml: Could not parse metadata /root/.m2/repository/com/zbxsoft/xwkweb/maven-metadata-local.xml: in epilog non whitespace content is not allowed but got e (position: END_TAG seen ...</metadata>\ne... @38:2) -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/MojoExecutionException
```

解决方法:
- 删除 /root/.m2/repository/com/zbxsoft/xwkweb/maven-metadata-local.xml ，然后在页面上重新构建

如果是 docker 运行的 jenkins ，需要 docker exec -ti jenkins bash 进入容器内部进行删除操作