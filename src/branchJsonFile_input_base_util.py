'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 15:23:01
FilePath: branchJsonFile_input.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")
import re
from env_util import get_json_file_data

# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'

# # 获取具名参数的值
# import argparse
# parser = argparse.ArgumentParser()  # 创建参数解析器
# parser.add_argument("-filePath", "--filePath", help="The value for argument 'filePath'")
# args = parser.parse_args()  # 解析命令行参数
# filePath = args.filePath
# if filePath is None:
#     print(f"{RED}您要获取姓名的输入源文件 -filePath 不能为空，请检查！{NC}")
#     exit(1)


def chooseAnswerFromFile(personFilePath):
    return _choosePeopleByType(personFilePath, "answerAllowId")

def chooseApierFromFile(personFilePath):
    return _choosePeopleByType(personFilePath, "apierAllowId")

def chooseTesterFromFile(personFilePath):
    return _choosePeopleByType(personFilePath, "testerAllowId")


def _choosePeopleByType(tool_params_file_path, typeId):
    data = get_json_file_data(tool_params_file_path)
    if data == None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件内容读取失败，无法获取姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName

    if 'branchJsonFile' not in data:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件内容缺失{BLUE} branchJsonFile {YELLOW}字段，无法获取姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    

    personResourceMap = data['branchJsonFile']
    if typeId not in personResourceMap:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件中的${BLUE} branchJsonFile {YELLOW}字段里缺失{BLUE} {typeId} {YELLOW}，无法获取姓名，将临时使用${BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    
    personMaps = personResourceMap[typeId]
    if personMaps:
        for i, personId in enumerate(personMaps):
            person = getPersonById(data['person'], personId)  
            if person:
                print(f"{i+1}. {person['name']}")
            else:
                print(f"{i+1}. 未找到id为 {RED}{personId} {NC}的用户, 详情请查看 {BLUE}{tool_params_file_path} {NC}中的 {BLUE}person {NC}字段")

    if typeId == 'answerAllowId':
        typeName="需求方人员"
    elif typeId == 'apierAllowId':
        typeName="后端接口人员"
    elif typeId == 'testerAllowId':
        typeName="测试方人员"
    else:
        typeName="需求方人员"
    while True:
        person_input = input(f"请输入{typeName}编号（自定义请填0,退出q/Q）：")
        if person_input == "q" or person_input == "Q":
            exit()

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        if person_input == "0":
            personName = input(f"请输入{typeName}姓名：")
            break

        index = int(person_input) - 1
        if index >= len(personMaps):
            print(f"请输入{typeName}编号（自定义请填0,退出q/Q）：")
            continue
        else:
            selectedPersonId = personMaps[index]
            personName = getPersonById(
                data['person'], selectedPersonId)["name"]
            break

    print(f"您选择输入{typeName}名：{BLUE}{personName}{NC}")
    return personName


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
    else:
        return None


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
            branchDes = input("请输入分支描述(支持描述后加地址，若要退出请输入Q|q) ：") or "null"
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
    
    result["weekSpendHours"] = ["null"]
    
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

# import os
# tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
# chooseAnswerFromFile(tool_params_file_path)
# chooseApierFromFile(tool_params_file_path)
# chooseTesterFromFile(tool_params_file_path)
# inputOutline()
