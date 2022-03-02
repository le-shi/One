#!/bin/bash
nginxdir=/usr/share/nginx
nginxver=nginx-1.12.2.tar.gz
if [ -d ${nginxdir} ];
then
 echo "${nginxdir} directory exists"
else
 mkdir ${nginxdir}
fi
#yum
yum -y install nss cmake make gcc gcc-c++ libevent zlib zlib-devel openssl openssl-devel glibc glibc-devel compat-expat1 glibc.i686 procps procmail ncurses-devel ncurses-libs ncurses-base ncurses libuuid-devel pcre pcre-devel libxslt libxml2 libxml2-devel gd-devel perl-ExtUtils-Embed perl-devel libxslt-devel GeoIP GeoIP-devel
#wget tar
if [ -f ${nginxdir}/${nginxver} ];
then
 :
else
 wget -P $nginxdir http://nginx.org/download/nginx-1.12.2.tar.gz
fi
wget -P $nginxdir https://bitbucket.org/nginx-goodies/nginx-sticky-module-ng/get/08a395c66e42.zip
#unzip
cd $nginxdir
tar -zxf nginx-1.12.2.tar.gz
unzip 08a395c66e42.zip
mv nginx-goodies-nginx-sticky-module-ng-08a395c66e42 nginx-sticky-module
#configure
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
--add-module=${nginxdir}/nginx-sticky-module

make -j $(nproc)
make install
