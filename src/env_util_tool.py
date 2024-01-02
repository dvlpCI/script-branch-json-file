'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 17:16:08
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import json
import subprocess
from path_util import joinFullPath_checkExsit, joinFullUrl

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


def getProject_dir_path_byToolParamFile(tool_params_file_path):
    # print(f"tool_params_file_path======={tool_params_file_path}")
    tool_params_file_data = get_json_file_data(tool_params_file_path)
    if tool_params_file_data == None:
        return None
    project_home_path_rel_this = tool_params_file_data['project_path']['home_path_rel_this_dir']
    tool_params_dir_path = os.path.dirname(tool_params_file_path)
    project_dir_abspath = joinFullPath_checkExsit(tool_params_dir_path, project_home_path_rel_this)
    # print(f"project_dir_abspath:{RED}{project_dir_abspath} {NC}")
    return project_dir_abspath


def getBranch_json_file_dir_path_fromToolParamFile(tool_params_file_path, shouldCheckExist=False):
    tool_params_file_data = get_json_file_data(tool_params_file_path)
    if tool_params_file_data == None:
        return None
    
    branch_json_file_dir_abspath = get_fileOrDirPath_fromToolParamFile(tool_params_file_path, "branchJsonFile.BRANCH_JSON_FILE_DIR_RELATIVE_PATH", shouldCheckExist=shouldCheckExist)
    return branch_json_file_dir_abspath


# 根据键值路径值 keypath 在 tool_params_file_path 的json文件中获取文件或者文件夹路径
def get_fileOrDirPath_fromToolParamFile(tool_params_file_path, keypath, shouldCheckExist=False):
    tool_params_file_data = get_json_file_data(tool_params_file_path)
    if tool_params_file_data == None:
        return None
    
    # 父目录
    branch_json_file_git_home = getProject_dir_path_byToolParamFile(tool_params_file_path)

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
            print(f"{RED}获取相对路径的字段值失败。您的{BLUE} {tool_params_file_path} {RED}文件中，不存在{BLUE} {value} {RED}字段。请修改您在文件{BLUE} {tool_params_file_path} {RED}中的 {hasFoundKeyPath.split('.')} {RED}填写的该拼接参数值{NC}")
            return None
    result_value=value

    # 完整目录
    branch_json_file_dir_abspath = joinFullPath_checkExsit(branch_json_file_git_home, result_value)
    # print(f"branch_json_file_dir_abspath:{RED}{branch_json_file_dir_abspath} {NC}")
    if branch_json_file_dir_abspath == None:
        print(f"{RED}获取要路径失败。您的{BLUE} {branch_json_file_git_home} {RED}项目中，不存在{BLUE} {result_value} {RED}的相对路径。请修改您在文件{BLUE} {tool_params_file_path} {RED}中的 {hasFoundKeyPath.split('.')} {RED}填写的该拼接参数值{NC}")
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