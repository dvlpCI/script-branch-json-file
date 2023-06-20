'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-20 19:51:18
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

from enum import Enum

class CustomPathType(Enum):
    NONE = 0
    FOLDER = 1
    FILE = 2
    BOTH = 3


def input_custom_path(prompt, validation=True, customPathType=CustomPathType.NONE):
    """Prompt the user to input a folder path. If `validation` is True,
    check if the folder exists and prompt the user to re-enter if it doesn't."""
    while True:
        input_path = input(prompt)
        if input_path.lower() == 'q':
            exit(2)
            break
        if not validation:
            return input_path
        
        if customPathType==CustomPathType.FOLDER:
            if os.path.isdir(input_path):
                return input_path
            else:
                print(f"{RED}Error: '{YELLOW}{input_path}{RED}' is not a valid folder path. Please try again.{NC}")

        if customPathType==CustomPathType.FILE:
            if os.path.isfile(input_path):
                return input_path
            else:
                print(f"{RED}Error: '{YELLOW}{input_path}{RED}' is not a valid file path. Please try again.{NC}")
            
        return input_path

