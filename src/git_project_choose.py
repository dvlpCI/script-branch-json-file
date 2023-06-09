'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-14 21:24:14
FilePath: git_project_choose.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import os
import re
import shutil

from path_util import joinFullPath_checkExsit
from env_util import getEnvValue_project_parent_dir_path
from path_choose_util import show_and_choose_folder_in_dir


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 选择git项目文件夹
def choose_git_project_dir_path():
    jenkins_parent_dir_path=getEnvValue_project_parent_dir_path()
    if jenkins_parent_dir_path == None:
        return None
    # print("文件路径123：", jenkins_parent_dir_path)

    selected_folder_map=show_and_choose_folder_in_dir(jenkins_parent_dir_path)
    selected_folder_abspath=selected_folder_map['path']
    return selected_folder_abspath

    
    
# def removeJsonByName(file_path, removeBranchName):
#     # 打开JSON文件
#     with open(file_path, 'r') as f:
#         data = json.load(f)

#     # 从package_merger_branchs数组中删除name为'dev_login_err'的JSON对象
#     data['package_merger_branchs'] = [obj for obj in data['package_merger_branchs'] if obj['name'] != removeBranchName]

#     # 保存更新后的JSON文件
#     with open(file_path, 'w') as f:
#         json.dump(data, f, indent=2, ensure_ascii=False)
        
def checkShouldContinue_project_dir(project_dir_path):
    while True:
        shouldContinue = input(f"您当前的路径是{RED}{project_dir_path}{NC}，请确认是否删除该git的远程缓存分支.[继续y/退出n] : ")
        if shouldContinue.lower() == 'y':
            break
        elif shouldContinue.lower() == 'n':
            print(f"放弃操作，将退出")
            exit(2)
        else:
            print(f"字符串{RED}{shouldContinue}{NC}不符合要求，请重新输入[继续y/退出n]\n")
    return 0

# 请选择操作类型
def removeJsonByInputName(): 
    git_project_dir_path=choose_git_project_dir_path()
    if git_project_dir_path == None:
        # print(f"git_project_dir_path={RED}{git_project_dir_path}{NC}不符合要求\n")
        return 1
    
    # refs_remotes_dir_relpath=".git/refs/remotes"
    # refs_remotes_dir_abspath = joinFullPath_checkExsit(git_project_dir_path, refs_remotes_dir_relpath)
    
    
    if checkShouldContinue_project_dir(git_project_dir_path) == 1:
        return 1
    
    # 删除空文件夹
    os.rmdir(git_project_dir_path)
    # 删除非空文件夹
    shutil.rmtree(git_project_dir_path)
    
    
removeJsonByInputName()