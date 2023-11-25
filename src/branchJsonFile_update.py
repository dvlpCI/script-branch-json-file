'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 17:48:34
FilePath: branchJsonFile_update.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import subprocess
from datetime import datetime

from git_util import get_branch_json_file_path_byToolParamFile
from object_update import update_dict_value

from branchJsonFile_input_base_util import chooseAnswerFromFile, chooseApierFromFile, chooseTesterFromFile, inputOutline

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

# 请选择操作类型
def chooseUpdateAction(tool_params_file_path):
    # print(f"tool_params_file_path={tool_params_file_path}")
    file_path=get_branch_json_file_path_byToolParamFile(tool_params_file_path)

    # 更新操作的类型
    updateAction_mapping = {
        "1": "更改人员信息(需求方/测试方)",
        "2": "添加信息",
        "3": "更新提测开始日期",
        "4": "更新测试通过日期和合入日期"
    }
    for key, value in updateAction_mapping.items():
        print(key, value)
    
    while True:
        updateAction_input = input(f"请选择操作类型(若要退出请输入Q|q)：")
        if updateAction_input == "q" or updateAction_input == "Q":
            break
        
        if updateAction_input == "1":
            answerName=chooseAnswerFromFile(tool_params_file_path)
            result=change("answer.name", f"{answerName}", file_path)
            if result == False:
                return False

            apierName=chooseApierFromFile(tool_params_file_path)
            result=change("apier.name", f"{apierName}", file_path)
            if result == False:
                return False
            
            testerName=chooseTesterFromFile(tool_params_file_path)
            result=change("tester.name", f"{testerName}", file_path)
            if result == False:
                return False

        elif updateAction_input == "2":
            outlineMap = inputOutline()
            addOutline(file_path, outlineMap)

        elif updateAction_input == "3":
            cur_date = datetime.now().strftime("%m.%d")
            result=change("submit_test_time", f"{cur_date}", file_path)
            if result == False:
                return False

        elif updateAction_input == "4":
            cur_date = datetime.now().strftime("%m.%d")
            result=change("pass_test_time", f"{cur_date}", file_path)
            if result == False:
                return False
            result=change("merger_pre_time", f"{cur_date}", file_path)
            if result == False:
                return False
        
        else:
            print("输入错误，请重新输入！")
            continue

        updateActionDes = updateAction_mapping[updateAction_input]
        print(f"您选择操作类型：{RED}{updateActionDes}{NC}\n")
    
    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', file_path])



def addOutline(file_path, outlineMap):
    with open(file_path, 'r') as json_file:
        json_data = json.load(json_file)

    json_data['outlines'].append(outlineMap)

    # 将更新后的数据写入json文件
    with open(file_path, 'w') as file:
        json.dump(json_data, file, indent=4, ensure_ascii=False)
    

def change(key, value, file_path):
    with open(file_path, "r+", encoding="utf-8") as json_file:
        json_data = json.load(json_file)
        # json_data[key] = value
        result=update_dict_value(json_data, key, value)
        if result == False:
            return False  
        json_file.seek(0)
        json.dump(json_data, json_file, indent=4, ensure_ascii=False)
        json_file.truncate()
    # print(f"已成功更新字段 {key} 为 {value} 在文件 {file_path}")


# 执行代码
# 获取具名参数的值
import argparse
parser = argparse.ArgumentParser()  # 创建参数解析器
parser.add_argument("-tool_params_file_path", "--tool_params_file_path", help="The value for argument 'tool_params_file_path'")
args = parser.parse_args()  # 解析命令行参数
tool_params_file_path = args.tool_params_file_path
if tool_params_file_path is None:
    print(f"{RED}您要获取创建分支信息的信息输入源文件 -tool_params_file_path 不能为空，请检查！{NC}")
    exit(1)
    
chooseUpdateAction(tool_params_file_path)
