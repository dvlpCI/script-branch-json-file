'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-06-04 18:41:39
FilePath: /path_util.py
Description: 路径的计算方法
'''
import os

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 获取相对于指定文件的相对目录的绝对路径
def getAbsPathByFileRelativePath(file_path, rel_path):
    file_dir_abspath=os.path.abspath(file_path)
    # 获取当前文件的所在目录
    file_parent_dir_path = os.path.dirname(file_dir_abspath)
    
    return joinFullPath(file_parent_dir_path, rel_path)


# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)
def joinFullPath(host_dir, rel_path):
    # 在 Unix 和 Linux 系统中，以斜杠开头的路径被视为绝对路径。所以需要去掉头部结尾的斜杠或者尾部开头的斜杠
    if host_dir.endswith("/"):
        host_dir = host_dir[:-1]
    if rel_path.startswith("/"):
        rel_path = rel_path[1:]
    full_path = os.path.join(host_dir, rel_path)
    full_abspath = os.path.abspath(full_path)

    # print(f"full_abspath: {YELLOW}{full_abspath}{NC}")
    return full_abspath


# Url路径拼接
def joinFullUrl(host_url, rel_url):
    # rstrip() 方法删除字符串末尾的斜杠，lstrip() 方法删除字符串开头的斜杠，然后拼接字符串
    full_url = host_url.rstrip("/") + "/" + rel_url.lstrip("/")

    # print(f"full_url: {YELLOW}{full_url}{NC}")
    return full_url

# a = '/Users/qian/Project/CQCI/script-branch-json-file/test/tool_input.json'
# b = '../../'
# c = os.path.abspath(os.path.join(os.path.dirname(a), b))
# print("===0====envValue: \033[1;31m{}\033[0m".format(c))
# print(f"===0====envValue: {RED}{c}{NC}")
# print("===1====envValue: \033[1;31m{}\033[0m".format(joinFullPath(os.path.dirname(a), "./")))
# print("===2====envValue: \033[1;31m{}\033[0m".format(joinFullPath(os.path.dirname(a), "../")))
# print("===3====envValue: \033[1;31m{}\033[0m".format(joinFullPath(os.path.dirname(a), "../../")))

# aUrl = "http://acd/dfd/cdfd.com/"
# print("===2.1====envValue: \033[1;31m{}\033[0m".format(joinFullUrl(aUrl, "/de/")))