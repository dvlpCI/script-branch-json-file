'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-11-21 20:08:42
FilePath: jenkins_input.py
Description: 对 map 进行 urlencode (array是无效的)
'''

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

import sys
import json
import urllib.parse

networkParams_json_string = sys.argv[1]
# # 获取具名参数的值
# import argparse
# parser = argparse.ArgumentParser()  # 创建参数解析器
# parser.add_argument("-temp_reslut_file_path", "--temp_reslut_file_path", help="The value for argument 'temp_reslut_file_path'")
# args = parser.parse_args()  # 解析命令行参数
# temp_reslut_file_path = args.temp_reslut_file_path
# if temp_reslut_file_path is None:
#     print(f"{RED}您要获取创建分支信息的信息输入源文件 -temp_reslut_file_path 不能为空，请检查！{NC}")
#     exit(1)

networkParams_json_data = json.loads(networkParams_json_string)

# print(f"networkParams_json_string={networkParams_json_string}")
# print(f"networkParams_json_data={networkParams_json_data}")

query_string = urllib.parse.urlencode(networkParams_json_data)
print(f"{query_string}")


