'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-18 06:07:58
FilePath: src/dealScriptByCustomChoose_util.py
Description: 打包-输入
Example: 通过 python3 "/Users/lichaoqian/Project/CQCI/script-branch-json-file/src/dealScriptByCustomChoose.py"
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json
import sys

def get_qbase_python_module_path():
    import shutil
    qbase_path = shutil.which('qbase')
    if qbase_path:
        qbase_real_path = os.path.realpath(qbase_path)
        qbase_dir = os.path.dirname(qbase_real_path)
        return os.path.join(qbase_dir, 'pythonModuleSrc')
    return None

qbase_python_path = get_qbase_python_module_path()
if qbase_python_path and os.path.isdir(qbase_python_path):
    sys.path.insert(0, qbase_python_path)
    from dealScript_by_scriptConfig import getRealScriptOrCommandFromData
else:
    raise ImportError("Cannot find qbase pythonModuleSrc directory")

from base_util import openFile
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