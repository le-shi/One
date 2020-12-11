FROM centos:7
ADD Apache_OpenOffice_4.1.7_Linux_x86-64_install-rpm_zh-CN.tar.gz /tmp
ADD Apache_OpenOffice_4.1.7_Linux_x86-64_langpack-rpm_zh-CN.tar.gz /tmp
RUN rpm -ivh /tmp/zh-CN/RPMS/*.rpm \
    && yum -y install wget \
    && wget -O CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
    && yum clean all \
    && yum makecache \
    && yum -y install java-1.8.0-openjdk \
    && rpm -e wget \
    && yum clean all \
    && rm -rf /tmp/zh-CN
WORKDIR /opt/openoffice4/program
ENTRYPOINT ["./soffice"]
CMD ["-accept=socket,host=0.0.0.0,port=8100;urp;StarOffice.ServiceManager", "-nologo", "-headless", "-nofirststartwizard"]