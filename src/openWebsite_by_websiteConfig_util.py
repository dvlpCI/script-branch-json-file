'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-28 20:53:15
FilePath: src/openWebsite_by_websiteConfig_util.py
Description: 打开选中的网站
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


def chooseCustomWebsiteAndOpenItFromWebsites(custom_script_files_abspath):
    chooseWebsiteMap=chooseCustomWebsiteFromWebsites(custom_script_files_abspath)
    chooseWebsiteUrl=chooseWebsiteMap["url"]
    openWebsiteByUrl(chooseWebsiteUrl)


# 1、展示 所有自定义的脚本中 并在选择便后后，并进行选择输出
def chooseCustomWebsiteFromWebsites(customWebisteMaps):
    print(f"")
    for i, customWebisteMap in enumerate(customWebisteMaps):
        customWebisteDes = customWebisteMap['des']
        customWebisteUrl = customWebisteMap['url']
        print(f"{i+1}. {BLUE}{customWebisteDes:<{15}}{NC}")
        print(f"   {NC}控制台:{NC}{customWebisteUrl}")

        if "docUrl" in customWebisteMap:
            customWebisteDocUrl = customWebisteMap['docUrl']
            print(f"   {NC}文  档:{customWebisteDocUrl}")
        
        

    if len(customWebisteMaps) == 1:
        chooseScriptIndex=0
    else:
        while True:
            env_input = input("请选择您想要执行的自定义脚本的编号（退出q/Q）：")
            if env_input == "q" or env_input == "Q":
                exit()

            if not env_input.isnumeric():
                print("输入的不是一个数字，请重新输入！")
                continue

            index = int(env_input) - 1
            if index >= len(customWebisteMaps):
                continue
            else:
                chooseScriptIndex = index
                break
        
    chooseWebsiteMap = customWebisteMaps[chooseScriptIndex]
    chooseWebsiteMapDes = chooseWebsiteMap["des"]
    chooseWebsiteMapUrl = chooseWebsiteMap["url"]
        
    print(f"您选择的想要打开的自定义网站：{YELLOW}{chooseWebsiteMapDes}{NC}")
    return chooseWebsiteMap




import subprocess
def openWebsiteByUrl(chooseWebsiteUrl):
# def openFile(file_path):
    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', chooseWebsiteUrl])