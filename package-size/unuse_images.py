'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-19 17:55:32
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-python
'''
# -*- coding: utf-8 -*-



import urllib.request
import subprocess

import os
def getEnvValue_params_file_path():
    # return "/Users/qian/Project/CQCI/script-branch-json-file/test/tool_input.json"
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    if tool_params_file_path.startswith('~'):
        tool_params_file_path = os.path.expanduser(tool_params_file_path) # 将波浪线~扩展为当前用户的home目录
    return tool_params_file_path

print(urllib.request.getproxies())

url="https://gitee.com/dvlpCI/package-size-resource/raw/master/Flutter/remove_unused_resources.py"
response = urllib.request.urlopen(url)
script = response.read().decode('utf-8')

# 要传递的参数列表
tool_params_file_path=getEnvValue_params_file_path()
args = [tool_params_file_path, 'arg2', 'arg3']

# 将参数列表添加到subprocess.call()函数的参数列表中
subprocess.call(['python3.9', '-c', script] + args)



