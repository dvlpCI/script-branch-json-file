'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 15:26:27
FilePath: branchJsonFile_input.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-

from branchJsonFile_input_base_util import chooseAnswerFromFile, chooseApierFromFile, chooseTesterFromFile

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

import os

def chooseAnswer():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    return chooseAnswerFromFile(tool_params_file_path)

def chooseApier():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    return chooseApierFromFile(tool_params_file_path)

def chooseTester():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    return chooseTesterFromFile(tool_params_file_path)




# # 获取具名参数的值
# import argparse
# parser = argparse.ArgumentParser()  # 创建参数解析器
# parser.add_argument("-filePath", "--filePath", help="The value for argument 'filePath'")
# args = parser.parse_args()  # 解析命令行参数
# filePath = args.filePath
# if filePath is None:
#     print(f"{RED}您要获取姓名的输入源文件 -filePath 不能为空，请检查！{NC}")
#     exit(1)

# import os
# tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
# chooseAnswer()
# chooseApier()
# chooseTester()
# inputOutline()
