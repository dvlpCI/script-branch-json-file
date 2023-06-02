'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-02 15:29:33
FilePath: pack_input.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json

import re
from env_util import getEnvValue_pack_input_params_file_path


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



def getActionById(actions, actionId):
    # for iPerson in persons:
    #     if iPerson['id'] == personId:
    #         person=iPerson
    #         break
    # return person

    matchPersons = list(filter(lambda x: x['id'] == actionId, actions))
    if matchPersons:
        person = matchPersons[0]

    return person

def getChooseValueById(values, valueId):
    # for iPerson in persons:
    #     if iPerson['id'] == personId:
    #         person=iPerson
    #         break
    # return person

    matchPersons = list(filter(lambda x: x['id'] == valueId, values))
    if matchPersons:
        person = matchPersons[0]

    return person

def dealActions():
    pack_input_params_file_path=getEnvValue_pack_input_params_file_path()
    with open(pack_input_params_file_path) as f:
        data = json.load(f)

    # 1、选择环境
    chooseEnvMap=chooseActions(data)
    print(f"")

    # 2、针对选择的环境，执行所需的操作
    env_action_ids=chooseEnvMap['env_action_ids']
    # print(f"未找到id为{YELLOW}{actions_envs}的用户{NC}")
    resultMaps=[]
    for i, env_action_id in enumerate(env_action_ids):
        resultMap=dealDataOperate(data, env_action_id)
        resultMaps.append(resultMap)
        print(f"")

    print(f"您选择的结果如下：{NC}")
    for i, resultMap in enumerate(resultMaps):
        print(f"{i+1}. {resultMap['resultForParam']} ({resultMap['resultValue']})")

    
        


def chooseActions(data):
    actions_envs=data['actions_envs']
    for i, actions_env in enumerate(actions_envs):
        print(f"{i+1}. {actions_env['env_id']} ({actions_env['env_name']})")

    envDes="要操作的环境"
    while True:
        env_input = input("请选择%s编号（退出q/Q）：" % (envDes))
        if env_input == "q" or env_input == "Q":
            exit()

        if not env_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        index = int(env_input) - 1
        if index >= len(actions_envs):
            continue
        else:
            chooseEnvMap = actions_envs[index]
            chooseEnvMapName = chooseEnvMap["env_name"]
            break

    print(f"您选择的{envDes}：{YELLOW}{chooseEnvMapName}{NC}")
    return chooseEnvMap
    
    


def dealDataOperate(data, operate):
    operateHomeMap=getActionById(data['actions'],operate)

    # 对 homeMap 进行处理
    # ①是什么操作
    operateDes = operateHomeMap['des']
    # ②是 "选择" 还是 "输入"
    operateActionType = operateHomeMap['actionType']
    if operateActionType == "choose":
        operateActionTypeDes="选择"
        # ③如果是选择，选择项有哪些
        operateChooseMaps = operateHomeMap['chooseValues']
        for i, chooseMap in enumerate(operateChooseMaps):
            chooseName = chooseMap['name']
            if chooseName:
                print(f"{i+1}. {chooseName}")
            else:
                print(f"未找到id为{YELLOW}{chooseName}的用户{NC}")
    else:
        operateActionTypeDes="输入"


    while True:
        person_input = input("请%s%s编号（自定义请填0,退出q/Q）：" % (operateActionTypeDes, operateDes))
        if person_input == "q" or person_input == "Q":
            exit()

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        if person_input == "0":
            personName=input("请输入%s名（退出q/Q）：" % (operateDes))
            if personName == "q" or personName == "Q":
                exit()
            break

        index = int(person_input) - 1
        if index >= len(operateChooseMaps):
            continue
        else:
            chooseValueMap = operateChooseMaps[index]
            personName = chooseValueMap["name"]
            break

    print(f"您{operateActionTypeDes}的{operateDes}：{YELLOW}{personName}{NC}")


    # ④选择的结果给谁用
    resultForParam = operateHomeMap['resultForParam']

    return {
        "resultForParam": personName,
        "resultValue": resultForParam,
    }



def inputBranchName():
    while True:
        branchName = input("②请输入您的分支名(支持字母数字下滑线中划线)(若要退出请输入Q|q) : ")
        if branchName.lower() == 'q':
            exit(2)
        else:
            # 使用正则表达式判断字符串以字母开头且不小于4位，同时内容只能为字母和_和其他数字
            if re.match(r'^[a-zA-Z][a-zA-Z0-9_-]{3,}$', branchName):
                break
            else:
                print(f"字符串{RED}{branchName}{NC}不符合要求，请重新输入(要求以字母开头，且不小于4位)\n")
    return branchName




def inputOutline():
    # 1、分支描述
    while True:
        try:
            # 尝试使用 UTF-8 编码解码用户输入
            branchDes = input("请输入分支描述：") or "null"
            break  # 如果解码成功，则跳出循环
        except UnicodeDecodeError:
            print("输入的编码不是 UTF-8，请重新输入。")
    print("输入的分支描述：\033[1;31m{}\033[0m\n".format(branchDes))

    # branchDes = "【【线上问题】复制口令，并且杀掉app重新打开，进入游戏会卡再初始图界面3s并且没有加载条】https://www.tapd.cn/69657441/bugtrace/bugs/view?bug_id=1169657442001003014"
    outlineMap = getOutline(branchDes)
    return outlineMap

def getOutline(text):
    result = {}
    
    # 使用正则表达式提取标题和URL
    title_pattern = r"(.+)"
    title_match = re.search(title_pattern, text)
    title = title_match.group(1)
    
    
    
    url_pattern = r"(https?://\S+)"
    url_match = re.search(url_pattern, text)
    if url_match:
        url = url_match.group(1)
        title = title.replace(url, "") # 将title中的url移除
        result["url"] = url
    else:
        url = None
    
    result["title"] = title

    return result


# chooseAnswer()
# chooseTester()
# inputOutline()
dealActions()
# choosePlatform()
