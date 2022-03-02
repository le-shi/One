# 如何使用 Netcat 复制文件

当您将文件从一台 Linux 服务器复制到另一台时，您的首选将是 SSH。SSH 安全且无处不在，**应该**是您的首选。

有时 SSH 加密的 CPU 开销可能是传输速度的瓶颈。如果您要复制大量数据，则此障碍可能会很严重。

避免这种情况的一种方法是使用[netcat](http://netcat.sourceforge.net/)。

Netcat 允许您在不使用任何加密的情况下在系统之间移动数据，从而最大限度地提高传输速度。

**注意：**这是完全不安全的，因此您应该非常仔细地考虑在何处使用此技术。

## 安装

```bash
# Centos
sudo yum install netcat
# 这两个软件包都包含 nc 命令
sudo yum install nmap-ncat
```

## 开始操作

首先，在目标服务器上，启动 netcat 侦听端口：

```bash
netcat -l -p <port> >OutFile
```

该命令在端口(`-p <端口>`)上启动netcat监听(`-l`)，并将接收到的数据指向一个文件(>OutFile)。

然后，使用以下命令从源服务器发送文件：

```bash
netcat <host> <port> <InFile
```

将`<host>`设置为接收服务器的主机名或IP地址，并将`<port>`与目标服务器上的侦听端口匹配。

传输速度将与您的网络或存储设备移动数据的速度一样快。