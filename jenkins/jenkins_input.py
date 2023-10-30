'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-10-30 15:15:33
FilePath: jenkins_input.py
Description: Jenkins打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json
import urllib.parse
import subprocess

from jenkins_input_result_util import save_jenkins_urls_to_file



import sys

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



temp_reslut_file_path=sys.argv[1]
# print("====保存结果的临时文件的路径为：\033[1;31m{}\033[0m\n".format(temp_reslut_file_path))

def getOptionById(options, optionInputId):
    # print("\033[1;32m哈哈哈{}\033[0m".format(optionInputId))
    option=None
    for iOption in options:
        if iOption['inputId'] == optionInputId:
            option=iOption
            break
    # print("\033[1;32m哈哈哈{}\033[0m".format(option))
    return option


def chooseOptionForPack():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    print("\033[1;32m{}\033[0m".format("已支持的Jenkins Job："))
    options = data['jenkins']['jenkins_input_option']
    for i, option in enumerate(options):
        print("\033[1;32m{}\033[0m：\033[1;33m{}\033[0m".format(option['inputId'], option['inputMeaning']))
        
    while True:
        option_input_id = input("请输入想要打包的id（退出q/Q）：")
        if option_input_id == "q" or option_input_id == "Q":
            exit(2)

        option=getOptionById(options, option_input_id)
        if not option:
            print("不存在\033[1;31m{}\033[0m，请重新输入想要打包的id（退出q/Q）：".format(option_input_id))
            continue
        else:
            break

    print("您选择打包的类型为：\033[1;31m{}\033[0m\n".format(option['inputMeaning']))

    return getAndSavePackParamStringToFileForOption(data['jenkins'], option)

def getCustomInputForKey(paramKey):
    while True:
        keyValue_input = input(f"请输入jenkin的 {paramKey} 参数（退出q/Q）：")
        if keyValue_input == "q" or keyValue_input == "Q":
            exit(2)
        else:
            break
    return keyValue_input
    
    output = subprocess.check_output(["git", "log", "-1", "--pretty=format:%an %s"])
    change_log = output.decode("utf-8").strip()
    return change_log
    
def getAndSavePackParamStringToFileForOption(jenkins_data, option):
    # baseUrl
    JENKINS_BaseURL=jenkins_data['jenkins_base']["JENKINS_BASE_URL"]
    
    # fixedBodyParams
    paramMap=jenkins_data['jenkins_input_option_param']
    jobUseParamType=option['jobUseParamType']
    # 获取 jenkins_input_option_param 中key为 jobUseParamType 的值
    param = next(filter(lambda x: jobUseParamType in x, paramMap))
    networkParams=param[jobUseParamType]
    print(f"{CYAN}温馨提示：您的jenkin job所需参数罗列如下:{BLUE}\n{json.dumps(networkParams, indent=2)} {NC}")
    
    for key, value in networkParams.items():  # 遍历字典的键和值
        if value == "custom_input":
            print(f"{YELLOW}您的jenkin job所需的{BLUE} {key} {YELLOW}参数为 {value}，需要手动输入。{YELLOW}")
            user_input=getCustomInputForKey(key)
            networkParams[key] = user_input
    
    query_string = urllib.parse.urlencode(networkParams)

    jenkinUrls = []
    jobNames=option['jobNames']
    for job_name in jobNames:
        jenkinUrl = f"{JENKINS_BaseURL}/job/{job_name}/buildWithParameters?" + query_string
        jenkinUrls.append(jenkinUrl)
    # print(jenkinUrls)

    save_jenkins_urls_to_file(jenkinUrls, temp_reslut_file_path)

    return jenkinUrls


chooseOptionForPack()


