'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-04-16 02:52:07
FilePath: /branchJsonFile_create/branchInfoManager.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import os
import json
from datetime import datetime

from env_util import getEnvValue_branch_json_file_git_home, getEnvValue_branch_json_file_dir_path
from git_util import get_gitHomeDir, get_currentBranchFullName
from object_update import update_dict_value
from branchJsonFile_input import chooseAnswer, chooseTester

project_dir=getEnvValue_branch_json_file_git_home()
branch_json_file_dir_path = getEnvValue_branch_json_file_dir_path()

def branch_info():
    os.chdir(project_dir) # 修改当前 Python 进程的工作目录

    currentBranchFullName = get_currentBranchFullName()
    print("当前分支全名：\033[1;31m{}\033[0m\n".format(currentBranchFullName))

    parts = currentBranchFullName.split("/")
    branchShortName = parts[-1]
    if len(parts) >= 2:
        branchType = parts[-2]
    else:
        # branchType = None
        branchType = "unkonw"

    # print("分支类型 = {}, 分支简名 = {}".format(branchType, branchShortName))
    jsonFileName = f"{branchType}_{branchShortName}.json"

    file_path = f"{branch_json_file_dir_path}/{jsonFileName}"
    # print("等下要在以下路径创建的json文件：\033[1;31m{}\033[0m\n".format(file_path))
    if not os.path.exists(file_path):
        print("Error❌:在\033[1;31m{}\033[0m分支中不存在\033[1;31m{}\033[0m文件，请检查！\n".format(currentBranchFullName, file_path))
        exit(1)

    chooseUpdateAction(file_path)


# 请选择操作类型
def chooseUpdateAction(file_path): 
    # 更新操作的类型
    updateAction_mapping = {
        "0": "更改人员信息",
        "1": "添加信息",
        "2": "更新测试通过日期和合入日期"
    }
    for key, value in updateAction_mapping.items():
        print(key, value)
    print("请选择操作类型：", end="")
    updateAction_input = input()
    updateActionDes = updateAction_mapping[updateAction_input]
    # print("key = {}, value = {}".format(updateAction_input, updateActionDes))
    print("您选择操作类型：\033[1;31m{}\033[0m\n".format(updateActionDes))
    
    if updateAction_input == "0":
        answerName=chooseAnswer()
        change("answer.name", f"{answerName}", file_path)

        testerName=chooseTester()
        change("tester.name", f"{testerName}", file_path)

    elif updateAction_input == "1":
        cur_date = datetime.now().strftime("%m.%d")
        change("pass_test_time", f"{cur_date}", file_path)

    elif updateAction_input == "2":
        cur_date = datetime.now().strftime("%m.%d")
        change("pass_test_time", f"{cur_date}", file_path)
        change("merger_pre_time", f"{cur_date}", file_path)

    

def change(key, value, file_path):
    with open(file_path, "r+") as json_file:
        json_data = json.load(json_file)
        # json_data[key] = value
        update_dict_value(json_data, key, value)
        json_file.seek(0)
        json.dump(json_data, json_file, indent=4, ensure_ascii=False)
        json_file.truncate()
    print(f"已成功更新字段 {key} 为 {value} 在文件 {file_path}")


branch_info()
