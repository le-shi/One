- 起因
  - 有一天，ssh 远程连接一台新机器(国产操作系统)时，无法进行连接并且提示 `Unable to negotiate with 192.168.9.75 port 22: no matching key exchange method found. Their offer: curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256`
- 分析
  - 看提示的表面意思是，本地的 ssh 客户端没有找到和远程服务端匹配的密钥交换算法，不匹配密钥交换算法是 `Their offer:` 后面列出的。
  - 通过阅读官网文档[1]得知，这是因为如果客户端和服务器之间一组相互的参数无法达成一致，则将连接失败，而官方提供的最佳解决方法是另一端的软件或用更安全的现代类型替换弱密钥类型。OpenSSH 仅禁用我们积极建议不要使用的算法，因为它们已知是弱的。在某些情况下，这可能无法立即实现，因此您可能需要暂时重新启用弱算法以保留访问权限(更改 ssh 客户端的配置，重新启用弱密钥算法)
- 解决方法
  - 将 `Their offer:` 后面提到的算法填加到本地的 ssh 客户端配置文件(`/etc/ssh/ssh_config`)中，然后再重新尝试 ssh 连接


1. 修改 `/etc/ssh/ssh_config` 文件，找到关键字 `KexAlgorithms` 所在行，在原有基础上的末尾加入提示的密钥交换算法，注意多个算法之间使用`,`分隔。

    ```config
    # KexAlgorithms: 用于生成每个连接密钥的密钥交换算法
    KexAlgorithms +diffie-hellman-group1-sha1
    ```

2. 重试，这时应该可以正常连接


- 资料参考：
    - [1] [OpenSSH 弃用的选项](http://www.openssh.com/legacy.html)
