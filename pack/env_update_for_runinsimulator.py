'''
Author: dvlproad
Date: 2023-07-04 17:48:57
LastEditors: dvlproad
LastEditTime: 2023-07-06 18:28:56
Description: 
'''

import os
# 获取当前 Python 脚本所在目录
current_dir = os.path.dirname(os.path.abspath(__file__))
# 获取当前 Python 脚本的父目录
temp_dir = os.path.dirname(current_dir)
project_dir = os.path.dirname(temp_dir)
code_hom_dir = f"{project_dir}/wish"

# 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 "grantType": "trust_mobile_wechat",
# 如果符合条件，则该行整行修改为"grantType": "sms_code",且保证新的行的起始空格和旧行一致
def remove_and_add_for_runinsimulator(file_path):
    temp_file_path = file_path + ".temp"

    with open(file_path, "r") as f, open(temp_file_path, "w") as temp_f:
        for line in f:
            if "grantType\": \"trust_mobile_wechat\"" in line:
                # 获取该行的起始空格
                spaces = line[:line.index("\"grantType")]
                # 将包含 "grantType": "trust_mobile_wechat" 的行整行替换为 "grantType": "sms_code"
                line = spaces + "\"grantType\": \"sms_code\",\n"
            temp_f.write(line)

    # 将修改后的内容写回原文件
    os.replace(temp_file_path, file_path)
    print(f'文件：{file_path} 替换完成')


# 使用python，修改指定文件中的某行。某行的确定规则为如果该行包含 "grantType": "trust_mobile_wechat",
# 如果符合条件，则该行该部分修改为"grantType": "sms_code",其他地方的保持不变
def replace_for_runinsimulator(file_path):
    temp_file_path = file_path + ".temp"

    with open(file_path, "r") as f, open(temp_file_path, "w") as temp_f:
        for line in f:
            if "grantType\": \"trust_mobile_wechat\"" in line:
                # 使用 replace() 函数替换该行中 "grantType": "trust_mobile_wechat" 部分
                line = line.replace("\"grantType\": \"trust_mobile_wechat\"", "\"grantType\": \"sms_code\"")
            temp_f.write(line)

    # 将修改后的内容写回原文件
    os.replace(temp_file_path, file_path)
    print(f'文件：{file_path} 替换完成')



json_path = f"{code_hom_dir}/packages/module_login/lib/src/msg_login_page.dart"
remove_and_add_for_runinsimulator(json_path)