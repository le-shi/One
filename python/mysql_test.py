# coding=utf-8

# 操作mysql

import pymysql as msq


def mysql_setting ():
    """
    mysql connect setting message
    """
    # 创建连接
    conn = mysql.connect(host="192.168.9.124",user="zabbix",password="zabbix",db="zabbix",port="3306",charset="utf8")
    # 创建游标
    cursor = conn.cursor(cursor=msq.cursors.DictCursor)
    # 执行SQL
    cursor.execute("select * from db;")
    # 接受返回值
    data = cursor.fetchall()
    # 输出结果
    cursor.close()
    conn.close()
    for x in range(len(data)):
        data_dicts = data[x]
        print(data_dicts)
        # 取出字典所有键
        data_dicts_keys = data_dicts.keys()
        # 转成list
        data_list_keys = list(data_dicts_keys)
        # 转换索引
        for i in range(len(data_list_keys)):
            data_dicts_key = data_list_keys[i]
            data_dicts_key_s = data_dicts[data_dicts_key]
            # data_dicts_values = data_dicts.values(i)
            # print(data_dicts_keys)
            # print(data_dicts_values)
            # return(data)
            print("data_dicts_key: " + data_dicts_key + "\t\t" + "data_dicts_value: " + data_dicts_key_s)

if __name__ == '__main__':
    mysql_setting()
