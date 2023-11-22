import sys
import urllib.parse

networkParams = {}
networkParamArray = [{"name": "id", "value": "123"},
                     {"name": "verbosity", "value": "high"}]
for param in networkParamArray:
    # print(f"param={param}")
    key = param["name"]
    value = param["value"]
    networkParams[key] = value
query_string = urllib.parse.urlencode(networkParams)
print(f"query_string={query_string}")


# 原始数据
data = {"name": "John", "age": 30, "city": "New York"}
print("原始的数据:", data)

# 编码数据
encoded_data = urllib.parse.urlencode(data)

# 解码数据
decoded_data = urllib.parse.parse_qsl(encoded_data)
decoded_dict = dict(decoded_data)
print("再解码数据:", decoded_dict)
