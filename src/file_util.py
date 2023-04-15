'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-04-13 17:03:32
FilePath: /branchJsonFile_create/branchInfoManager.py
Description: object的更新
'''
# -*- coding: utf-8 -*-

import os

def check_file_exists(file_path):
    if not os.path.exists(file_path):
        print('文件不存在，退出脚本')
        exit()
    else:
        print('文件存在，继续执行脚本')
        # 在这里继续执行您的脚本逻辑