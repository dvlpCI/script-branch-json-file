'''
Author: dvlproad
Date: 2023-07-04 17:48:57
LastEditors: dvlproad
LastEditTime: 2023-07-06 16:33:13
Description: 
'''
# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

import json
import sys

import os
# 获取当前 Python 脚本所在目录
current_dir = os.path.dirname(os.path.abspath(__file__))
# 获取当前 Python 脚本的父目录
temp_dir = os.path.dirname(current_dir)
project_dir = os.path.dirname(temp_dir)
code_hom_dir = f"{project_dir}/wish"

# 使用方法：
# cd到wish目录下，执行命令：python3 put_env_in_code.py <env>
# env: test1, test2, develop1, develop2, preproduct, product

def replace_values_in_file(file_path, json_content, placeholder_format, replace_format):
    file_path=f"{code_hom_dir}/{file_path}"
    with open(file_path, 'r') as file:
        content = file.read()

    for key, value in json_content.items():
        placeholder = placeholder_format.format(key=key)
        if placeholder in content:
            replace = replace_format.format(value)
            content = content.replace(placeholder, replace)

    with open(file_path, 'w') as file:
        file.write(content)

    print(f'文件：{file_path} 替换完成')


def replace_values(json_path):
    with open(json_path, 'r') as json_file:
        json_content = json.load(json_file)

    replace_values_in_file('packages/app_environment/lib/src/bj_config.dart', json_content,
                           'String.fromEnvironment(\'{key}\')', '"{}"')
    replace_values_in_file('android/app/build.gradle', json_content,
                           "project.hasProperty('{key}') ? {key} :", "true ? '{}' :")
    replace_values_in_file('ios/Runner/Info.plist', json_content, '$({key})', '{}')
    replace_values_in_file('packages/app_environment/lib/src/keys/bj_keys.dart', json_content,
                           'String.fromEnvironment("{key}")', '"{}"')
    replace_values_in_file('packages/flutter_environment_base/lib/src/network_page_data_bean.dart', json_content,
                           'String.fromEnvironment(\'{key}\')', '"{}"')


env_list = ["test1", "test2", "develop1", "develop2", "preproduct", "product"]


# # 获取具名参数的值
# import argparse
# parser = argparse.ArgumentParser()  # 创建参数解析器
# parser.add_argument("-temp_reslut_file_path", "--temp_reslut_file_path", help="The value for argument 'temp_reslut_file_path'")
# args = parser.parse_args()  # 解析命令行参数
# temp_reslut_file_path = args.temp_reslut_file_path
# if temp_reslut_file_path is None:
#     print(f"{RED}您要获取创建分支信息的信息输入源文件 -temp_reslut_file_path 不能为空，请检查！{NC}")
#     exit(1)
if len(sys.argv) >= 2:
    env = sys.argv[1]
    if env not in env_list:
        print(f"环境信息 '{env}' 不存在。")
        exit()
else:
    print(f'请提供正确的环境信息：{env_list}')
    exit()

print(f'==============> 正在把<{env}>环境配置写入代码里，用于测试，请勿提交 <==============')

json_path = f"{project_dir}/env_config/{env}.json"
replace_values(json_path)

print(f'==============> <{env}>环境配置写入代码里成功，用于测试，请勿提交 <==============')
