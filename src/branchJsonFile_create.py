'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-20 13:48:49
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-python
'''
# -*- coding: utf-8 -*-
import os
import json
import subprocess
from datetime import datetime
import re

from path_util import joinFullPath_noCheck
from env_util import getEnvValue_project_dir_path, getEnvValue_branch_json_file_dir_path
from git_util import get_currentBranchFullName
from branchJsonFile_input import inputOutline, chooseAnswer, chooseTester

import getpass
username = getpass.getuser()
# print("当前登录用户的用户名是：{}\n".format(username))


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


project_dir = getEnvValue_project_dir_path()
print("当前项目目录===========：", project_dir)


branch_json_file_dir_path = getEnvValue_branch_json_file_dir_path()
if branch_json_file_dir_path == None:
    exit(1)


def create_branch_json_file():
    os.chdir(project_dir)  # 修改当前 Python 进程的工作目录

    currentBranchFullName = get_currentBranchFullName()
    print(f"当前分支全名： {BLUE}{currentBranchFullName}{NC}\n")

    parts = currentBranchFullName.split("/")
    branchShortName = parts[-1]
    if len(parts) >= 2:
        branchType = parts[-2]
    else:
        # branchType = None
        branchType = "unkonw"

    # print("分支类型 = {}, 分支简名 = {}".format(branchType, branchShortName))
    jsonFileName = f"{branchType}_{branchShortName}.json"

    file_path = joinFullPath_noCheck(branch_json_file_dir_path, jsonFileName)
    # print("等下要在以下路径创建的json文件：\033[1;31m{}\033[0m\n".format(file_path))

    create(branchType, currentBranchFullName, file_path)




def create(branchType, branchFullName, file_path):
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
        print(f"无法找到开发者{YELLOW}{username}{NC}的映射，将其设置为未知开发者。{NC}")

    # 1、分支描述
    outlineMap = inputOutline()

    # 2、需求方信息
    answerName = chooseAnswer()

    # 3、测试方信息
    testerName = chooseTester()

    json_data = {
        "create_time": cur_date,
        "submit_test_time": "null",
        "pass_test_time": "null",
        "merger_pre_time": "null",
        "type": branchType,
        "name": branchFullName,
        "des": "详见outlines",
        "outlines": [
            outlineMap
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

    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', file_path])


create_branch_json_file()
