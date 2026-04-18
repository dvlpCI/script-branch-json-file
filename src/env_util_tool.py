'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-18 16:15:08
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os

import subprocess
from file_util import get_fileOrDirPath_fromJsonFileFileAndKey, get_json_file_data, joinFullPath_checkExsit

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
# 
# 说明：基准目录根据 keypath 后缀决定
#   - 如果 keypath 以 "_rel_this_file" 结尾：相对于 tool_params_file_path 所在目录
#   - 否则：相对于项目目录（通过 tool_params_file_path.json 中的 project_path.home_path_rel_this_dir 字段计算）
# 
# 参数:
#   tool_params_file_path: 工具参数配置文件路径（如 /path/to/project/test/tool_input.json）
#   keypath: JSON中的键值路径（如 "personnel_file_path" 或 "personnel_file_path_rel_this_file"）
#   shouldCheckExist: 是否检查路径存在（默认False）
def get_fileOrDirPath_fromToolParamFile(tool_params_file_path, keypath, shouldCheckExist=False):
    # 基准目录：根据 keypath 后缀决定
    # - 如果 keypath 以 "_rel_this_file" 结尾：相对于 tool_params_file_path 所在目录
    # - 否则：相对于项目目录
    if keypath.endswith("_rel_this_file"):
        base_dir_path = os.path.dirname(tool_params_file_path)
    else:
        base_dir_path = getProject_dir_path_byToolParamFile(tool_params_file_path)

    branch_json_file_dir_abspath = get_fileOrDirPath_fromJsonFileFileAndKey(tool_params_file_path, keypath, base_dir_path, shouldCheckExist=shouldCheckExist)    
    return branch_json_file_dir_abspath