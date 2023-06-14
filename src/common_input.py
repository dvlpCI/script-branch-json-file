'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-14 18:51:03
FilePath: jenkins_input.py
Description: Jenkins打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'




def input_folder_path(prompt, validation=True):
    """Prompt the user to input a folder path. If `validation` is True,
    check if the folder exists and prompt the user to re-enter if it doesn't."""
    while True:
        folder_path = input(prompt)
        if folder_path.lower() == 'q':
            exit(2)
            break
        if os.path.isdir(folder_path):
            return folder_path
        elif not validation:
            return folder_path
        else:
            print(f"{RED}Error: '{YELLOW}{folder_path}{RED}' is not a valid folder path. Please try again.{NC}")


