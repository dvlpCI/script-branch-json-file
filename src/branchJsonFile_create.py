'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-18 17:18:04
FilePath: src/branchJsonFile_create.py
Description: 分支JSON文件的创建-python

输入参数：只有只需 json 文件路径，但json必须包含以下字段
{
    "personnel_file_path_rel_this_file": "./tool_input_personel.json",
    "branchJsonFile": {
        "BRANCH_JSON_FILE_DIR_RELATIVE_PATH": "./src/example/featureBrances/",
        "answerAllowId": [
            "developer1"
        ],
        "apierAllowId": [
        ],
        "testerAllowId": [
        ]
    }
}
其中
branchJsonFile.BRANCH_JSON_FILE_DIR_RELATIVE_PATH 表示创建的分支信息要存在哪个位置
branchJsonFile.answerAllowId 等   表示创建分支信息的时候，允许哪些人 role_id 作为需求方、接口人、测试人
personnel_file_path_rel_this_file 表示人员信息文件， answerAllowId 等需要根据 role_id 去这里获取实际姓名方便直观展示

输出结束：一个符合标准结构的分支信息json文件
'''
# -*- coding: utf-8 -*-
import os
import json
import subprocess
from datetime import datetime
import re

from path_util import joinFullPath_noCheck
from env_util_tool import get_fileOrDirPath_fromToolParamFile, getProject_dir_path_byToolParamFile, getBranch_json_file_dir_path_fromToolParamFile
from git_util import get_currentBranchFullName, get_branch_file_name, get_branch_type
from branchJsonFile_input_base_util import getPeopleNameByPersonnel_FILE_PATH, chooseAnswerFromFile, chooseApierFromFile, chooseTesterFromFile, inputOutline

from env_util import getEnvValue_params_file_path

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



def create_branch_json_file():
    os.chdir(project_dir)  # 修改当前 Python 进程的工作目录

    currentBranchFullName = get_currentBranchFullName()
    print(f"当前分支全名：{BLUE} {currentBranchFullName} {NC}\n")

    jsonFileName=get_branch_file_name(currentBranchFullName)
    branchType=get_branch_type(currentBranchFullName)

    file_path = joinFullPath_noCheck(branch_json_file_dir_path, jsonFileName)
    # print("等下要在以下路径创建的json文件：\033[1;31m{}\033[0m\n".format(file_path))

    create(branchType, currentBranchFullName, file_path)




def create(branchType, branchFullName, branch_json_file_path):
    # 创建日期
    cur_date = datetime.now().strftime("%m.%d")

    # 开发者信息
    try:
        # developerName = user_mapping[username]
        developerName = getPeopleNameByPersonnel_FILE_PATH(Personnel_FILE_PATH, "uid", username)
        print(f"当前开发者的用户名是：{RED}{developerName}{NC}\n")
    except KeyError:
        developerName = "unknown"
        print(f"无法找到开发者{YELLOW}{username}{NC}的映射，将其设置为未知开发者。{NC}")

    # 1、分支描述
    outlineMap = inputOutline()

    # 2、需求方信息
    print(f"")
    answerName = chooseAnswerFromFile(tool_params_file_path)
    
    # 3、开发方信息
    print(f"")
    apiName = chooseApierFromFile(tool_params_file_path)

    # 4、测试方信息
    print(f"")
    testerName = chooseTesterFromFile(tool_params_file_path)

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
        "apier": {
            "name": apiName
        },
        "tester": {
            "name": testerName
        }
    }

    # 确保文件夹存在
    os.makedirs(os.path.dirname(branch_json_file_path), exist_ok=True)
    # 打开文件并写入数据
    with open(branch_json_file_path, "w", encoding="utf-8") as json_file:
        json.dump(json_data, json_file, indent=4, ensure_ascii=False)

    # 将文件加入 Git 暂存区
    subprocess.call(["git", "add", branch_json_file_path])
    print(f"已成功创建分支JSON文件：{BLUE} {branch_json_file_path} {NC}")

    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', branch_json_file_path])

# python 的块注释
'''
# 获取具名参数的值
import argparse
parser = argparse.ArgumentParser()  # 创建参数解析器
parser.add_argument("-branch_json_dir_path", "--branch_json_dir_path", help="The value for argument 'branch_json_dir_path'")
parser.add_argument("-personnel_json_file_path", "--personnel_json_file_path", help="The value for argument 'personnel_json_file_path'")
args = parser.parse_args()  # 解析命令行参数
branch_json_dir_path = args.branch_json_dir_path
if branch_json_dir_path is None:
    print(f"{RED}缺少 -branch_json_dir_path 参数，分支信息要存放的目录不能为空，请检查！{NC}")
    exit(1)
personnel_json_file_path = args.personnel_json_file_path
if personnel_json_file_path is None:
    print(f"{RED}缺少 -personnel_json_file_path 参数，为分支信息匹配到精确人员的人员json文件路径不能为空，请检查！{NC}")
    exit(1)

project_dir = getProject_dir_path_byToolParamFile(tool_params_file_path)
print("当前项目目录===========：", project_dir)


branch_json_file_dir_path = getBranch_json_file_dir_path_fromToolParamFile(tool_params_file_path)
if branch_json_file_dir_path == None:
    exit(1)

Personnel_FILE_PATH=get_fileOrDirPath_fromToolParamFile(tool_params_file_path, "personnel_file_path_rel_this_file")
if Personnel_FILE_PATH == None:
    exit(1)
'''
    
# 获取具名参数的值
import argparse
parser = argparse.ArgumentParser()  # 创建参数解析器
parser.add_argument("-tool_params_file_path", "--tool_params_file_path", help="The value for argument 'tool_params_file_path'")
args = parser.parse_args()  # 解析命令行参数
tool_params_file_path = args.tool_params_file_path
if tool_params_file_path is None:
    print(f"{RED}缺少 -tool_params_file_path 参数，您要获取创建分支信息的信息输入源文件不能为空，请检查！{NC}")
    exit(1)

project_dir = getProject_dir_path_byToolParamFile(tool_params_file_path)
print("当前项目目录===========：", project_dir)


branch_json_file_dir_path = getBranch_json_file_dir_path_fromToolParamFile(tool_params_file_path)
if branch_json_file_dir_path == None:
    exit(1)

Personnel_FILE_PATH=get_fileOrDirPath_fromToolParamFile(tool_params_file_path, "personnel_file_path_rel_this_file")
if Personnel_FILE_PATH == None:
    exit(1)

create_branch_json_file()
