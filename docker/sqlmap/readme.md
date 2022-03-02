# sqlmap && python2 && sshd

**构建镜像**

```bash
docker build . -t rolesle/sqlmap:2021-06-29
```

**docker启动**

```bash
docker run -d -p 2222:22 --name sqlmap rolesle/sqlmap:2021-06-29
```

**docker-compose启动**

```yaml
version: '3'

services:
  sqlmap:
    container_name: sqlmap
    image: rolesle/sqlmap:2021-06-29
    hostname: sqlmap
    restart: always
    ports:
      - "2222:22"
```

**使用**

```bash
# 连接 - 本地exec
docker exec -ti sqlmap bash
# 连接 - 远程ssh
ssh sqlmap_ip:2222

# 使用 sqlmap 工具
$ python sqlmap.py --help
```