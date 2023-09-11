'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-01 15:10:42
FilePath: lastBranchJsonFile_update.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import os
import re

from branchJsonFile_input import inputBranchName
from path_util import joinFullPath_checkExsit
from env_util import getEnvValue_project_parent_dir_path
from path_choose_util import show_and_choose_file_in_dir


# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'



def choose_last_branchs_info_file_path():
    last_branchs_info_dir_path=getEnvValue_project_parent_dir_path()
    if last_branchs_info_dir_path == None:
        return None
    # print("文件路径1：", last_branchs_info_dir_path)
    
    last_branchs_info_file_path=show_and_choose_file_in_dir(last_branchs_info_dir_path, '.json')
    return last_branchs_info_file_path





    
    
def removeJsonByName(file_path, removeBranchName):
    # 打开JSON文件
    with open(file_path, 'r') as f:
        data = json.load(f)

    # 从package_merger_branchs数组中删除name为'dev_login_err'的JSON对象
    data['package_merger_branchs'] = [obj for obj in data['package_merger_branchs'] if obj['name'] != removeBranchName]

    # 保存更新后的JSON文件
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        

# 请选择操作类型
def removeJsonByInputName(): 
    last_branchs_info_file_path=choose_last_branchs_info_file_path()
    if last_branchs_info_file_path == None:
        return 1
    print("您等下将在以下文件里删除分支名：\033[1;31m{}\033[0m\n".format(last_branchs_info_file_path))
    
    print("文件中的分支名列表：")
    with open(last_branchs_info_file_path) as f:
        data = json.load(f)
    # 获取package_merger_branchs数组
    branchs = data['package_merger_branchs']
    for i, branch in enumerate(branchs):
        print(f"{i+1}. {branch['name']}")
    
    branchName_input=inputBranchName()
    print("您等下将要删除的分支名为：\033[1;31m{}\033[0m\n".format(branchName_input))
    removeJsonByName(last_branchs_info_file_path, branchName_input)
    
    
removeJsonByInputName()
