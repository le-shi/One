#!/bin/python
#-*- coding:utf-8 -*-

# 操作oracle

#pip install cx_Oracle --upgrade
#(57M) https://download.oracle.com/otn/linux/instantclient/11204/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm?AuthParam=1545735202_bc446ba4b6fc07acb77adaa2c677f704

import cx_Oracle                                          #引用模块cx_Oracle
conn=cx_Oracle.connect('username','password','19.18.0.8/orcl')    #连接数据库
c=conn.cursor()                                           #获取cursor
x=c.execute('select * from uct_user s where s.user_ename=\'admin\'')                   #使用cursor进行各种操作
d=x.fetchone()
print d
c.close()                                                 #关闭cursor
conn.close()                                              #关闭连接
