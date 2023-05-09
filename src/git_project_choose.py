'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-09 19:33:08
FilePath: git_project_choose.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import os
import re
import shutil

from branchJsonFile_input import inputBranchName
from path_util import joinFullPath
from env_util import getEnvValue_pack_workspace


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
    jenkins_workspace_dir_path=getEnvValue_pack_workspace()
    if jenkins_workspace_dir_path == 1:
        return 1
    # print("文件路径1：", jenkins_workspace_dir_path)
    
    # 获取上级目录，使用 os.path.abspath()函数获取jenkins_workspace文件夹的绝对路径，能有效去除目录路径结尾可能多一个/的问题
    jenkins_workspace_dir_path=os.path.abspath(jenkins_workspace_dir_path)
    jenkins_parent_dir_path = os.path.dirname(jenkins_workspace_dir_path)
    if not os.path.isdir(jenkins_parent_dir_path):
        print(f"{RED}目录jenkins_parent_dir_path={jenkins_parent_dir_path}不存在，请检查{NC}")
        return 1
    

    # 获取第一层文件夹名，如果是文件则不需要
    folder_names = [dir for dir in os.listdir(jenkins_parent_dir_path) if os.path.isdir(os.path.join(jenkins_parent_dir_path, dir))]
    
    # 打印第一层的文件夹列表
    print("文件夹列表：")
    for i, folder_name in enumerate(folder_names):
        print(f"{i+1}. {os.path.basename(folder_name)}")


    while True:
        user_input = input("请输入想要操作的文件名（输入Q或q退出）：")
        if user_input.lower() == 'q':
            exit(2)
            break
        elif user_input not in [os.path.basename(folder_name) for folder_name in folder_names]:
            print(f"{RED}目录不存在，请重新输入{NC}")
            continue
        else:
            git_project_folder_path = joinFullPath(jenkins_parent_dir_path, user_input)
            git_project_folder_path = os.path.abspath(git_project_folder_path)
            print(f"{user_input} 文件夹存在，路径为：{git_project_folder_path}")
            break
    return git_project_folder_path





    
    
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
    if git_project_dir_path == 1:
        return 1
    
    refs_remotes_dir_relpath=".git/refs/remotes"
    refs_remotes_dir_abspath = joinFullPath(git_project_dir_path, refs_remotes_dir_relpath)
    
    
    if checkShouldContinue_project_dir(git_project_dir_path) == 1:
        return 1
    
    # 删除空文件夹
    os.rmdir(git_project_dir_path)
    # 删除非空文件夹
    shutil.rmtree(git_project_dir_path)
    
    
removeJsonByInputName()