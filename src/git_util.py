'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-19 16:36:32
FilePath: git_util.py
Description: git工具
'''
# -*- coding: utf-8 -*-

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

import subprocess
import os
from path_util import joinFullPath_checkExsit
from env_util import getEnvValue_params_file_path
from env_util_tool import getProject_dir_path_byToolParamFile, getBranch_json_file_dir_path_fromToolParamFile

def get_gitHomeDir():
    git_output = subprocess.check_output(['git', 'rev-parse', '--show-toplevel'], text=True)
    gitHomeDir_Absolute = git_output.strip() # 删除输出中的换行符，以获取仓库根目录的绝对路径
    # print("Git 仓库根目录的绝对路径：", gitHomeDir_Absolute)
    return gitHomeDir_Absolute

def get_currentBranchFullName():
    try:
        currentBranchFullName = subprocess.check_output(['git', 'symbolic-ref', '--short', '-q', 'HEAD'], text=True).strip()
        print("当前分支名称为:", currentBranchFullName)
    except subprocess.CalledProcessError as e:
        currentBranchFullName="unknow"
        print("Git命令执行失败:", e.returncode)
        print("标准输出:", e.output)
        print("标准错误输出:", e.stderr)

    if currentBranchFullName=="master":
        print(f"您的分支还是{BLUE}{currentBranchFullName}{NC}未切换到可编码分支，请检查：\n")
        exit(1)

    # 提取分支名称
    if currentBranchFullName.startswith('refs/heads/'):
        currentBranchFullName = currentBranchFullName[len('refs/heads/'):]
    
    return currentBranchFullName



def get_branch_type(fullBranchName):
    parts = fullBranchName.split("/")
    branchShortName = parts[-1]
    if len(parts) >= 2:
        branchType = parts[-2]
    else:
        # branchType = None
        branchType = "unkonw"
    return branchType

def get_branch_file_name(fullBranchName):
    parts = fullBranchName.split("/")
    branchShortName = parts[-1]
    if len(parts) >= 2:
        branchType = parts[-2]
        jsonFileName = f"{branchType}_{branchShortName}.json"
    else:
        branchType = "unkonw"
        jsonFileName = f"{branchShortName}.json"

    return jsonFileName

def get_branch_json_file_path():
    tool_params_file_path = getEnvValue_params_file_path()
    return get_branch_json_file_path_byToolParamFile(tool_params_file_path)
    
def get_branch_json_file_path_byToolParamFile(tool_params_file_path):
    # print(f"tool_params_file_path ======= {tool_params_file_path}")
    
    project_dir = getProject_dir_path_byToolParamFile(tool_params_file_path)
    if project_dir == None:
        return None
    os.chdir(project_dir) # 修改当前 Python 进程的工作目录
    
    branch_json_file_dir_path = getBranch_json_file_dir_path_fromToolParamFile(tool_params_file_path)
    if branch_json_file_dir_path == None:
        return None

    currentBranchFullName = get_currentBranchFullName()
    print(f"当前分支全名：{BLUE}{currentBranchFullName}{NC}\n")

    jsonFileName=get_branch_file_name(currentBranchFullName)
    print(f"当前分支信息文件的文件名：{BLUE}{jsonFileName}{NC}\n")

    file_path = joinFullPath_checkExsit(branch_json_file_dir_path, jsonFileName)
    if file_path == None:
        print(f"未找到要更新的json文件：{BLUE}{file_path}{NC}\n")
        exit(1)

    print(f"要更新的json文件：{BLUE}{file_path}{NC}\n")
    if not os.path.exists(file_path):
        print(f"Error❌:在{BLUE}{currentBranchFullName}{NC}分支中不存在{BLUE}{file_path}{NC}文件，请检查！\n")
        exit(1)
    else:
        return file_path

# get_branch_json_file_path()
