'''
Author: dvlproad
Date: 2023-07-04 17:48:57
LastEditors: dvlproad
LastEditTime: 2023-09-04 18:00:35
Description: 使用python，修改指定文件中的某行。
'''

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

import os
from base_util import openFile

# 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 $removeLineOldString, 则该行整行修改为 $removeLineNewString 且保证新的行的起始空格和旧行一致
def remove_and_add_in_file(file_path, removeLineOldString=None, removeLineNewString=None):
    if not os.path.exists(file_path):
        print(f"❌:{BLUE} {file_path} {NC}文件不存在,请检查")
        return False
        
    temp_file_path = file_path + ".temp"

    with open(file_path, "r") as f, open(temp_file_path, "w") as temp_f:
        foundNeedChangeValue=False
        for line in f:
            if removeLineOldString in line:
                # 获取该行的起始空格
                spaces = line[:line.index(removeLineOldString)]
                # 将包含 "grantType": "trust_mobile_wechat" 的行整行替换为 "grantType": "sms_code"
                line = spaces + removeLineNewString + "\n"
                foundNeedChangeValue=True
            temp_f.write(line)
        if foundNeedChangeValue==False:
            print(f"{RED}❌:{BLUE} {file_path} {RED}文件中未找到需要修改的行,请检查该行是否包含{BLUE} {removeLineOldString} {NC}")
            return False

    # 删除原文件，将修改后的内容写入新文件
    os.remove(file_path)

    # 将修改后的内容写回原文件
    os.replace(temp_file_path, file_path)
    print(f'文件：{BLUE} {file_path} {NC}替换完成')
    openFile(file_path)


# 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 $removeLineOldString, 则该行整行修改为 $removeLineNewString 且保证新的行的起始空格和旧行一致
def replace_for_in_file(file_path, removeLineOldString=None, removeLineNewString=None):
    temp_file_path = file_path + ".temp"

    with open(file_path, "r") as f, open(temp_file_path, "w") as temp_f:
        foundNeedChangeValue=False
        for line in f:
            if removeLineOldString in line:
                # 使用 replace() 函数替换该行中 "grantType": "trust_mobile_wechat" 部分
                line = line.replace(removeLineOldString, removeLineNewString)
                foundNeedChangeValue=True
            temp_f.write(line)

        if foundNeedChangeValue==False:
            print(f"{RED}❌:{BLUE} {file_path} {RED}文件中未找到需要修改的行,请检查该行是否包含{BLUE} {removeLineOldString} {NC}")
            return False

    # 将修改后的内容写回原文件
    os.replace(temp_file_path, file_path)
    print(f'文件：{BLUE} {file_path} {NC}替换完成')
    openFile(file_path)



# 获取具名参数的值
import argparse
parser = argparse.ArgumentParser()  # 创建参数解析器
parser.add_argument("-file_path", "--file_path", help="The value for argument 'file_path'")
parser.add_argument("-removeLineOldString", "--removeLineOldString", help="The value for argument 'removeLineOldString'")
parser.add_argument("-removeLineNewString", "--removeLineNewString", help="The value for argument 'removeLineNewString'")
args = parser.parse_args()  # 解析命令行参数

file_path = args.file_path
if file_path is None:
    print(f"{RED}您要修改的文件 -file_path 不能为空，请检查！{NC}")
    exit(1)

removeLineOldString = args.removeLineOldString
if removeLineOldString is None:
    print(f"{RED}您要修改的文件内容 -removeLineOldString 不能为空，请检查！{NC}")
    exit(1)

removeLineNewString = args.removeLineNewString
if removeLineNewString is None:
    print(f"{RED}您要替换成的新内容 -removeLineNewString 不能为空，请检查！{NC}")
    exit(1)


remove_and_add_in_file(file_path, removeLineOldString=removeLineOldString, removeLineNewString=removeLineNewString)