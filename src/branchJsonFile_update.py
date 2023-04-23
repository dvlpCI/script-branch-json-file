'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-23 13:17:54
FilePath: branchJsonFile_update.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import subprocess
from datetime import datetime

from git_util import get_branch_json_file_path
from object_update import update_dict_value
from branchJsonFile_input import inputOutline, chooseAnswer, chooseTester

def branch_info():
    branch_json_file_path=get_branch_json_file_path()
    chooseUpdateAction(branch_json_file_path)


# 请选择操作类型
def chooseUpdateAction(file_path): 
    # 更新操作的类型
    updateAction_mapping = {
        "1": "更改人员信息(需求方/测试方)",
        "2": "添加信息",
        "3": "更新提测开始日期",
        "4": "更新测试通过日期和合入日期"
    }
    for key, value in updateAction_mapping.items():
        print(key, value)
    print("请选择操作类型：", end="")
    updateAction_input = input()
    updateActionDes = updateAction_mapping[updateAction_input]
    # print("key = {}, value = {}".format(updateAction_input, updateActionDes))
    print("您选择操作类型：\033[1;31m{}\033[0m\n".format(updateActionDes))
    
    if updateAction_input == "1":
        answerName=chooseAnswer()
        change("answer.name", f"{answerName}", file_path)

        testerName=chooseTester()
        change("tester.name", f"{testerName}", file_path)

    elif updateAction_input == "2":
        outlineMap = inputOutline()
        addOutline(file_path, outlineMap)

    elif updateAction_input == "3":
        cur_date = datetime.now().strftime("%m.%d")
        change("submit_test_time", f"{cur_date}", file_path)

    elif updateAction_input == "4":
        cur_date = datetime.now().strftime("%m.%d")
        change("pass_test_time", f"{cur_date}", file_path)
        change("merger_pre_time", f"{cur_date}", file_path)

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
        update_dict_value(json_data, key, value)
        json_file.seek(0)
        json.dump(json_data, json_file, indent=4, ensure_ascii=False)
        json_file.truncate()
    # print(f"已成功更新字段 {key} 为 {value} 在文件 {file_path}")


branch_info()
