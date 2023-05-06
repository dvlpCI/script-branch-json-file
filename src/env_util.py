'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-05-06 10:11:29
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import json
import subprocess
from path_util import joinFullPath

# 定义颜色常量
RED = "\033[31m"
NC = "\033[0m"

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


# 获取环境变量的值
def getEnvValue_branch_json_file_git_home():
    branch_json_file_git_home = os.getenv('QTOOL_DEAL_PROJECT_DIR_PATH')
    if branch_json_file_git_home.startswith('~'):
        branch_json_file_git_home = os.path.expanduser(branch_json_file_git_home) # 将~扩展为当前用户的home目录
    return branch_json_file_git_home

# 获取环境变量的值
def getEnvValue_branch_json_file_dir_path():
    branch_json_file_git_home = os.getenv('QTOOL_DEAL_PROJECT_DIR_PATH')
    if branch_json_file_git_home.startswith('~'):
        branch_json_file_git_home = os.path.expanduser(branch_json_file_git_home) # 将~扩展为当前用户的home目录

    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    branch_json_file_dir_relpath = data['branchJsonFile']['BRANCH_JSON_FILE_DIR_RELATIVE_PATH']
    branch_json_file_dir_abspath = joinFullPath(branch_json_file_git_home, branch_json_file_dir_relpath)

    # print("branch_json_file_dir_abspath: \033[1;31m{}\033[0m".format(branch_json_file_dir_abspath))
    return branch_json_file_dir_abspath



def getEnvValue_jenkins_workspace():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)
        
    jenkins_data=data['jenkins']
    jenkins_workspace=jenkins_data['workspace']
    if jenkins_workspace.startswith('~'):
        jenkins_workspace = os.path.expanduser(jenkins_workspace) # 将~扩展为当前用户的home目录

    if not os.path.isdir(jenkins_workspace):
        print(f"{RED}目录{jenkins_workspace}不存在，请检查{tool_params_file_path}中的jenkins.workspace字段 {NC}")
        # 在 macOS 或 Linux 上打开 file_path 文件。
        # subprocess.Popen(['open', file_path])
        subprocess.Popen(['open', tool_params_file_path])
        return 1
    
    return jenkins_workspace

# branch_json_file_git_home=getEnvValue_branch_json_file_git_home()
# getEnvValue_branch_json_file_dir_path()