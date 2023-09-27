'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-09-27 15:04:25
FilePath: src/dealScriptByCustomChoose_util.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json

from base_util import openFile
from path_util import getAbsPathByFileRelativePath
from env_util import check_command, get_json_file_data, getEnvValue_params_file_path, getEnvValue_project_dir_path


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



# 1、展示 所有自定义的脚本中 并在选择便后后，并进行选择输出
def chooseCustomScriptFromFilePaths(custom_script_files_abspath, shouldCheckExist=False):
    print(f"")
    script_info_maps=[]
    for i, custom_script_file_abspath in enumerate(custom_script_files_abspath):
        script_info_map=_get_custom_script_file_map(custom_script_file_abspath) # 会检查脚本文件是不是存在
        if script_info_map==False:
            return None
        # print(f"script_info_map={script_info_map}")
        script_file_des = script_info_map['script_file_des']
        # des_length = sum(2 if ord(c) > 127 else 1 for c in script_file_des)  # 计算中英文字符长度
        placeHolder=""
        print(f"{i+1}. {BLUE}{script_file_des:<{15}}{NC} ({BLUE}{script_info_map['script_file_abspath']}{NC})\n{YELLOW}{placeHolder:<{23}}(来源于:{NC}{script_info_map['script_info_abspath']})")
        script_info_maps.append(script_info_map)

    if len(script_info_maps) == 1:
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
            if index >= len(script_info_maps):
                continue
            else:
                chooseScriptIndex = index
                break
        
    chooseScriptMap = script_info_maps[chooseScriptIndex]
    chooseScriptMapName = chooseScriptMap["script_file_des"]
    chooseScriptFilePath=chooseScriptMap["script_info_abspath"]
    # print(f"chooseScriptFilePath:{RED}{chooseScriptFilePath} {NC}")
    if shouldCheckExist==True:
        if not os.path.exists(chooseScriptFilePath):
            print(f"{RED}打包参数信息文件 {YELLOW}{chooseScriptFilePath} {RED}不存在，请检查。请检查您的 {YELLOW}{getEnvValue_params_file_path()}{NC} 的 {BLUE}custom_script_files_RELATIVE_HOME{RED} 属性值是否正确。（其会导致计算相对于 {YELLOW}{getEnvValue_project_dir_path()}{RED} 的该属性值路径 {BLUE}{chooseScriptFilePath}{RED} 不存在)。{NC}")
            openFile(getEnvValue_params_file_path())
            return None
        
    print(f"您选择的想要执行的自定义脚本：{YELLOW}{chooseScriptMapName}{NC}")
    return chooseScriptMap


def _get_custom_script_file_map(pack_input_params_file_path):
    if not os.path.exists(pack_input_params_file_path):
        print(f"{RED}您的参数文件(内含脚本及脚本的参数)不存在，请检查 {YELLOW}{pack_input_params_file_path()}{NC}")
        openFile(pack_input_params_file_path())
        return False
    data=get_json_file_data(pack_input_params_file_path)
    if data == None:
        print(f"{RED}发生错误:从{YELLOW}{pack_input_params_file_path}{RED} 文件获取数据失败，请检查{NC}")
        return False
    
    # 1、获取脚本文件
    action_script_file_absPath=getRealScriptOrCommandFromData(data, pack_input_params_file_path)
    if action_script_file_absPath == False:
        return False
    
    # 1、获取脚本文件描述
    if 'action_sript_file_des' not in data:
        print(f"{RED}发生错误:{pack_input_params_file_path} 文件中不存在'action_sript_file_des'键，请检查{NC}")
        return False
    action_sript_file_des=data['action_sript_file_des']
    
    return {
        "script_info_abspath": pack_input_params_file_path,
        "script_file_abspath": action_script_file_absPath, # 执行的脚本文件
        "script_file_des": action_sript_file_des # 执行的脚本文件的描述
    }


# 1、从 fileData 中获取展示可选择的操作，并进行选择输出
def getRealScriptOrCommandFromData(data, pack_input_params_file_path):
    if 'action_sript_bin' in data:
        action_sript_bin=data['action_sript_bin']
        # print(f"这是本地命令{action_sript_bin}")
        # check_command(action_sript_bin) # TODO不正确
        return action_sript_bin
    
    
    # print(f"这不是本地命令，所以将继续寻找实际的脚本")
    if 'action_sript_file_rel_this_dir' not in data:
        print(f"{RED}发生错误:{pack_input_params_file_path} 文件中不存在'action_sript_file_rel_this_dir'键，请检查{NC}")
        return False
    action_sript_file_rel_this_dir=data['action_sript_file_rel_this_dir']
    # 获取脚本的实际绝对路径
    action_script_file_absPath=getAbsPathByFileRelativePath(pack_input_params_file_path, action_sript_file_rel_this_dir)
    if action_script_file_absPath == None or not os.path.isfile(action_script_file_absPath):
        print(f"{RED}发生错误:脚本文件不存在，原因为计算出来的相对目录不存在。请检查您的 {YELLOW}{pack_input_params_file_path}{NC} 中的 {BLUE}action_sript_file_rel_this_dir{RED} 属性值 {BLUE}{action_sript_file_rel_this_dir}{RED} 是否正确。（其会导致计算相对于 {YELLOW}{pack_input_params_file_path}{RED} 的该属性值路径 {BLUE}{action_script_file_absPath}{RED} 不存在)。{NC}")
        openFile(pack_input_params_file_path)
        # print(f"{RED}=======这里报错了，应该要退出方法{NC}")
        return False
    
    return action_script_file_absPath