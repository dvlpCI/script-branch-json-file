'''
Author: dvlproad
Date: 2023-05-24 18:00:48
LastEditors: dvlproad
LastEditTime: 2023-06-29 16:47:08
Description: 反编译dex
'''
#!/bin/bash

import os
import sys
import subprocess
import shutil
from path_util import joinFullPath_checkExsit
from common_input import input_custom_path, CustomPathType
from path_choose_util import show_and_choose_file_from_currentDir
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



# 二、使用
# dex_tool_dir_path = "/Users/qian/Downloads/dex-tools-2.1"
dex_tool_dir_path="/Applications/dex-tools-2.1"
def install_dextool_byCustomDownload():
    import urllib.request
    import zipfile
    if not os.path.exists(dex_tool_dir_path):
        print(f"{dex_tool_dir_path}目录不存在，将从GitHub上下载dex2jar-2.1.zip文件并解压到此目录下...")
        download_url = "https://github.com/pxb1988/dex2jar/releases/download/v2.1/dex2jar-2.1.zip"
        download_path = os.path.join(os.getcwd(), "dex2jar-2.1.zip")
        # download_path=os.path.join(os.getcwd(), "")
        urllib.request.urlretrieve(download_url, download_path)
        with zipfile.ZipFile(download_path, 'r') as zip_ref:
            zip_ref.extractall(dex_tool_dir_path)
        os.remove(download_path)
        print("下载并解压完成。")

        # 将外部的 dex-tools-2.1 文件夹改名为 dex-tools-2.1-outer
        outer_dex_tool_dir_path = os.path.join(os.path.dirname(dex_tool_dir_path), "dex-tools-2.1-outer")
        os.rename(dex_tool_dir_path, outer_dex_tool_dir_path)
        # 将 dex-tools-2.1 文件夹移动到外部文件夹的位置
        os.rename(os.path.join(outer_dex_tool_dir_path, "dex-tools-2.1"), dex_tool_dir_path)
        # 删除 dex-tools-2.1-outer 文件夹
        os.rmdir(outer_dex_tool_dir_path)

        # 使用subprocess模块打开目录
        subprocess.call(["open", dex_tool_dir_path])
        return dex_tool_dir_path
    else:
        # print(f"{dex_tool_dir_path}目录已存在。")
        return dex_tool_dir_path


# jd_gui_app_path="~/Downloads/jd-gui-osx-1.6.6/JD-GUI.app"
jd_gui_app_path="/Applications/JD-GUI.app"
# 判断jd_gui_app_path="/Applications/JD-GUI.app"是否存在,
# 如果不存在继续判断jdguiDownloadDirPath="~/Downloads/jd-gui-osx-1.6.6"是否存在
# 如果仍不存在，则从https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-osx-1.6.6.tar地址下载并解压到jdguiDownloadDirPath目录下。解压结束后，打开该目录。
# def install_jdgui_byCustomDownload():
#     import urllib.request
#     import zipfile
#     if not os.path.exists(jd_gui_app_path):
#         print(f"{jd_gui_app_path}目录不存在，将从GitHub上下载jd-gui-osx-1.6.6.tar文件并解压到此目录下...")
#         download_url = "https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-osx-1.6.6.tar"
#         download_path = os.path.join(os.getcwd(), "jadx-1.4.7.zip")
#         urllib.request.urlretrieve(download_url, download_path)

#         jdguiDownloadDirPath="~/Downloads/jd-gui-osx-1.6.6"
#         with zipfile.ZipFile(download_path, 'r') as zip_ref:
#             zip_ref.extractall(jdguiDownloadDirPath)
#         os.remove(download_path)
#         print("下载并解压完成。")
#         # 使用subprocess模块打开目录
#         subprocess.call(["open", jdguiDownloadDirPath])

#         jd_gui_AppFilePath = joinFullPath_checkExsit(jdguiDownloadDirPath, "JD-GUI.app")
#         if jd_gui_AppFilePath==None:
#             print(f"{RED}Error:app文件 {YELLOW}{jd_gui_AppFilePath} {RED}不存在，请检查。{NC}")
#             sys.exit(1)
#         return jd_gui_AppFilePath
#     # else:
#     #     print(f"{jadxBinHomeDirPath}目录已存在。")



# dex
dex_tool_dir_path=install_dextool_byCustomDownload()

dex2jar_script_file_path = joinFullPath_checkExsit(dex_tool_dir_path, "d2j-dex2jar.sh")
if dex2jar_script_file_path==None:
    print(f"{RED}Error:缺少脚本文件 {YELLOW}{dex2jar_script_file_path} {RED}，请检查。{NC}")
    sys.exit(1)


print(f"{YELLOW}温馨提示：反编译过程将使用{BLUE}{dex2jar_script_file_path} {YELLOW}中的 d2j-dex2jar.sh 进行处理。")
wait_change_dex_file_path=show_and_choose_file_from_currentDir('.dex')


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
    openFile(wait_change_project_dir)
    return output_dex_file_path




def openDex2(jd_gui_app_path, output_dex_file_path):
    if jd_gui_app_path.startswith('~'):
        jd_gui_app_path = os.path.expanduser(jd_gui_app_path) # 将~扩展为当前用户的home目录

    # 调用系统命令打开文件
    subprocess.run(["open", "-a", jd_gui_app_path, output_dex_file_path])
    # print(f"{GREEN}恭喜:apk逆向结束，逆向结果的源码文件夹路径为 {YELLOW}{output_cache_dir_path} {GREEN}，已为你自动打开。{NC}")
    # openFile(output_cache_dir_path)

output_dex_file_path=execdex2jar(wait_change_dex_file_path)
openDex2(jd_gui_app_path, output_dex_file_path)
