'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-11-21 20:08:42
FilePath: jenkins_input.py
Description: 对 map 进行 urlencode (array是无效的)
'''
import sys
import json
import urllib.parse

networkParams_json_string = sys.argv[1]
networkParams_json_data = json.loads(networkParams_json_string)

# print(f"networkParams_json_string={networkParams_json_string}")
# print(f"networkParams_json_data={networkParams_json_data}")

query_string = urllib.parse.urlencode(networkParams_json_data)
print(f"{query_string}")


