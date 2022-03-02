Linux 免安装Oracle客户端 连接 Oracle数据库
1. 首先到oracle官网下载连接数据库用到的压缩包
官方地址如下：
http://www.oracle.com/technetwork/topics/linuxsoft-082809.html （32位）
http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html （64位）

具体根据数据库服务器版本下载对应版本的一下文件：
instantclient-basic-linux.x64-11.2.0.4.0.zip
instantclient-sqlplus-linux.x64-11.2.0.4.0.zip
instantclient-sdk-linux.x64-11.2.0.4.0.zip

2. 将下载的压缩包上传至Linux服务器，将压缩包进行解压
创建目录 mkdir -p /opt/oracle 将压缩包上传
解压文件 cd /opt/oracle 
unzip -q instantclient-basic-linux.x64-11.2.0.4.0.zip
unzip -q instantclient-sqlplus-linux.x64-11.2.0.4.0.zip
mv instantclient_11_2/ lib
unzip -q instantclient-sdk-linux.x64-11.2.0.4.0.zip
mv instantclient_11_2/ sdk

3. 创建 tnsnames.ora 文件

mkdir -p /opt/oracle/network/admin
cd /opt/oracle/network/admin

vim tnsnames.ora ，将具体地址数据库服务名进行修改

tee tnsnames.ora <<EOF
ORCL =
    (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.9.46)(PORT = 1521))
    (CONNECT_DATA =
        (SERVER = DEDICATED)
        (SERVICE_NAME = orcl)
    )
    )
EOF

4. 增加环境变量

将oracle环境变量加到对应用户 .bash_profile 执行 `source .bash_profile` 使其生效或者直接命令行执行

export ORACLE_HOME=/opt/oracle
export LD_LIBRARY_PATH=${ORACLE_HOME}/lib
export PATH=$PATH:${LD_LIBRARY_PATH}

5. 测试

直接使用: sqlplus 
或者
填写对应的用户名密码和实例名: sqlplus user/passwd@dbname
