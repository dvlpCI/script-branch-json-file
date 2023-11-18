#!/usr/bin/env python3

import sys
from pypinyin import pinyin, Style

chinese_string = sys.argv[1]
# chinese_string = "你好世界123abc✅"
converted = []

def debug_log(message):
    message
    # print(f"{message}")
        
for char in chinese_string:
    if '\u4e00' <= char <= '\u9fff':  # 判断是否为中文字符
        debug_log(f"\"{char}\":中文字符");
        pinyin_list = pinyin(char, style=Style.NORMAL, errors="ignore")
        if pinyin_list:
            converted.extend([p[0] for p in pinyin_list])
    elif char.isalnum(): # 先排除掉了中文字符，这里才不会出现把中文字符也归为此类
        # print(f"\"{char}\":字母或者数字");
        if char.isdigit():
            debug_log(f"\"{char}\":数字");
        elif char.isalpha():
            debug_log(f"\"{char}\":字母");
        converted.append(char)
    else:
        debug_log(f"\"{char}\":其他(将废弃)");

converted_string = "".join(converted)
print(converted_string)