"""
# 背景: 原始结构: 附件是按项目目录存放，目标结构: 附件按所属人目录存放

# 1. 从数据库里查询出附件信息并保存在cvs中
# 2. 从cvs获取源路径，文件名和所属人
# 3. 定义输出路径，将目标文件放到指定目录中

def a - read_csv; return dict
def b - file_action; return info
def c - load_a[dict]; use_b

use: c(**kwargs)
"""
import csv

import os
import shutil
from datetime import datetime
from multiprocessing import Pool
from time import time

# 写文件
def write_test():
    one = ["11", "22"]
    with open("test.csv", "w", newline="") as fi:
        fic = csv.writer(fi)
        fic.writerow(one)

# 读文件
def read_test(read_file, src_path, dest_path):
    """
    read_file = "/home/lshi/atta_pytest.csv"
    src_path = "/home/lshi/workspace"
    dest_path = "/tmp/wow"

    :param read_file: 读取文本文件
    :param src_path: 源文件路径，获取数据文件
    :param dest_path: 输出文件路径，将文件分类，放到指定拼接的路径下
    :return:
    """
    # 创建进程池对象
    pool = Pool(8, maxtasksperchild=2)
    # 读取文件，读取结束自动关闭
    with open(read_file, "r") as fi:
        # 初始化reader对象
        fic = csv.reader(fi)
        # 处理每行
        for f in fic:
            # 声明使用的对象
            PID = f[0]
            PRO_NAME = f[1]
            BUYER_NAME = f[2]
            BUYER_ID = f[3]
            ELECTRONIC_URL = f[4]
            # 处理多附件，以,结尾
            if "," in ELECTRONIC_URL:
                for ii in range(len(ELECTRONIC_URL.split(','))):
                    if ELECTRONIC_URL.split(',')[ii]:
                        ELECTRONIC_URL_FILE = ELECTRONIC_URL.split(',')[ii].split('atta//')[-1]
                        # 以多进程的方式操作文件，异步非阻塞方式
                        pool.apply_async(test_merge, args=(ELECTRONIC_URL_FILE, PRO_NAME, BUYER_NAME))
                        # 同步阻塞方式
                        # test_merge(ELECTRONIC_URL_FILE, PRO_NAME, BUYER_NAME)
            else:
                # 获取文件名
                ELECTRONIC_URL_FILE = ELECTRONIC_URL.split('atta//')[-1]
                # 以多进程的方式操作文件，异步非阻塞方式
                pool.apply_async(test_merge, args=(ELECTRONIC_URL_FILE, PRO_NAME, BUYER_NAME))
                # 同步阻塞方式
                # test_merge(ELECTRONIC_URL_FILE, PRO_NAME, BUYER_NAME)
    # 阻止后续任务提交到进程池，当所有任务执行完成后，工作进程会退出。
    pool.close()
    # 等待所有工作进程执行完毕，使用join之前必须使用close或者terminate
    pool.join()


def print_message(msg):
    print(datetime.now(), msg)


# 合并路径
def test_merge(ELECTRONIC_URL_FILE, PRO_NAME, BUYER_NAME):
    # 拼接源路径
    src_file = "{0}/{1}".format(src_path, ELECTRONIC_URL_FILE)
    # 拼接dest路径，格式："{固定目录}/{项目名称}/{竞买人名称}/{相关附件}"
    dest_file = "{0}/{1}/{2}/{3}".format(dest_path, PRO_NAME, BUYER_NAME, ELECTRONIC_URL_FILE.split('/')[-1])
    print_message("Pid[{pid}] 源文件: {0} -> 目标文件: {1}".format(src_file, dest_file, pid=os.getpid()))
    # 文件按项目，竞买人归类
    test_file_exist(src_file)
    # test_file(src_file, dest_file)


# 文件测试
def test_file_exist(src_file):
    if not os.path.isfile(src_file):
        print_message("error - file not exist {0}".format(src_file))
    else:
        print_message("ok - file exists {0}".format(src_file))


# 文件操作
def test_file(src_file, dest_file):
    if not os.path.isfile(src_file):
        print_message("file not exist {0}".format(src_file))
    else:
        fpath, fname = os.path.split(dest_file)
        if not os.path.exists(fpath):
            os.makedirs(fpath, mode=0o755)
        shutil.copyfile(src_file, dest_file)



if __name__ == '__main__':
    # 声明对象
    read_file = "/home/lshi/atta_pytest.csv"
    src_path = "/home/lshi/workspace"
    dest_path = "/tmp/wow"

    start_time = time()
    read_test(read_file, src_path, dest_path)
    end_time = time()
    print_message("CPU:({0})".format(os.cpu_count()))
    print_message("本次消耗时间: %.2f 秒" % (end_time - start_time))

