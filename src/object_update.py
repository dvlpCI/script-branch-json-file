'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-05-19 16:36:14
FilePath: get_util.py
Description: object的更新
'''
# -*- coding: utf-8 -*-

def update_dict_value(dictionary, key_name, value):
    if dictionary is None:
        print("您要更新的 dictionary 不能为空，请检查")
        return False
    
    try:
        keys = key_name.split(".")
        sub_dict = dictionary
        for key in keys[:-1]:
            if key not in sub_dict:
                sub_dict[key] = {}
            sub_dict = sub_dict[key]
        
        last_key = keys[-1]
        sub_dict[last_key] = value
        
    except (KeyError, TypeError) as e:
        print(f"{key_name} 的 {key}")
        print(f"Error occurred: 在更新 {key_name} 的时候发生错误，请检查，详细错误错误为 {e}")
        return False
    return dictionary


# old_json_data={
#     "create_time": "11.29",
#     "submit_test_time": "null",
#     "pass_test_time": "null",
#     "merger_pre_time": "null",
#     "type": "null",
#     "name": "main",
#     "des": "详见outlines",
#     "outlines": [
#         {
#             "title": "版本管理显示及分类优化"
#         }
#     ],
#     "answer": {
#         "name": "产品"
#     },
#     "tester": {
#         "name": "测试"
#     }
# }

# import json

# new_json_data=update_dict_value(old_json_data, "answer.name", "张三")
# print(f"{json.dumps(new_json_data, indent=2, ensure_ascii=False)}")

# new_json_data=update_dict_value(old_json_data, "apier.name", "李四")
# print(f"{json.dumps(new_json_data, indent=2, ensure_ascii=False)}")