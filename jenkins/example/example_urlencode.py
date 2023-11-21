import sys
import urllib.parse

networkParams={}
networkParamArray=[{"name":"id", "value":"123"}, {"name":"verbosity", "value":"high"}]
for param in networkParamArray:
    # print(f"param={param}")
    key=param["name"]
    value=param["value"]
    networkParams[key]=value
query_string = urllib.parse.urlencode(networkParams)
print(f"query_string={query_string}")



networkParams={"id":"123", "verbosity":"high"}
query_string = urllib.parse.urlencode(networkParams)
print(f"query_string={query_string}")