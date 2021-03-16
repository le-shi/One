# Plugins

```mark
## 标题名称

- 插件名称1
- 插件名称2 as 安装脚本 插件名
```

---

## 集成Gitlab

- `gitlab`
- `Generic Webhook Trigger`
- `Blue Ocean`(会带上很多依赖)
- `Pipeline Utility Steps`
- `Task Scanner` as `/usr/local/bin/install-plugins.sh tasks`

## 集成SonarQube

- `SonarQube Scanner` as `/usr/local/bin/install-plugins.sh sonar`
- `dependency-check` as `/usr/local/bin/install-plugins.sh dependency-check-jenkins-plugin`
- `Static Analysis Utilities` as `/usr/local/bin/install-plugins.sh analysis-core`

## 集成Maven & Nexus

- `pipeline Maven Integration` as `/usr/local/bin/install-plugins.sh pipeline-maven`
- `Pipeline Utility Steps` as `/usr/local/bin/install-plugins.sh pipeline-utility-steps`