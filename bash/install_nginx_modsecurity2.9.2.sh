#!/bin/bash
nginxdir=/usr/local/nginx
nginxver=nginx-1.12.2
modsecurity_path=/etc/nginx

# funtion
nginx_init () {
    curl -L https://gitee.com/Roles_le/One/raw/master/bash/nginx > /etc/init.d/nginx
    if [ $? -eq '0' ];
    then
        chmod +x /etc/init.d/nginx
    else
        echo "add /etc/init.d/nginx filed."
        exit
    fi
}


if [ -d ${nginxdir} ];
then
    echo "${nginxdir} directory exists"
else
    mkdir ${nginxdir}
fi
# yum
yum -y install wget unzip cmake make gcc gcc-c++ libevent nss zlib zlib-devel openssl openssl-devel glibc glibc-devel compat-expat1 glibc.i686 procps procmail  ncurses-devel ncurses-libs ncurses-base ncurses  libuuid-devel pcre pcre-devel  libxslt libxml2 libxml2-devel gd-devel perl-ExtUtils-Embed perl-devel libxslt-devel
# wget tar
if [ -f ${nginxdir}/${nginxver}.tar.gz ];
then
    rm -r ${nginxdir}/${nginxver}.tar.gz
    rm -rf ${nginxdir}/${nginxver}
    wget -P $nginxdir http://nginx.org/download/${nginxver}.tar.gz
else
    wget -P $nginxdir http://nginx.org/download/${nginxver}.tar.gz
fi
# wget sticky
wget -P $nginxdir https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/08a395c66e42.zip
# unzip
cd $nginxdir
tar -zxf nginx-1.12.2.tar.gz
unzip 08a395c66e42.zip
mv nginx-goodies-nginx-sticky-module-ng-08a395c66e42 nginx-sticky-module
#  install modsecurity2.9.2
if [ $? -eq '0' ];
then
    echo "Install modsecurity2"
    yum install -y git gcc make automake autoconf libtool
    yum install -y pcre pcre-devel libxml2 libxml2-devel curl curl-devel httpd-devel
    if [ $? -eq '0' ];
    then
        cd ${nginxdir} && git clone https://github.com/SpiderLabs/ModSecurity.git  mod_security
    else
        exit
    fi
    cd mod_security && \
    git checkout v2.9.2 && \
    chmod 777 autogen.sh && \
    ./autogen.sh && \
    ./configure --enable-standalone-module && \
    make
fi



# configure
cd ${nginxdir}/nginx-1.12.2
./configure \
--prefix=/usr/local/nginx/ \
--user=nginx \
--group=nginx \
--conf-path=/etc/nginx/nginx.conf \
--pid-path=/var/run/nginx.pid \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_stub_status_module \
--with-http_ssl_module \
--sbin-path=/usr/sbin/nginx \
--modules-path=/usr/lib64/nginx/modules \
--http-client-body-temp-path=/var/lib/nginx/tmp/client_body  \
--http-proxy-temp-path=/var/lib/nginx/tmp/proxy  \
--http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi  \
--http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi  \
--http-scgi-temp-path=/var/lib/nginx/tmp/scgi  \
--lock-path=/var/lock/subsys/nginx  \
--with-file-aio  \
--with-http_v2_module  \
--with-http_realip_module  \
--with-http_addition_module  \
--with-http_xslt_module=dynamic  \
--with-http_sub_module  \
--with-http_dav_module  \
--with-http_flv_module \
--with-http_mp4_module  \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module  \
--with-http_slice_module \
--add-module=${nginxdir}/nginx-sticky-module \
--add-module=${nginxdir}/mod_security/nginx/modsecurity

make -j $(nproc)
make install

if [ $? -eq '0' ];
then
    nginx_init
    # create nobody user
    useradd -s /sbin/nologin -M nginx
    nginx -t
fi
# install modsecurity owasp
cd ${nginxdir} && git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
cp -r owasp-modsecurity-crs/ ${modsecurity_path}
cp ${modsecurity_path}/owasp-modsecurity-crs/crs-setup.conf.example ${modsecurity_path}/owasp-modsecurity-crs/crs-setup.conf
# deploy modsecurity
cp -r /usr/local/nginx/mod_security/{modsecurity.conf-recommended,unicode.mapping} ${modsecurity_path}
cp ${modsecurity_path}/modsecurity.conf-recommended ${modsecurity_path}/modsecurity.conf
sed -i 's/^SecRuleEngine DetectionOnly/SecRuleEngine on/' ${modsecurity_path}/modsecurity.conf
if [ $? -eq '0' ];
then
cat >> ${modsecurity_path}/modsecurity.conf << EOF
SecRule ARGS:testparam "@contains test" "id:1234,deny,status:403,msg:'Our test rule has triggered !!!197-test-196!!!'"
Include owasp-modsecurity-crs/crs-setup.conf
EOF
fi

echo '''
#############################
# #1. nginx开启ModSecurity
# ...
#         location / {
#             root   html;
#             # 开启ModSecurity
#             ModSecurityEnabled on;
#             # 选择ModSecurity配置文件
#             ModSecurityConfig /etc/nginx/modsecurity.conf;
#             index  index.html index.htm;
#         }
# ...

# #2. 测试
# #第一：重启nginx
# nginx -s reload
# #第二：使用nikto测试owasp 核心规则是否生效
# #Nikto扫描工具生成恶意请求，包括针对已知易受攻击的文件，跨站点脚本（XSS）和其他类型的攻击的探测。
# #该工具还会报告传递给应用程序的请求，从而揭示应用程序中的潜在漏洞。
# git clone https://github.com/sullo/nikto
# cd nikto
# perl program/nikto.pl -h http://localhost
# #可以通过日志进行验证
# cat /var/log/modsec_audit.log
#############################
'''