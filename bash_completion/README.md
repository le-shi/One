Known and available: 
- git(default support)
- docker
- docker-compose
- kubectl
- helm

---

- [Install && Directory](#install--directory)
- [In file](#in-file)



# Install && Directory
安装完软件包后，补充文件将放到脚本目录内

- CentOS

    ```
    # Package
    yum -y install bash-completion
    # Directory
    /etc/bash_completion.d/
    ```

# In file
[/etc/profile|~/.bashrc]

- kubectl
  
    `source <(kubectl completion bash)`

- helm
  
    `source <(helm completion bash)`
