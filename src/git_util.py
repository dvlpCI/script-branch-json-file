'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-19 16:36:32
FilePath: git_util.py
Description: git工具
'''
# -*- coding: utf-8 -*-

import subprocess
import os
from path_util import joinFullPath
from env_util import getEnvValue_project_dir_path, getEnvValue_branch_json_file_dir_path

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
        print("您的分支还是\033[1;31m{}\033[0m未切换到可编码分支，请检查：\n".format(currentBranchFullName))
        exit(1)

    # 提取分支名称
    if currentBranchFullName.startswith('refs/heads/'):
        currentBranchFullName = currentBranchFullName[len('refs/heads/'):]
    
    return currentBranchFullName

project_dir=getEnvValue_project_dir_path()
branch_json_file_dir_path = getEnvValue_branch_json_file_dir_path()


def get_branch_json_file_path():
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

    file_path = joinFullPath(branch_json_file_dir_path, jsonFileName)
    print("要更新的json文件：\033[1;31m{}\033[0m\n".format(file_path))
    if not os.path.exists(file_path):
        print("Error❌:在\033[1;31m{}\033[0m分支中不存在\033[1;31m{}\033[0m文件，请检查！\n".format(currentBranchFullName, file_path))
        exit(1)
    else:
        return file_path

