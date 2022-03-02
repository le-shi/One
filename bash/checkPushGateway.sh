#!/bin/bash
# 增加 自定义指标 服务
# curl -s http://192.168.13.98:8000/checkPushGateway.sh | bash
# 脚本 push_gateway.sh 存放于 One/docker/prometheus

echo "prepare push_gateway.sh"
curl -s http://192.168.13.98:8002/push_gateway.sh -o /usr/sbin/push_gateway.sh
chmod +x /usr/sbin/push_gateway.sh
# exit 0
echo "prepare push-gateway.service"
cat > /usr/lib/systemd/system/push-gateway.service <<EOF
[Unit]
Description=push-gateway client

[Service]
Type=simple
ExecStart=/usr/sbin/push_gateway.sh
EOF

echo "prepare push-gateway.timer"
cat > /usr/lib/systemd/system/push-gateway.timer <<EOF
[Unit]
Description=push-gateway every 15s

[Timer]
# 定时器后指定的时间单位可以是：us(微秒), ms(毫秒), s(秒), m(分), h(时), d(天), w(周), month(月), y(年)。如果省略了单位，则表示使用默认单位‘秒’
# 多少(OnActiveSec)时间后，开始运行
OnActiveSec=30s
# 连续运行两次之间的间隔时间
OnUnitActiveSec=15s
Unit=push-gateway.service

[Install]
WantedBy=multi-user.target
EOF

echo "start && enable push-gateway.timer"
# jia载配置
systemctl daemon-reload
# 启动定时器
systemctl start push-gateway.timer
# 设置开机启动
systemctl enable push-gateway.timer


echo "check status push-gateway.timer"
# 查看定时器，服务
systemctl status push-gateway.timer push-gateway.service

# 开启自动超时断开
curl -s http://192.168.13.98:8000/checkSSHTimeout.sh | bash