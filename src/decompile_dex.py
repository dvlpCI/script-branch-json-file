'''
Author: dvlproad
Date: 2023-05-24 18:00:48
LastEditors: dvlproad
LastEditTime: 2023-06-26 09:45:52
Description: 反编译dex
'''
#!/bin/bash

import os
import sys
from path_util import joinFullPath_checkExsit
from common_input import input_custom_path, CustomPathType
from path_choose_util import show_and_choose_file_in_dir
from base_util import openFile, callScriptCommond


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 1、branchJsonName_input 分支json文件名的输入
quit_strings=["q", "Q", "quit", "Quit", "n"]  # 输入哪些字符串算是想要退出

last_arg=sys.argv[-1]  # 获取最后一个参数
verbose_strings=[ "--verbose", "-verbose" ]  # 输入哪些字符串算是想要日志
if last_arg in verbose_strings:
    verbose = True
else:
    verbose = False

def log_msg(msg):
    if verbose:
        print(msg)

# brew install apktool

# https://github.com/pxb1988/dex2jar

# 



# 二、使用
dex_tool_dir_path = "/Users/qian/Downloads/dex-tools-2.1"
# dex
dex2jar_script_file_path = joinFullPath_checkExsit(dex_tool_dir_path, "d2j-dex2jar.sh")
if dex2jar_script_file_path==None:
    print(f"{RED}Error:缺少脚本文件 {YELLOW}{dex2jar_script_file_path} {RED}，请检查。{NC}")
    sys.exit(1)



supportCustomString="dex所在目录路径/dex文件路径"
git_project_folderOrFile_path = input_custom_path(f"请输入想要操作的{supportCustomString}（输入Q或q退出）：", customPathType=CustomPathType.BOTH)
if os.path.isdir(git_project_folderOrFile_path):
    wait_change_dex_file_path=show_and_choose_file_in_dir(git_project_folderOrFile_path, '.dex')
else:
    wait_change_dex_file_path=git_project_folderOrFile_path
# wait_change_dex_file_path = "/Users/qian/Project/Bojue/未命名文件夹/app-release/classes.dex"


wait_change_project_dir=os.path.dirname(os.path.abspath(wait_change_dex_file_path))



def execdex2jar(wait_change_dex_file_path):
    if not os.path.isfile(wait_change_dex_file_path):
        print(f"{RED}Error:文件 {YELLOW}{wait_change_dex_file_path} {RED}不存在，请检查。{NC}")
        sys.exit(1)
    output_dex_file_path = os.path.join(wait_change_project_dir, "classes-dex2jar.jar")

    command=["sh", dex2jar_script_file_path, wait_change_dex_file_path, "-o", output_dex_file_path]
    resultCode=callScriptCommond(command, dex2jar_script_file_path, verbose=verbose)
    if resultCode==False:
        sys.exit(1)
    print(f"{GREEN}恭喜:dex2jar成功，路径为 {YELLOW}{output_dex_file_path} {GREEN}所在目录 {BLUE}{wait_change_project_dir} {GREEN}，将为你自动打开。{NC}")
    openFile(output_dex_file_path)

execdex2jar(wait_change_dex_file_path)


# smali
# dex2jar_script_file_path = "/Users/qian/Downloads/dex-tools-2.1/d2j-dex2jar.sh"
# wait_change_dex_file_path = os.path.join(wait_change_project_dir, f"{r8}{backportedMethods}{utility}{Boolean}1{hashCode}.smali")