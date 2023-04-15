'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-04-16 03:00:55
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os


# 获取环境变量的值
def getEnvValue_branch_json_file_git_home():
    branch_json_file_git_home = os.getenv('BRANCH_JSON_FILE_GIT_HOME')
    # if 'BRANCH_JSON_FILE_GIT_HOME' in os.environ:
    #     branch_json_file_git_home = os.environ['BRANCH_JSON_FILE_GIT_HOME']
    #     print(branch_json_file_git_home)
    # else:
    #     print('BRANCH_JSON_FILE_GIT_HOME environment variable not set')
    print("branch_json_file_git_home: \033[1;31m{}\033[0m".format(branch_json_file_git_home))
    return branch_json_file_git_home

# 获取环境变量的值
def getEnvValue_branch_json_file_dir_path():
    branch_json_file_dir_path = os.getenv('BRANCH_JSON_FILE_DIR_PATH')
    # if 'BRANCH_JSON_FILE_DIR_PATH' in os.environ:
    #     branch_json_file_dir_path = os.environ['BRANCH_JSON_FILE_DIR_PATH']
    #     print(branch_json_file_dir_path)
    # else:
    #     print('BRANCH_JSON_FILE_DIR_PATH environment variable not set')
    print("branch_json_file_dir_path: \033[1;31m{}\033[0m".format(branch_json_file_dir_path))
    return branch_json_file_dir_path

# branch_json_file_git_home=getEnvValue_branch_json_file_git_home()
# getEnvValue_branch_json_file_dir_path()