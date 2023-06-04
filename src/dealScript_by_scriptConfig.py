'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-06-04 23:56:21
FilePath: src/dealScript_by_scriptConfig.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

from dealScript_by_scriptConfig_util import dealScriptByScriptConfig


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

import sys
# Check if command line arguments are provided
if len(sys.argv) == 0:
    print(f"{RED}请传递描述想要执行的脚本的信息配置文件")
    exit(1)
# print(f"传递进来的参数如下:")
# for i, arg in enumerate(sys.argv[1:], start=1):
#     print(f"参数{i}: {arg}")


dealScriptByScriptConfig(sys.argv[1])