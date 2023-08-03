'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-08-03 09:51:24
FilePath: dealScriptByCustomChoose.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import subprocess
from env_pack_util import getEnvValue_customWebsite
from base_util import openFile
from path_util import joinFullPath_noCheck
from env_util import get_json_file_data
from openWebsite_by_websiteConfig_util import chooseCustomWebsiteAndOpenItFromWebsites


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


# 获取环境变量的值-自定义的website
def getEnvValue_website_recommend():
    # 获取当前脚本文件所在的目录
    current_script_dir = os.path.dirname(os.path.abspath(__file__))
    default_value_file_path= joinFullPath_noCheck(current_script_dir, "default_value.json")
    data = get_json_file_data(default_value_file_path)
    if data == None:
        return None
    
    if "website" not in data or "recommend" not in data['website']:
        print(f"{default_value_file_path}中不存在key为 .website.recommend 的值，请先检查补充")
        openFile(default_value_file_path)
        return None
    
    customWebsites = data['website']['recommend']
    return customWebsites


import sys



# 获取第一个参数
if len(sys.argv) > 1:
    arg1 = sys.argv[1] # 第一个参数
    print("第一个参数是：", arg1)
else:
    print("缺少第一个参数")



    

# 获取第二个参数
if arg1 == "custom":
    customWebistes=getEnvValue_customWebsite()
elif arg1 == "recommend":
    customWebistes=getEnvValue_website_recommend()
else:
    print("缺少第二个参数")




if customWebistes==None:
    exit(1)

chooseCustomWebsiteAndOpenItFromWebsites(customWebistes)


