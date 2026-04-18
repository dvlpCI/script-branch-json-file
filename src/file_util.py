'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-18 16:11:22
FilePath: file_util.py
Description: 文件检查、文件路径获取
'''
# -*- coding: utf-8 -*-

import os
import json
from path_util import joinFullPath_checkExsit, joinFullUrl

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

def check_file_exists(file_path):
    if not os.path.exists(file_path):
        print('文件不存在，退出脚本')
        exit()
    else:
        print('文件存在，继续执行脚本')
        # 在这里继续执行您的脚本逻辑



# 从 json_file_path 文件中获取 keypath 指向的文件或者文件夹路径，并根据 base_firl_path 获取完整路径
# 
# 说明：基准目录根据 base_firl_path
#   - 只有 base_firl_path 不为None，且该路径存在，才使用该路径作为基准目录
#   - 否则：默认按相对当前文件路径获取
# 
# 参数:
#   json_file_path: 工具参数配置文件路径（如 /path/to/project/test/tool_input.json）
#   keypath: JSON中的键值路径（如 "personnel_file_path" 或 "personnel_file_path_rel_this_file"）
#   base_firl_path: 基准目录路径（默认为None，表示按相对当前文件路径获取。如果有指定 base_firl_path ，且该路径存在，则使用该路径作为基准目录。）
#   shouldCheckExist: 是否检查路径存在（默认False）
def get_fileOrDirPath_fromJsonFileFileAndKey(json_file_path, keypath, base_firl_path=None, shouldCheckExist=False):
    tool_params_file_data = get_json_file_data(json_file_path)
    if tool_params_file_data == None:
        return None
    
    # 如果有指定 base_firl_path ，且该路径存在，则使用该路径作为基准目录。否则按相对当前文件路径获取
    if base_firl_path != None:
        if not os.path.exists(base_firl_path):
            print(f"{RED}你指定了的基准目录路径{BLUE} {base_firl_path} {RED}，但是该路径不存在，请检查{NC}")
            return None
        
        base_dir_path = base_firl_path
    else:
        base_dir_path = os.path.dirname(json_file_path)
        
    # 子目录
    # result_value = tool_params_file_data['branchJsonFile']['BRANCH_JSON_FILE_DIR_RELATIVE_PATH']
    # 按键值路径逐层获取值
    hasFoundKeyPath="" # 已查找到哪一层
    value = tool_params_file_data
    for index, key in enumerate(keypath.split('.')):
        if index > 0:
            hasFoundKeyPath+=f"."
        hasFoundKeyPath+=f"{key}"

        value = value.get(key)
        if value == None:
            print(f"{RED}获取相对路径的字段值失败。您的{BLUE} {json_file_path} {RED}文件中，不存在{BLUE} {key} {RED}字段。请在文件{BLUE} {json_file_path} {RED}中添加 {hasFoundKeyPath.split('.')} {RED}字段{NC}")
            return None
    result_value=value

    # 完整目录
    branch_json_file_dir_abspath = joinFullPath_checkExsit(base_dir_path, result_value)
    # print(f"branch_json_file_dir_abspath:{RED}{branch_json_file_dir_abspath} {NC}")
    if branch_json_file_dir_abspath == None:
        print(f"{RED}获取路径失败。获取{BLUE} {base_dir_path} {RED}相对路径{BLUE} {result_value} {RED}失败。请修改您在文件{BLUE} {json_file_path} {RED}中的 {hasFoundKeyPath.split('.')} {RED}字段值{NC}")
        return None
    
    if shouldCheckExist==False:
        return branch_json_file_dir_abspath
    else:
        if not os.path.exists(branch_json_file_dir_abspath):
            print(f"Error❌: {branch_json_file_dir_abspath} 文件不存在，请检查")
            return None
        else:
            return branch_json_file_dir_abspath
        


def get_json_file_data(json_file_path):
    try:
        with open(json_file_path) as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"{RED}Error: File{YELLOW} {json_file_path} {RED}not found. {NC}")
        return None
    except json.JSONDecodeError:
        print(f"{RED}Error: Failed to load JSON data from file{YELLOW} {json_file_path} {RED}{NC}")
        return None
    return data