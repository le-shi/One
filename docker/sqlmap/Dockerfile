FROM cr.zbxsoft.com/3rd/python:2.7.18-stretch
RUN \
    echo "deb http://mirrors.aliyun.com/debian/ stretch main non-free contrib" > /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ stretch main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian-security stretch/updates main" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ stretch-updates main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib" >> /etc/apt/sources.list \
    && echo "deb-src http://mirrors.aliyun.com/debian/ stretch-backports main non-free contrib" >> /etc/apt/sources.list
RUN mkdir /run/sshd
RUN apt-get update
RUN apt-get -y install openssh-server vim
RUN echo 'UseDNS no' >> /etc/ssh/sshd_config \
    && echo 'GSSAPIAuthentication no' >> /etc/ssh/sshd_config \
    && echo 'GSSAPICleanupCredentials no' >> /etc/ssh/sshd_config \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo "alias ll='ls -l --color=auto'" >> /etc/profile \
    && echo "alias ls='ls --color=auto'" >> /etc/profile \
    && echo 'root:root' | chpasswd
RUN \
    apt-get update \
    && rm -rf /var/lib/apt/*
COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY sqlmap.zip /root
RUN unzip -q /root/sqlmap.zip -d /tmp/ \
    && mv /tmp/sqlmap*/* /root/ \
    && chmod +x /docker-entrypoint.sh
WORKDIR /root
EXPOSE 22

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config"]
