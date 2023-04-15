'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-13 18:14:41
FilePath: /branchJsonFile_create/branchInfoManager.py
Description: git工具
'''
# -*- coding: utf-8 -*-

import subprocess

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