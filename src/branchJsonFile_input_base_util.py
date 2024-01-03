'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2023-11-25 23:17:01
FilePath: branchJsonFile_input.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-
import json
import re
import datetime
from env_util import get_json_file_data
from env_util_tool import get_fileOrDirPath_fromToolParamFile

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




# 定义一个函数，根据Personnel_FILE_PATH，searchIdKey，searchIdValue获取personName
def getPeopleNameByPersonnel_FILE_PATH(Personnel_FILE_PATH, searchIdKey, searchIdValue):
    # 读取Personnel_FILE_PATH文件内容
    data = get_json_file_data(Personnel_FILE_PATH)
    # 如果读取失败，则返回personName
    if data == None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {Personnel_FILE_PATH} {YELLOW}文件内容读取失败，无法获取姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    
    # 查找 searchIdKey 为 searchIdValue 的字典
    desired_dict = next((item for item in data if item[searchIdKey] == searchIdValue), None)
    # 如果查找失败，则返回personName
    if desired_dict==None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {Personnel_FILE_PATH} {YELLOW}文件缺失{BLUE} {searchIdKey} {YELLOW}字段为{BLUE} {searchIdValue} {YELLOW}的内容，导致无法获取用户信息，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    
    # 打印结果
    # print(f"==========={desired_dict}")
    personName=desired_dict["name"]
    if personName==None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {Personnel_FILE_PATH} {YELLOW}文件中{BLUE} {searchIdKey} {YELLOW}字段为{BLUE} {searchIdValue} {YELLOW}的内容 {desired_dict} 缺少 name 属性，无法获取用户姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName

    return personName

    



def _choosePeopleByType(tool_params_file_path, typeId):
    data = get_json_file_data(tool_params_file_path)
    if data == None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件内容读取失败，无法获取姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    
    # 获取用户信息文件 personnel_file_path
    Personnel_FILE_PATH = get_fileOrDirPath_fromToolParamFile(tool_params_file_path, "personnel_file_path")
    if Personnel_FILE_PATH == None:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件中的${BLUE} personnel_file_path {YELLOW}字段里缺失{BLUE} {typeId} {YELLOW}，无法获取姓名，将临时使用${BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName

    # 获取可以选择的用户ids
    if 'branchJsonFile' not in data:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件内容缺失{BLUE} branchJsonFile {YELLOW}字段，无法获取姓名，将临时使用{BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    personResourceMap = data['branchJsonFile']
    if typeId not in personResourceMap:
        personName="unkonw"
        print(f"{YELLOW}您的{BLUE} {tool_params_file_path} {YELLOW}文件中的${BLUE} branchJsonFile {YELLOW}字段里缺失{BLUE} {typeId} {YELLOW}，无法获取姓名，将临时使用${BLUE} {personName} {YELLOW}，请后续补充。{NC}")
        return personName
    personIdMaps = personResourceMap[typeId]
    for i, personId in enumerate(personIdMaps):
        personName = getPeopleNameByPersonnel_FILE_PATH(Personnel_FILE_PATH, "role_id", personId)
        print(f"{i+1}. {personName}")

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
        if index >= len(personIdMaps):
            print(f"请输入{typeName}编号（自定义请填0,退出q/Q）：")
            continue
        else:
            selectedPersonId = personIdMaps[index]
            personName = getPeopleNameByPersonnel_FILE_PATH(Personnel_FILE_PATH, "role_id", selectedPersonId)
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


def addOutline(file_path):
    with open(file_path, 'r') as json_file:
        json_data = json.load(json_file)

    outlineMap = inputOutline()
    json_data['outlines'].append(outlineMap)

    # 将更新后的数据写入json文件
    with open(file_path, 'w') as file:
        json.dump(json_data, file, indent=4, ensure_ascii=False)
        
    return True


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
    print(f"输入的分支描述：{RED}{branchDes}{NC}\n")

    # branchDes = "【【线上问题】复制口令，并且杀掉app重新打开，进入游戏会卡再初始图界面3s并且没有加载条】https://www.tapd.cn/69657441/bugtrace/bugs/view?bug_id=1169657442001003014"
    outlineMap = getOutline(branchDes)
    return outlineMap


def get_date_range(date, formatter="%Y.%m.%d"):
    # date = datetime.datetime.strptime(date_str, formatter)  # 将日期字符串解析为日期对象
    start_of_week = date - datetime.timedelta(days=date.weekday())  # 计算本周的开始日期
    end_of_week = start_of_week + datetime.timedelta(days=6)  # 计算本周的结束日期
    
    start_of_week_string = start_of_week.strftime(formatter)
    end_of_week_string = end_of_week.strftime(formatter)
    
    range_time_string = f"{start_of_week_string} - {end_of_week_string}"
    return range_time_string

def is_within_date_range(check_date_str, start_date_str, end_date_str, formatter):
    print(f"{YELLOW}正在判断 {check_date_str} 是否在 {start_date_str} - {end_date_str} 范围内(以{formatter}格式){NC}")
            
    # 将日期字符串转换为日期对象
    date = datetime.datetime.strptime(check_date_str, formatter)
    start_date = datetime.datetime.strptime(start_date_str, formatter)
    end_date = datetime.datetime.strptime(end_date_str, formatter)

    # 判断日期是否在范围内
    if date < start_date:
        return "smallThen"
    elif date > end_date:
        return "bigThen"
    else:
        return "in"


def getOutline(text):
    result = {}
    
    result["weekSpend"] = [{"range_time": get_date_range(datetime.datetime.now()), "hour": 0 }]
    
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

def updateOutlineSpendHour(file_path, atDateString=datetime.datetime.now().strftime("%Y.%m.%d"), formatter="%Y.%m.%d"):
    with open(file_path, 'r') as json_file:
        json_data = json.load(json_file)

    timeRangeString = get_date_range(datetime.datetime.strptime(atDateString, formatter))

    outlinesArray = json_data["outlines"]
    for i, outline in enumerate(outlinesArray):
        spendHour = 0
        if "weekSpend" in outline:
            weekSpendArray = outline["weekSpend"]
            for i, spendMap in enumerate(weekSpendArray):
                iHour = spendMap["hour"]
                spendHour += iHour
            
        print(f"{i+1}:{BLUE} {outline['title']} {NC}【{RED}{spendHour}{NC}】")
        
    while True:
        try:
            index_input = input(f"请输入要修改的分支描述序号(若要退出请输入Q|q) ：")
            if index_input == "q" or index_input == "Q":
                exit()

            if not index_input.isnumeric():
                print(f"输入的不是一个数字，请重新输入！")
                continue
            
            index_input = int(index_input)
            if index_input < 0 or index_input >= len(outlinesArray):
                print(f"输入的序号 {index_input} 不在范围内，请重新输入。")
                continue
            
            willChangeOutlineMap = outlinesArray[index_input]
            break
        
        except ValueError:
            print(f"输入的不是数字，请重新输入。")
            continue
    
    # 输入这次投入的功能耗时
    willChangeOutlineTitle = willChangeOutlineMap["title"]
    addSpendHour = inputSpendHour(willChangeOutlineTitle)
    
    # 将输入的这次投入的功能耗时添加到对应周上
    weekIndex_create = get_week_number(json_data["create_time"])
    weekIndex_current = int(datetime.datetime.now().strftime("%U"))
    weekCount = weekIndex_current - weekIndex_create + 1
    # print(f"weekCount={weekCount} , 计算公式: {weekIndex_current} - {weekIndex_create} + 1 ")
    if "weekSpend" not in willChangeOutlineMap:
        willChangeOutlineMap["weekSpend"] = []
    
    
    weekSpendHourArray = willChangeOutlineMap["weekSpend"]
    if len(weekSpendHourArray) == 0:
        spendMap = {"range_time": timeRangeString, "hour": addSpendHour }
        weekSpendHourArray.insert(0, spendMap)
    else:
        for i, weekSpendHourMap in enumerate(weekSpendHourArray):
            weekRangeString = weekSpendHourMap["range_time"]
            
            # 分割字符串，获取起始日期和结束日期字符串
            weekStartTimeString, weekEndTimeString = weekRangeString.split(" - ")
            print(f"{YELLOW}正在判断 {atDateString} 是否在 {weekStartTimeString} - {weekStartTimeString} 范围内(以{formatter}格式){NC}")
            
            is_within_type = is_within_date_range(atDateString, weekStartTimeString, weekEndTimeString, formatter)
            if is_within_type == "smallThen":
                spendMap = {"range_time": timeRangeString, "hour": addSpendHour }
                weekSpendHourArray.insert(i, spendMap)
            elif is_within_type == "in":
                spendMap = weekSpendHourArray[i]
                spendMap["hour"] += addSpendHour
            else:   # bigThen
                spendMap = {"range_time": timeRangeString, "hour": addSpendHour }
                weekSpendHourArray.insert(i+1, spendMap)

    # print(f"{json.dumps(weekSpendHourArray, indent=2, ensure_ascii=False)}")
    
    # hasWriteWeekCount = len(weekSpendHourArray)
    # print(f"已填写耗时的周数: {hasWriteWeekCount}/{weekCount}")
    
    # 将更新后的数据写入json文件
    with open(file_path, 'w') as file:
        json.dump(json_data, file, indent=4, ensure_ascii=False)
    return True


def get_week_number(date_str):
    date_str = convert_date_format(date_str)
    date = datetime.datetime.strptime(date_str, "%Y-%m-%d")  # 将日期字符串解析为日期对象
    week_number = date.strftime("%U")  # 获取周数（起始从周日）
    return int(week_number)


def convert_date_format(date_str):
    # 匹配 "2023.01.01" 格式
    pattern1 = r"(\d{4})\.(\d{2})\.(\d{2})"
    match1 = re.match(pattern1, date_str)

    # 匹配 "01.01" 格式
    pattern2 = r"(\d{2})\.(\d{2})"
    match2 = re.match(pattern2, date_str)

    if match1:
        # 匹配到 "2023.01.01" 格式，进行转换
        year = match1.group(1)
        month = match1.group(2)
        day = match1.group(3)
        converted_date_str = f"{year}-{month}-{day}"
    elif match2:
        # 匹配到 "01.01" 格式，补充年份后进行转换
        current_year = datetime.datetime.now().year
        year = str(current_year)
        month = match2.group(1)
        day = match2.group(2)
        converted_date_str = f"{year}-{month}-{day}"
    else:
        # 无法匹配日期格式，返回原始字符串
        converted_date_str = date_str

    return converted_date_str

# 输入耗时(以小时计算)
def inputSpendHour(forTitle):
    while True:
        try:
            # 尝试使用 UTF-8 编码解码用户输入
            spendHour_input = input(f"请输入这次在【 {forTitle} 】投入的功能耗时(以小时计算，若要退出请输入Q|q) ：") or "null"
            if spendHour_input.lower() == 'q':
                exit(2)
            elif not spendHour_input.isnumeric():
                print("输入的不是一个数字，请重新输入！")
                continue
            else:
                break  # 如果解码成功，则跳出循环
        except UnicodeDecodeError:
            print("输入的编码不是 UTF-8，请重新输入。")
    print(f"输入的这次投入的功能耗时：{RED}{spendHour_input}{NC}\n")

    return int(spendHour_input)
