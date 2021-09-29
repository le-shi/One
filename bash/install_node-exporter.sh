#!/bin/bash
set -xe

PKG_VER=1.2.2

cd /tmp
# 下载
wget -c -t 3 https://github.com/prometheus/node_exporter/releases/download/v${PKG_VER}/node_exporter-${PKG_VER}.linux-amd64.tar.gz

# 放到可执行目录
tar -zxf node_exporter-${PKG_VER}.linux-amd64.tar.gz
mv -f -b node_exporter-${PKG_VER}.linux-amd64/node_exporter /usr/bin/node_exporter
# 添加service
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network.target

[Service]
ExecStart=/usr/bin/node_exporter
User=nobody

[Install]
WantedBy=multi-user.target
EOF

# 设置开机启动并立刻启动
systemctl daemon-reload
systemctl enable --now node_exporter
systemctl restart node_exporter

# 查看启动的状态
systemctl status node_exporter

# 清理
rm -f node_exporter-${PKG_VER}.linux-amd64.tar.gz
