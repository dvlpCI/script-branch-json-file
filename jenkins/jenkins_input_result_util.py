'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-18 16:25:02
FilePath: jenkins_input_result_util.py
Description: Jenkins打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import json


def save_jenkins_urls_to_file(jenkins_urls, file_path):
    # 读取temp_result.json文件中的数据
    with open(file_path, 'r') as file:
        data = json.load(file)

    # 更新jenkinsUrl字段
    data['jenkinsUrls'] = jenkins_urls

    # 将更新后的数据写入temp_result.json文件
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4, ensure_ascii=False)


def load_jenkins_urls_from_file(file_path):
    # 从temp_result.json文件中读取jenkinsUrls
    with open(file_path, 'r') as file:
        data = json.load(file)
        jenkins_urls = data.get('jenkinsUrls')

    # 返回jenkinsUrls列表
    return jenkins_urls


