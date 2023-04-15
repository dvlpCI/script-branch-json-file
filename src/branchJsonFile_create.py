'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-14 14:25:09
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-python
'''
# -*- coding: utf-8 -*-
import os
import json
import subprocess
from datetime import datetime

from git_util import get_gitHomeDir, get_currentBranchFullName
from branchJsonFile_input import chooseAnswer, chooseTester

import getpass
username = getpass.getuser()
# print("当前登录用户的用户名是：{}\n".format(username))


project_dir=get_gitHomeDir()
print("当前项目目录：", project_dir)


def create_branch_json_file():
    os.chdir(project_dir) # 修改当前 Python 进程的工作目录

    currentBranchFullName = get_currentBranchFullName()
    print("当前分支全名：\033[1;31m{}\033[0m\n".format(currentBranchFullName))

    parts = currentBranchFullName.split("/")
    branchShortName = parts[-1]
    branchType = parts[-2]
    # print("分支类型 = {}, 分支简名 = {}".format(branchType, branchShortName))
    jsonFileName = f"{branchType}_{branchShortName}.json"

    file_path = f"{project_dir}/featureBrances/{jsonFileName}"
    # print("等下要在以下路径创建的json文件：\033[1;31m{}\033[0m\n".format(file_path))
    
    create(branchType, branchShortName, file_path)



def create(branchType, branchShortName, file_path):
    # 创建日期
    cur_date = datetime.now().strftime("%m.%d")

    # 开发者信息
    user_mapping = {
        "lichaoqian": "qian",
        "2": "hotfix",
        "3": "optimize",
        "4": "other"
    }
    try:
        developerName = user_mapping[username]
        print("当前开发者的用户名是：\033[1;31m{}\033[0m\n".format(developerName))
    except KeyError:
        developerName = "unknown"
        print("无法找到开发者\033[1;31m{}\033[0m的映射，将其设置为未知开发者。\n".format(username))


    # 1、分支描述
    while True:
        try:
            # 尝试使用 UTF-8 编码解码用户输入
            branchDes = input("请输入分支描述：") or "null"
            break  # 如果解码成功，则跳出循环
        except UnicodeDecodeError:
            print("输入的编码不是 UTF-8，请重新输入。")
    print("输入的分支描述：\033[1;31m{}\033[0m\n".format(branchDes))

    # 2、需求方信息
    answerName = chooseAnswer()
   
    # 3、测试方信息
    testerName=chooseTester()

    json_data = {
        "create_time": cur_date,
        "submit_test_time": "null",
        "pass_test_time": "null",
        "merger_pre_time": "null",
        "type": branchType,
        "name": branchShortName,
        "des": "详见outlines",
        "outlines": [
            {"title": branchDes}
        ],
        "answer": {
            "name": answerName
        },
        "tester": {
            "name": testerName
        }
    }
    
    # 确保文件夹存在
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    # 打开文件并写入数据
    with open(file_path, "w", encoding="utf-8") as json_file:
        json.dump(json_data, json_file, indent=4, ensure_ascii=False)

    # 将文件加入 Git 暂存区
    subprocess.call(["git", "add", file_path])
    print(f"已成功创建分支JSON文件：\033[1;32m{file_path}\033[0m")

create_branch_json_file()
