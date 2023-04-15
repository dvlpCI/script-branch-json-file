'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-13 13:32:14
FilePath: /bulidScript/branch_create/branchInfo_create.py
Description: 分支JSON文件的创建-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

def chooseAnswer():
    answer_mapping = {
        "1": "李超前",
        "2": "谢晓龙",
        "3": "李再超",
        "4": "王毅",
        "5": "刘璟"
    }
    for key, value in answer_mapping.items():
        print(key, value)
    
    while True:
        answer_input = input("请输入需求方人员编号（1、2、3、4、5）：")
        if answer_input in answer_mapping:
            answerName = answer_mapping[answer_input]
            # print("key = {}, value = {}".format(answer_input, answerName))
            print("您选择输入需求方人员名：\033[1;31m{}\033[0m\n".format(answerName))
            break
        else:
            print("输入有误，请重新输入！")
    
    return answerName


def chooseTester():
    # 3、测试方信息
    # while True:
    #     try:
    #         # 尝试使用 UTF-8 编码解码用户输入
    #         tester = input("输入测试人：") or "null"
    #         break  # 如果解码成功，则跳出循环
    #     except UnicodeDecodeError:
    #         print("输入的编码不是 UTF-8，请重新输入。")
    tester_mapping = {
        "1": "李智荣",
        "2": "苏婉艺",
        "3": "谭贤",
        "4": "林尚挺"
    }
    for key, value in tester_mapping.items():
        print(key, value)

    while True:
        tester_input = input("请输入测试人员编号（1、2、3、4）：")
        if tester_input in tester_mapping:
            testerName = tester_mapping[tester_input]
            # print("key = {}, value = {}".format(tester_input, testerName))
            print("选择的测试人员姓名：\033[1;31m{}\033[0m\n".format(testerName))
            break
        else:
            print("输入有误，请重新输入！")

    
    return testerName

    

