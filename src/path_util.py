'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-04-25 20:17:14
FilePath: /path_util.py
Description: 路径的计算方法
'''
import os

# 获取环境变量的值
def joinFullPath(host_dir, rel_path):
    # 在 Unix 和 Linux 系统中，以斜杠开头的路径被视为绝对路径。所以需要去掉头部结尾的斜杠或者尾部开头的斜杠
    if host_dir.endswith("/"):
        host_dir = host_dir[:-1]
    if rel_path.startswith("/"):
        rel_path = rel_path[1:]
    full_abspath = os.path.join(host_dir, rel_path)

    # print("full_abspath: \033[1;31m{}\033[0m".format(full_abspath))
    return full_abspath