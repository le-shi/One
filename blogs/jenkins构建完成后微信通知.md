# jenkins构建完成后微信通知

1. jenkins安全设置允许匿名用户只读权限
2. 准备个py脚本
3. 创建个专门发送通知的job(自定义)
4. 执行shell jenkins_job_msg_to_python.sh
5. 关联job
问题: 并发job时有点问题
