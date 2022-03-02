#!/bin/sh
# 一键安装docker环境
docker_name=docker-20.10.2.tgz
#CentOS|RHEL
systemd_root_path=/usr/lib
#Ubuntu
#systemd_root_path=/lib

#下载docker二进制文件
wget -Nc https://download.docker.com/linux/static/stable/$(uname --machine)/${docker_name}
#解压拷贝docker二进制文件
tar -xf ${docker_name}
#放到bin目录
mv docker/* /usr/bin/ && rm docker -rf

# 生成docker服务文件
cat > ${systemd_root_path}/systemd/system/docker.service <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket containerd.service

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

# 生成docker socket
cat > ${systemd_root_path}/systemd/system/docker.socket <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0666
SocketUser=root
SocketGroup=root

[Install]
WantedBy=sockets.target
EOF

# 生成containerd服务文件
cat > ${systemd_root_path}/systemd/system/containerd.service <<EOF
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target local-fs.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
Type=notify
Delegate=yes
KillMode=process
Restart=always
RestartSec=5
LimitNPROC=infinity
LimitCORE=infinity
LimitNOFILE=1048576
TasksMax=infinity
OOMScoreAdjust=-999

[Install]
WantedBy=multi-user.target
EOF

mkdir -p /etc/containerd
cat > /etc/containerd/config.toml <<EOF
disabled_plugins = ["cri"]
EOF

# 授权644
chmod 644 ${systemd_root_path}/systemd/system/{docker.service,docker.socket,containerd.service} /etc/containerd/config.toml

# 优化docker日志
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "max-concurrent-downloads": 20,
  "log-driver": "json-file",
  "log-level": "warn",
  "log-opts": {
    "max-size": "20m",
    "max-file": "100"
  },
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "http://hub-mirror.c.163.com"
  ]
}
EOF

systemctl daemon-reload
#开机启动并启动docker服务
systemctl enable --now docker.service >/dev/null 2>&1

# 显示docker版本
docker version