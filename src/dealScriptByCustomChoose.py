'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-13 21:04:28
FilePath: dealScriptByCustomChoose.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import subprocess
from env_pack_util import getEnvValue_pack_input_params_file_path
from base_util import callScriptCommond
from path_util import getAbsPathByFileRelativePath
from dealScript_by_scriptConfig_util import chooseCustomScriptFromFilePaths, dealScriptByScriptConfig

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



# import argparse
# parser = argparse.ArgumentParser()
# for item in json.loads(" ".join(__import__("sys").argv[1:])):
#     parser.add_argument(item)
# args = parser.parse_args()
# print(args)

custom_script_files_abspath=getEnvValue_pack_input_params_file_path(shouldCheckExist=True)
chooseScriptMap=chooseCustomScriptFromFilePaths(custom_script_files_abspath, shouldCheckExist=True)
chooseScriptFilePath=chooseScriptMap["script_info_abspath"]
pack_input_params_file_path=chooseScriptFilePath
if pack_input_params_file_path == None:
    exit(1)

# 执行方法1：直接使用util方法
# dealScriptByScriptConfig(pack_input_params_file_path)

# 执行方法2：调用python脚本
import os
current_file_path = os.path.realpath(__file__)
sript_file_absPath=getAbsPathByFileRelativePath(current_file_path, "./dealScript_by_scriptConfig.py")
command=["python3", sript_file_absPath, pack_input_params_file_path]
callScriptCommond(command, sript_file_absPath)

