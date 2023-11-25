'''
Author: dvlproad dvlproad@163.com
Date: 2023-11-25 20:53:03
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 23:03:34
FilePath: example_branchJsonFile_update.py
Description: 测试
'''
# -*- coding: utf-8 -*-

import os
import subprocess
import datetime
import json

from branchJsonFile_input_base_util import get_date_range, getOutline, inputOutline, chooseAnswerFromFile, chooseApierFromFile, chooseTesterFromFile, addOutline, updateOutlineSpendHour
# tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
# chooseAnswerFromFile(tool_params_file_path)
# chooseApierFromFile(tool_params_file_path)
# chooseTesterFromFile(tool_params_file_path)

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

def logTitle(title):
    print(f"{PURPLE}-------{title}-------{NC}")

current_dir = os.path.dirname(os.path.abspath(__file__))
example_dir = current_dir + "/example"


# logTitle("get_date_range")
# date = datetime.datetime.now()
# date = datetime.datetime.strptime("2022-02-03", "%Y-%m-%d")  # 将日期字符串解析为日期对象
# result = get_date_range(date)
# print(f"result = {result}")


# logTitle("getOutline")
# outlineMap=getOutline("哈哈哈")
# print(f"{json.dumps(outlineMap, indent=2, ensure_ascii=False)}")
# # exit(0)

# logTitle("inputOutline")
# outlineMap = inputOutline()
# print(f"{json.dumps(outlineMap, indent=2, ensure_ascii=False)}")
# # exit(0)

logTitle("updateOutlineSpendHour")
json_file_path = example_dir + "/featureBrances/main.json"
updateOutlineSpendHour(json_file_path)
subprocess.call(["open", json_file_path])