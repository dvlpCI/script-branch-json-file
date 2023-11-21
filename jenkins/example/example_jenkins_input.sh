#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-21 17:57:40
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 20:38:09
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

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..


qtool_jenkins_input_scriptPath="${CategoryFun_HomeDir_Absolute}/jenkins_input.py"
qtool_jenkins_scriptPath="${CategoryFun_HomeDir_Absolute}/jenkins.sh"


log_title "1.获取要执行的 jenkins job url"
jenkin_input_result_file_path=${Example_HomeDir_Absolute}/example_jenkins_input_result1.json
python3 "${qtool_jenkins_input_scriptPath}" "${jenkin_input_result_file_path}"
# open "${jenkin_input_result_file_path}"
# jenkinUrlCount=$(cat "${jenkin_input_result_file_path}" | jq ".|length")
# echo "jenkinUrlCount=${jenkinUrlCount}"
# for((i=0;i<jenkinUrlCount;i++));
# do
#     jenkinUrl=$(cat "${jenkin_input_result_file_path}" | jq -r ".jenkinsUrls[${i}]")
#     echo "$((i+1)).${GREEN}${jenkinUrl}${NC}"
# done

echo "恭喜您获得的jenkins的job的url分别如下:"
cat "${jenkin_input_result_file_path}" | jq -r "."
open "${jenkin_input_result_file_path}"
