###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-25 16:40:56
# @FilePath: src/decompile_apk.sh
# @Description: 反编译 [jadx](https://github.com/skylot/jadx)
###


import os
import sys
import subprocess
import threading
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


# 二、使用
# 检查 jadx 是否已经安装
# 安装 jadx 的方法一：
# jadxBinHomeDirPath="/Users/qian/Downloads/test111/jadx-1.4.7"
jadxBinHomeDirPath="/Applications/jadx-1.4.7"

def check_and_get_jadxBinHome():
    jadxHome_path_inApplication=_get_Application_jadxHome_path()
    jadxHome_path_inHomebrew=_get_brew_jadxHome_path()
    
    if jadxHome_path_inHomebrew!=None:
        return joinFullPath_checkExsit(jadxHome_path_inHomebrew, "bin/jadx-gui")
    
    if jadxHome_path_inApplication!=None:
        return joinFullPath_checkExsit(jadxHome_path_inApplication, "bin/jadx-gui")
    
    print(f"{YELLOW}温馨提示：您还未在 {BLUE}Application {YELLOW}或 {BLUE}Homebrew {YELLOW}上安装 {BLUE}jadx {YELLOW},将自动为你在 {BLUE}Homebrew {YELLOW}中安装。")
    jadx_gui_BinFilePath=install_jadx_byHomebrew()
    return jadx_gui_BinFilePath

    

def _get_Application_jadxHome_path():
    if not os.path.exists(jadxBinHomeDirPath):
        return None
    # print(f"{jadxBinHomeDirPath}目录已存在。")
    return jadxBinHomeDirPath
    
    
def _get_brew_jadxHome_path():
    result = subprocess.run(["which", "jadx"], stdout=subprocess.PIPE)
    if result.returncode != 0:
        print("jadx未安装，将使用brew命令安装...")
        return None
    # 获取jadx的安装目录
    result = subprocess.run(["brew", "--prefix", "jadx"], stdout=subprocess.PIPE)
    jadx_dir = result.stdout.decode("utf-8").strip()
    return jadx_dir


def install_jadx_byCustomDownload():
    import urllib.request
    import zipfile
    if not os.path.exists(jadxBinHomeDirPath):
        print(f"{jadxBinHomeDirPath}目录不存在，将从GitHub上下载jadx-1.4.7.zip文件并解压到此目录下...")
        download_url = "https://github.com/skylot/jadx/releases/download/v1.4.7/jadx-1.4.7.zip"
        download_path = os.path.join(os.getcwd(), "jadx-1.4.7.zip")
        urllib.request.urlretrieve(download_url, download_path)
        with zipfile.ZipFile(download_path, 'r') as zip_ref:
            zip_ref.extractall(jadxBinHomeDirPath)
        os.remove(download_path)
        print("下载并解压完成。")
        # 使用subprocess模块打开目录
        subprocess.call(["open", jadxBinHomeDirPath])

        jadx_gui_BinFilePath = joinFullPath_checkExsit(jadxBinHomeDirPath, "bin/jadx-gui")
        if jadx_gui_BinFilePath==None:
            print(f"{RED}Error:bin文件 {YELLOW}{jadx_gui_BinFilePath} {RED}不存在，请检查。{NC}")
            sys.exit(1)
        # 给文件添加可执行权限
        import stat
        os.chmod(jadx_gui_BinFilePath, os.stat(jadx_gui_BinFilePath).st_mode | stat.S_IEXEC)
        return jadx_gui_BinFilePath
    # else:
    #     print(f"{jadxBinHomeDirPath}目录已存在。")

# 安装 jadx 的方法二：
def install_jadx_byHomebrew():
    result = subprocess.run(["which", "jadx"], stdout=subprocess.PIPE)
    if result.returncode == 0:
        print("jadx已经安装。")
    else:
        print("jadx未安装，将使用brew命令安装...")
        subprocess.run(["brew", "install", "jadx"])
        print("jadx安装完成。")

    # 获取jadx的安装目录
    result = subprocess.run(["brew", "--prefix", "jadx"], stdout=subprocess.PIPE)
    jadx_dir = result.stdout.decode("utf-8").strip()

    # 输出jadx_gui_BinFilePath文件路径
    jadx_gui_BinFilePath = os.path.join(jadx_dir, "bin", "jadx-gui")
    print(f"jadx_gui_BinFilePath文件路径为: {jadx_gui_BinFilePath}")

    # 打开jadx的安装目录
    subprocess.call(["open", jadx_dir])
    return jadx_gui_BinFilePath





using_jadx_gui_Bin_FilePath=check_and_get_jadxBinHome()
print(f"{YELLOW}温馨提示：反编译过程将使用{BLUE}{using_jadx_gui_Bin_FilePath} {YELLOW}中的jadx进行处理。")



apk_file_path=show_and_choose_file_from_currentDir('.apk')
# supportCustomString="apk文件路径"
# apk_file_path = input_custom_path(f"请输入想要操作的{supportCustomString}（输入Q或q退出）：", customPathType=CustomPathType.FILE)
# apk_file_path="/Users/qian/Project/Bojue/未命名文件夹/app-release_100_jiagu.apk"


def execjadx_gui(apk_file_path):
    if not os.path.isfile(apk_file_path):
        print(f"{RED}Error:apk文件 {YELLOW}{apk_file_path} {RED}不存在，请检查。{NC}")
        sys.exit(1)

    # 获取文件名
    apk_file_name = os.path.basename(apk_file_path)
    apk_inDir_path=os.path.dirname(os.path.abspath(apk_file_path))
    output_cache_dir_path = os.path.join(apk_inDir_path, f"{apk_file_name}.cache")

    print(f"{GREEN}提示:正在进行apk逆向，请稍候...(逆向后的源码文件夹路径为 {YELLOW}{output_cache_dir_path} {GREEN}。){NC}")
    # 调用系统命令打开文件
    subprocess.call([using_jadx_gui_Bin_FilePath, apk_file_path])
    print(f"{GREEN}恭喜:apk逆向结束，逆向结果的源码文件夹路径为 {YELLOW}{output_cache_dir_path} {GREEN}，已为你自动打开。{NC}")
    openFile(output_cache_dir_path)
    
    # proc = subprocess.Popen([using_jadx_gui_Bin_FilePath, apk_file_path])  # 调用系统命令打开GUI软件并打开指定文件    
    # # 在新线程中等待GUI软件退出，并输出日志信息
    # def print_success_message():
    #     proc.communicate()
        
    # threading.Thread(target=print_success_message).start()


execjadx_gui(apk_file_path)
