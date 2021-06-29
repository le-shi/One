# sqlmap && python2 && sshd

**构建镜像**

```shell
docker build . -t rolesle/sqlmap:2021-06-29
```

**docker启动**

```shell
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
