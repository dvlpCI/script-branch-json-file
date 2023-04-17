'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-04-17 23:52:06
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
    tool_params_file_path = os.getenv('TOOL_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    branch_json_file_git_home = data['branchGit']['BRANCH_JSON_FILE_GIT_HOME']
    return branch_json_file_git_home

# 获取环境变量的值
def getEnvValue_branch_json_file_dir_path():
    tool_params_file_path = os.getenv('TOOL_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    branch_json_file_dir_path = data['branchJsonFile']['BRANCH_JSON_FILE_DIR_PATH']

    print("branch_json_file_dir_path: \033[1;31m{}\033[0m".format(branch_json_file_dir_path))
    return branch_json_file_dir_path



# branch_json_file_git_home=getEnvValue_branch_json_file_git_home()
# getEnvValue_branch_json_file_dir_path()