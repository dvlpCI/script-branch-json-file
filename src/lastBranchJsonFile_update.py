'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-09 19:44:51
FilePath: lastBranchJsonFile_update.py
Description: 分支Json文件的信息更新
'''
# -*- coding: utf-8 -*-
import json
import os
import re

from branchJsonFile_input import inputBranchName
from path_util import joinFullPath
from env_util import getEnvValue_pack_workspace


# 定义颜色常量
RED = "\033[31m"
NC = "\033[0m"



def choose_last_branchs_info_file_path():
    jenkins_workspace_dir_path=getEnvValue_pack_workspace()
    if jenkins_workspace_dir_path == 1:
        return 1
    # print("文件路径1：", jenkins_workspace_dir_path)
    
    # 获取上级目录，使用 os.path.abspath()函数获取jenkins_workspace文件夹的绝对路径，能有效去除目录路径结尾可能多一个/的问题
    jenkins_workspace_dir_path=os.path.abspath(jenkins_workspace_dir_path)
    last_branchs_info_dir_path = os.path.dirname(jenkins_workspace_dir_path)
    if not os.path.isdir(last_branchs_info_dir_path):
        print(f"{RED}目录last_branchs_info_dir_path={last_branchs_info_dir_path}不存在，请检查{NC}")
        return 1
    
    
    # 获取testDir文件夹下所有JSON文件的路径
    # 在这行代码中，f是一个变量名，用于迭代os.listdir(path)函数返回的文件名列表。os.listdir(path)返回指定目录下的所有文件和文件夹的名称列表，然后通过列表推导式[os.path.join(path, f) for f in os.listdir(path) if f.endswith('.json')]筛选出以.json结尾的文件，并使用os.path.join()函数将它们的路径与目录合并。在这个列表推导式中，f代表os.listdir(path)返回的列表中的每个文件名。
    lastBranchsInfo_files = [joinFullPath(last_branchs_info_dir_path, f) for f in os.listdir(last_branchs_info_dir_path) if f.endswith('.json')]
    if lastBranchsInfo_files.__len__ == 0:
        print(f"{RED}目录last_branchs_info_dir_path={last_branchs_info_dir_path}下未找到json类型的文件，请检查{NC}")
        return 1

    # 打印文件列表
    print("文件列表：")
    for i, file in enumerate(lastBranchsInfo_files):
        print(f"{i+1}. {os.path.basename(file)}")


    while True:
        user_input = input("请输入想要操作的文件名（输入Q或q退出）：")
        if user_input.lower() == 'q':
            exit(2)
            break
        elif not re.match(r'^[a-zA-Z0-9_]+\.[jJ][sS][oO][nN]$', user_input):
            print(f"{RED}输入的{user_input}不是JSON文件名，请重新输入{NC}")
            continue
        elif user_input not in [os.path.basename(file) for file in lastBranchsInfo_files]:
            print(f"{RED}文件不存在，请重新输入{NC}")
            continue
        else:
            last_branchs_info_file_path = joinFullPath(last_branchs_info_dir_path, user_input)
            last_branchs_info_file_path = os.path.abspath(last_branchs_info_file_path)
            # print(f"{user_input} 文件存在，路径为：{last_branchs_info_file_path}")
            break
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
    if last_branchs_info_file_path == 1:
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
