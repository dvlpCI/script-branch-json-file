'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-20 13:50:16
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json

import re

# 定义颜色常量
RED = "\033[31m"
NC = "\033[0m"





def getPersonById(persons, personId):
    # for iPerson in persons:
    #     if iPerson['id'] == personId:
    #         person=iPerson
    #         break
    # return person

    matchPersons = list(filter(lambda x: x['id'] == personId, persons))
    if matchPersons:
        person = matchPersons[0]

    return person


def chooseAnswer():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    personMaps = data['branchJsonFile']['answerAllowId']
    for i, personId in enumerate(personMaps):
        person = getPersonById(data['person'], personId)
        if person:
            print(f"{i+1}. {person['name']}")
        else:
            print("未找到id为\033[1;31m{}\033[0m的用户\n".format(personId))

    while True:
        person_input = input("请输入需求方人员编号（自定义请填0,退出q/Q）：")
        if person_input == "q" or person_input == "Q":
            exit()

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        if person_input == "0":
            personName = input("请输入需求方人员姓名：")
            break

        index = int(person_input) - 1
        if index >= len(personMaps):
            print("请输入需求方人员编号（自定义请填0,退出q/Q）：")
            continue
        else:
            selectedPersonId = personMaps[index]
            personName = getPersonById(
                data['person'], selectedPersonId)["name"]
            break

    print("您选择输入需求方人员名：\033[1;31m{}\033[0m\n".format(personName))
    return personName


def chooseTester():
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    with open(tool_params_file_path) as f:
        data = json.load(f)

    personMaps = data['branchJsonFile']['testerAllowId']
    for i, personId in enumerate(personMaps):
        person = getPersonById(data['person'], personId)
        if person:
            print(f"{i+1}. {person['name']}")
        else:
            print("未找到id为\033[1;31m{}\033[0m的用户\n".format(personId))

    while True:
        person_input = input("请输入测试方人员编号（自定义请填0,退出q/Q）：")
        if person_input == "q" or person_input == "Q":
            exit()

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        if person_input == "0":
            personName = input("请输入需求方人员姓名：")
            break

        index = int(person_input) - 1
        if index >= len(personMaps):
            print("请输入测试方人员编号（自定义请填0,退出q/Q）：")
            continue
        else:
            selectedPersonId = personMaps[index]
            personName = getPersonById(
                data['person'], selectedPersonId)["name"]
            break

    print("您选择输入测试方人员名：\033[1;31m{}\033[0m\n".format(personName))
    return personName




def inputBranchName():
    while True:
        branchName = input("②请输入您的分支名(支持字母数字下滑线中划线小数点)(若要退出请输入Q|q) : ")
        if branchName.lower() == 'q':
            exit(2)
        else:
            # 使用正则表达式判断字符串以字母开头且不小于4位，同时内容只能为字母和_和其他数字
            if re.match(r'^[a-zA-Z][a-zA-Z0-9_-.]{3,}$', branchName):
                break
            else:
                print(f"字符串{RED}{branchName}{NC}不符合要求，请重新输入(要求以字母开头，且不小于4位)\n")
    return branchName




def inputOutline():
    # 1、分支描述
    while True:
        try:
            # 尝试使用 UTF-8 编码解码用户输入
            branchDes = input("请输入分支描述(若要退出请输入Q|q) ：") or "null"
            if branchDes.lower() == 'q':
                exit(2)
            else:
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
