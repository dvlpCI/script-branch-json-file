'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-13 17:02:53
FilePath: /branchJsonFile_create/branchInfoManager.py
Description: object的更新
'''
# -*- coding: utf-8 -*-

def update_dict_value(dictionary, key_name, value):
    keys = key_name.split(".")
    sub_dict = dictionary
    for key in keys[:-1]:
        sub_dict = sub_dict[key]
    sub_dict[keys[-1]] = value
    return dictionary
