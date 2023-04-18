'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-18 14:38:12
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json





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
    tool_params_file_path = os.getenv('TOOL_PARAMS_FILE_PATH')
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
    tool_params_file_path = os.getenv('TOOL_PARAMS_FILE_PATH')
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


# chooseAnswer()
# chooseTester()
