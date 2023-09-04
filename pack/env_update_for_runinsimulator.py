'''
Author: dvlproad
Date: 2023-07-04 17:48:57
LastEditors: dvlproad
LastEditTime: 2023-09-04 18:34:07
Description: 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 "grantType": "trust_mobile_wechat",如果符合条件，则该行整行修改为"grantType": "sms_code",且保证新的行的起始空格和旧行一致
'''

from replace_text_in_file import remove_and_add_in_file

import os
# 获取当前 Python 脚本所在目录
current_dir = os.path.dirname(os.path.abspath(__file__))
# 获取当前 Python 脚本的父目录
temp_dir = os.path.dirname(current_dir)
project_dir = os.path.dirname(temp_dir)
code_hom_dir = f"{project_dir}/wish"

json_path = f"{code_hom_dir}/packages/module_login/lib/src/msg_login_page.dart"
removeLineOldString="grantType\": \"trust_mobile_wechat\""
removeLineNewString="\"grantType4\": \"sms_code3\","
remove_and_add_in_file(json_path, removeLineOldString=removeLineOldString, removeLineNewString=removeLineNewString)