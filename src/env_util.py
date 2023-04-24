'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-04-24 20:38:46
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import json

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
    branch_json_file_git_home = os.getenv('TOOL_DEAL_PROJECT_DIR_PATH')
    if branch_json_file_git_home.startswith('~'):
        branch_json_file_git_home = os.path.expanduser(branch_json_file_git_home) # 将~扩展为当前用户的home目录
    return branch_json_file_git_home

# 获取环境变量的值
def getEnvValue_branch_json_file_dir_path():
    branch_json_file_git_home = os.getenv('TOOL_DEAL_PROJECT_DIR_PATH')
    if branch_json_file_git_home.startswith('~'):
        branch_json_file_git_home = os.path.expanduser(branch_json_file_git_home) # 将~扩展为当前用户的home目录

    tool_params_file_path = os.getenv('TOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    branch_json_file_dir_relpath = data['branchJsonFile']['BRANCH_JSON_FILE_DIR_RELATIVE_PATH']
    branch_json_file_dir_abspath = os.path.join(branch_json_file_git_home, branch_json_file_dir_relpath)

    # print("branch_json_file_dir_abspath: \033[1;31m{}\033[0m".format(branch_json_file_dir_abspath))
    return branch_json_file_dir_abspath



def getEnvValue_jenkins_workspace():
    tool_params_file_path = os.getenv('TOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)
        
    jenkins_data=data['jenkins']
    jenkins_workspace=jenkins_data['workspace']
    if jenkins_workspace.startswith('~'):
        jenkins_workspace = os.path.expanduser(jenkins_workspace) # 将~扩展为当前用户的home目录
    
    return jenkins_workspace

# branch_json_file_git_home=getEnvValue_branch_json_file_git_home()
# getEnvValue_branch_json_file_dir_path()