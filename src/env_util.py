'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-05-19 16:28:00
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import json
import subprocess
from path_util import joinFullPath

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 获取环境变量的值
def getEnvValueByKey(key):
    envValue = os.getenv(key)
    # if key in os.environ:
    #     envValue = os.environ[key]
    #     print(envValue)
    # else:
    #     print("\033[1;31m{}\033[0m environment variable not set".format(envValue))
    print("envValue: \033[1;31m{}\033[0m".format(envValue))
    return envValue

def getEnvValue_params_file_path():
    # return "/Users/qian/Project/CQCI/script-branch-json-file/test/tool_input.json"
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    if tool_params_file_path.startswith('~'):
        tool_params_file_path = os.path.expanduser(tool_params_file_path) # 将~扩展为当前用户的home目录
    return tool_params_file_path

def getEnvValue_params_file_data():
    tool_params_file_path = getEnvValue_params_file_path()
    try:
        with open(tool_params_file_path) as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"{RED}File {tool_params_file_path} not found. {NC}")
        return 1
    except json.JSONDecodeError:
        print(f"{RED}Failed to load JSON data from file {tool_params_file_path} {NC}")
        return 1
    return data


# 获取环境变量的值-项目路径
def getEnvValue_project_dir_path():
    tool_params_file_path = getEnvValue_params_file_path()
    tool_params_file_data = getEnvValue_params_file_data()
    if tool_params_file_data == 1:
        return 1
    project_home_path_rel_this = tool_params_file_data['project_path']['home_path_rel_this']
    project_dir_abspath = joinFullPath(tool_params_file_path, project_home_path_rel_this)
    # print("project_dir_abspath: \033[1;31m{}\033[0m".format(project_dir_abspath))
    return project_dir_abspath
    

# 获取环境变量的值-项目中分支信息文件的存放路径
def getEnvValue_branch_json_file_dir_path():
    branch_json_file_git_home = getEnvValue_project_dir_path()
    
    data = getEnvValue_params_file_data()
    if data == 1:
        return 1
    branch_json_file_dir_relpath = data['branchJsonFile']['BRANCH_JSON_FILE_DIR_RELATIVE_PATH']
    branch_json_file_dir_abspath = joinFullPath(branch_json_file_git_home, branch_json_file_dir_relpath)
    print("branch_json_file_dir_abspath: \033[1;31m{}\033[0m".format(branch_json_file_dir_abspath))
    return branch_json_file_dir_abspath



# 获取工程的所在目录(①用户Jenkins打包机的 打包项目 选择；②要更新哪个打包的历史json文件选择)
def getEnvValue_pack_workspace():
    project_dir_path = getEnvValue_project_dir_path()
    return project_dir_path

    # jenkins_data=data['pack']
    # jenkins_workspace=jenkins_data['workspace']
    # if jenkins_workspace.startswith('~'):
    #     jenkins_workspace = os.path.expanduser(jenkins_workspace) # 将~扩展为当前用户的home目录

    # if not os.path.isdir(jenkins_workspace):
    #     print(f"{RED}目录{jenkins_workspace}不存在，请检查{tool_params_file_path}中的jenkins.workspace字段(已自动为你打开) {NC}")
    #     # 在 macOS 或 Linux 上打开 file_path 文件。
    #     # subprocess.Popen(['open', file_path])
    #     subprocess.Popen(['open', tool_params_file_path])
    #     return 1
    
    # return jenkins_workspace

# branch_json_file_git_home=getEnvValue_project_dir_path()
# getEnvValue_branch_json_file_dir_path()
getEnvValue_project_dir_path()