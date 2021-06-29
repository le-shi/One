
# 安装apache 2.2 
wget http://archive.apache.org/dist/httpd/httpd-2.2.32.tar.gz
tar zxf httpd-2.2.32.tar.gz
cd httpd-2.2.32
# fix --> configure: error: ... Error, SSL/TLS libraries were missing or unusable
export LDFLAGS=-ldl
./configure --prefix=/home/user/apache2  --enable-ssl  --with-ssl=/usr/local/openssl-1.0.2u  --enable-so --enable-mods-shared=all && make -j 8 && make install

# 添加mod_xx.so 模块
mod_jk.so:
wget https://archive.apache.org/dist/tomcat/tomcat-connectors/jk/binaries/linux/jk-1.2.31/i386/mod_jk-1.2.31-httpd-2.2.x.so

mod_security.so:
wget https://master.dl.sourceforge.net/project/mod-security/modsecurity-apache/1.9.5/modsecurity-apache_1.9.5.tar.gz?viasf=1 -O modsecurity-apache_1.9.5.tar.gz
tar zxf modsecurity-apache_1.9.5.tar.gz
cd modsecurity-apache_1.9.5/apache2
# 执行完这句命令，mod_security.so就已经安装到了 ${APACHE_PREFIX_PATH}/modules下面
/home/user/apache2/bin/apxs -aic mod_security.c

mod_qos:
# 官网 http://mod-qos.sourceforge.net/
# 下载地址 https://sourceforge.net/projects/mod-qos/files/

# 安装依赖
yum install pcre-devel pcre openssl-devel
# 下载
wget https://jaist.dl.sourceforge.net/project/mod-qos/mod_qos-11.66.tar.gz
# 解压
tar xf mod_qos-11.66.tar.gz
# httpd 二进制文件必须支持动态加载的对象 (DSO)。通过检查mod_so的可用性来验证这一点：该命令 必须列出 mod_so.c 模块
/home/user/apache2/bin/httpd -l
# 以下命令编译模块并将 mod_qos 安装到服务器的模块目录中
/home/user/apache2/bin/apxs -i -c mod_qos.c -lcrypto -lpcre 
