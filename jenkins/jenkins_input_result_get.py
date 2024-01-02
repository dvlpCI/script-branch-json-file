'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-08 16:02:57
FilePath: jenkins_input_result_get.py
Description: Jenkins打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'


from jenkins_input_result_util import load_jenkins_urls_from_file



import sys
temp_reslut_file_path=sys.argv[1]

# # 获取具名参数的值
# import argparse
# parser = argparse.ArgumentParser()  # 创建参数解析器
# parser.add_argument("-temp_reslut_file_path", "--temp_reslut_file_path", help="The value for argument 'temp_reslut_file_path'")
# args = parser.parse_args()  # 解析命令行参数
# temp_reslut_file_path = args.temp_reslut_file_path
# if temp_reslut_file_path is None:
#     print(f"{RED}您要获取创建分支信息的信息输入源文件 -temp_reslut_file_path 不能为空，请检查！{NC}")
#     exit(1)

# print("====保存结果的临时文件的路径为：\033[1;31m{}\033[0m\n".format(temp_reslut_file_path))


def getPackParamStringFromFileForOption():
    return load_jenkins_urls_from_file(temp_reslut_file_path)


getPackParamStringFromFileForOption()


