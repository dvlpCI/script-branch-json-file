'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-02 16:05:29
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






# chooseAnswer()
# chooseTester()
dealActions()
# choosePlatform()
