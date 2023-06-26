###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-25 16:40:56
# @FilePath: src/decompile_apk.sh
# @Description: 反编译
###


import os
import sys
import subprocess
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


# 二、使用
jadxBinHomeDirPath="/Users/qian/Downloads/jadx-1.4.7"
jadx_gui_BinFilePath = joinFullPath_checkExsit(jadxBinHomeDirPath, "bin/jadx-gui")
if jadx_gui_BinFilePath==None:
    print(f"{RED}Error:bin文件 {YELLOW}{jadx_gui_BinFilePath} {RED}不存在，请检查。{NC}")
    sys.exit(1)



supportCustomString="apk文件路径"
apk_file_path = input_custom_path(f"请输入想要操作的{supportCustomString}（输入Q或q退出）：", customPathType=CustomPathType.FILE)
# apk_file_path="/Users/qian/Project/Bojue/未命名文件夹/app-release_100_jiagu.apk"


def execjadx_gui(apk_file_path):
    if not os.path.isfile(apk_file_path):
        print(f"{RED}Error:apk文件 {YELLOW}{apk_file_path} {RED}不存在，请检查。{NC}")
        sys.exit(1)

    # 获取文件名
    apk_file_name = os.path.basename(apk_file_path)
    apk_inDir_path=os.path.dirname(os.path.abspath(apk_file_path))
    output_cache_dir_path = os.path.join(apk_inDir_path, f"{apk_file_name}.cache")

    # 调用系统命令打开文件
    subprocess.call([jadx_gui_BinFilePath, apk_file_path])

    # command=["sh", dex2jar_script_file_path, wait_change_dex_file_path, "-o", output_cache_dir_path]
    # resultCode=callScriptCommond(command, dex2jar_script_file_path, verbose=True)
    # if resultCode==False:
    #     sys.exit(1)
    print(f"{GREEN}恭喜:apk逆向成功，已为你自动打开。且逆向后的源码文件夹路径为 {YELLOW}{output_cache_dir_path} {GREEN}，将为你自动打开。{NC}")
    openFile(output_cache_dir_path)

execjadx_gui(apk_file_path)
