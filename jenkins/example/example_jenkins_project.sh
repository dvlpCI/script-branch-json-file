#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-21 17:57:40
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 20:40:15
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

# jenkinUrl="http://192.168.72.211:8080/job/wish_iOS_测试/buildWithParameters?PackageNetworkType=%E6%B5%8B%E8%AF%95%EF%BC%88%E6%B5%8B%E8%AF%95%E4%B8%80%E5%92%8C%E6%B5%8B%E8%AF%95%E4%BA%8C%EF%BC%89&BRANCH=tia&ChangeLog=fi&NotificatePeople=all&MultiChannel=false&channelNames=xiaomi+vivo+oppo+yingyongbao+360+baidu+alibaba+general+douyin&Test1=True&Test2=True&UseDoKit=true"
# jenkinJobHomeUrl=$(echo "$jenkinUrl" | sed -E 's/\job.*$//')    # 去掉.com/之后(含.com)的字符串
# echo "jenkinJobHomeUrl=${jenkinJobHomeUrl}"
# exit

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



echo "\n"
log_title "2.获取要执行的 jenkins job url"
jenkin_input_result_file_path=${Example_HomeDir_Absolute}/example_jenkins_input_result2.json
# echo "正在执行命令：《 sh ${qtool_jenkins_scriptPath} \"${jenkin_input_result_file_path}\" 》"
sh ${qtool_jenkins_scriptPath} "${jenkin_input_result_file_path}"


jenkinUrlCount=$(cat "${jenkin_input_result_file_path}" | jq ".|length")
echo "jenkinUrlCount=${jenkinUrlCount}"
for((i=0;i<jenkinUrlCount;i++));
do
    jenkinUrl=$(cat "${jenkin_input_result_file_path}" | jq -r ".jenkinsUrls[${i}]")
    echo "$((i+1)).${GREEN}${jenkinUrl}${NC}"


    jenkinJobHomeUrl=$(echo "$jenkinUrl" | sed -E 's/\job.*$//')    # 去掉.com/之后(含.com)的字符串
    echo "jenkinJobHomeUrl=${jenkinJobHomeUrl}"
    open "${jenkinJobHomeUrl}"
done

