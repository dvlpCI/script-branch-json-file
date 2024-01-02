'''
Author: dvlproad
Date: 2023-07-04 17:48:57
LastEditors: dvlproad
LastEditTime: 2023-09-04 18:34:07
Description: 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 "grantType": "trust_mobile_wechat",如果符合条件，则该行整行修改为"grantType": "sms_code",且保证新的行的起始空格和旧行一致
'''


import os
# 获取当前 Python 脚本所在目录
current_dir = os.path.dirname(os.path.abspath(__file__))
# 获取当前 Python 脚本的父目录
temp_dir = os.path.dirname(current_dir)
# project_dir = os.path.dirname(temp_dir)
project_dir="~/Project/xxx/mobile_flutter_wish"
if project_dir.startswith('~'):
    project_dir = os.path.expanduser(project_dir)   # 将波浪线~扩展为当前用户的home目录
code_hom_dir = f"{project_dir}/wish"


json_path = f"{code_hom_dir}/lib/module/login/pages/msg_login_page/msg_login_page.dart"
removeLineOldString="LoginGrantTypeUtil.LoginGrantType_NeddWechat,"
removeLineNewString="LoginGrantTypeUtil.LoginGrantType_CanOnlySmsCode,"

# from replace_text_in_file import remove_and_add_in_file
# remove_and_add_in_file(json_path, removeLineOldString=removeLineOldString, removeLineNewString=removeLineNewString)

import subprocess   # 调用指定的 Python 文件
remove_and_add_in_file_scriptPath=f"{temp_dir}/src/replace_text_in_file.py"
subprocess.run(['python3', remove_and_add_in_file_scriptPath, '-file_path', json_path, '-removeLineOldString', removeLineOldString, '-removeLineNewString', removeLineNewString])
