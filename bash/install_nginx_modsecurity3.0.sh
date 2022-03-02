#!/usr/bin/env bash
exit 1
# 软件环境安装
#第一：准备编译和依赖环境
yum install gcc wget git geoip-devel libcurl-devel libxml2 libxml2-devel libgd-devel  openssl-devel -y
yum groupinstall 'Development tools' -y

#第二：下载并安装ModSecurity
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
cd ModSecurity
git submodule init
git submodule update
./build.sh
./configure
make
make install

#第三：下载nginx与modsecurity的连接器
cd
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git

#第四：下载并编译nginx（将连接器编译进去）
mkdir /usr/local/nginx -p
yum install pcre-devel openssl-devel gd-devel geoip-devel -y
wget https://nginx.org/download/nginx-1.14.1.tar.gz
tar xf nginx-1.14.1.tar.gz
cd nginx-1.14.1

./configure \
--prefix=/usr/local/nginx \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_image_filter_module=dynamic \
--with-http_geoip_module=dynamic \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_degradation_module \
--with-http_slice_module \
--with-http_stub_status_module \
--with-pcre \
--with-pcre-jit \
--with-stream=dynamic \
--with-stream_ssl_module \
--with-debug \
--add-dynamic-module=/root/ModSecurity-nginx \
--with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" ;

make modules	#编译模块
make -j $(nproc)
make install


# 配置modsec与nginx
#第一：配置modsecurity
mkdir /usr/local/nginx/conf/modsec
cp /root/ModSecurity/modsecurity.conf-recommended /usr/local/nginx/conf/modsec/modsecurity.conf
cp /root/ModSecurity/unicode.mapping /usr/local/nginx/conf/modsec/

#第二：配置nginx,使其开启加载modsec模块
cat /usr/local/nginx/conf/nginx.conf

#该行在nginx.conf的event字段上面添加
load_module modules/ngx_http_modsecurity_module.so;

#配置在具体vhost里面
modsecurity on;	#表示开启modsec
location / {
    root   html;
    modsecurity_rules_file /usr/local/nginx/conf/modsec/modsecurity.conf;
    index  index.html index.htm;
}

#第三：测试nginx配置文件是否正确
/usr/local/nginx/sbin/nginx -t

#第四：使用测试规则调试modsec与nginx的工作是否正常
cat /usr/local/nginx/conf/modsec/modsecurity.conf

#SecRuleEngine DetectionOnly(将该行改为如下，表示启用拦截功能。默认只记录不拦截)
SecRuleEngine On

#添加如下一行，指定modsecurity的记录日志格式为json(默认的行数太多)
SecAuditLogFormat JSON

#在最后添加一个测试规则（测试完成就删除该行吧）
SecRule ARGS:testparam "@contains test" "id:1234,deny,log,status:403"

#第五：启动nginx并验证modsec与nginx的工作是否正常
/usr/local/nginx/sbin/nginx &
curl -D - http://localhost/foo?testparam=thisisatestofmodsecurity
#若是返回403则表示规则生效
#可以通过日志进行验证
cat /var/log/modsec_audit.log

#第六：安装owasp核心规则CRS
git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git
cp -rf owasp-modsecurity-crs  /usr/local/nginx/conf/
cd /usr/local/nginx/conf/owasp-modsecurity-crs
cp crs-setup.conf.example  crs-setup.conf
cd /usr/local/nginx/conf/owasp-modsecurity-crs/rules/
mv REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
mv RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf

#第七：让owasp核心规则生效加入modsecurity配置文件
cat /usr/local/nginx/conf/modsec/modsecurity.conf
#在最后添加引入owasp核心规则
Include /usr/local/nginx/conf/owasp-modsecurity-crs/crs-setup.conf
Include /usr/local/nginx/conf/owasp-modsecurity-crs/rules/*.conf


# 测试owasp核心规则是否生效
#第一：重启nginx
/usr/local/nginx/sbin/nginx -s reload &

#第二：使用nikto测试owasp 核心规则是否生效
#Nikto扫描工具生成恶意请求，包括针对已知易受攻击的文件，跨站点脚本（XSS）和其他类型的攻击的探测。
#该工具还会报告传递给应用程序的请求，从而揭示应用程序中的潜在漏洞。
git clone https://github.com/sullo/nikto
Cloning into 'nikto'...
cd nikto
perl program/nikto.pl -h http://localhost

#可以通过日志进行验证
cat /var/log/modsec_audit.log