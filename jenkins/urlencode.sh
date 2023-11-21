#!/bin/bash

###
# @Author: dvlproad
# @Date: 2023-04-13 10:40:15
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 20:10:51
# @Description:
###

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"


networkParams='
{"id":"123", "verbosity":"high"}
'

query_string=$(python3 ${CurrentDIR_Script_Absolute}/urlencode.py "${networkParams}")
if [ $? != 0 ]; then
    echo "${RED}urlencode.py脚本执行失败。${query_string}${NC}"
    exit 1
fi
echo "${GREEN}恭喜:query_string编码后的值如下:${BLUE} ${query_string} ${NC}"


