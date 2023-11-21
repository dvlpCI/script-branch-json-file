#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-18 16:34:07
 # @Description: 360加固的多渠道文件生成
### 
# 渠道配置文件脚本
# 1、渠道值自定义简化与接收转化
# 2、渠道固定值的自动匹配与新增值的智能转义信息完善
# 3、多渠道文件生成与合规校验
# 4、打自定义渠道包的脚本优化



# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qtool_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qtool_360channel_getJsonFile_scriptPath=${CategoryFun_HomeDir_Absolute}/channelFile_toJsonFile_360.sh
qtool_360channel_file_scriptPath=${CategoryFun_HomeDir_Absolute}/channelFile_generate_byChannelNames_360.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}

log_title "1.使用 arrayString 生成多渠道配置文件"
ChannelTxtFilePath="${Example_HomeDir_Absolute}/360channels_fixed.txt"
fixedChannelJsonString=$(sh $qtool_360channel_getJsonFile_scriptPath -channelTxtF "${ChannelTxtFilePath}")
if [ $? != 0 ]; then
  echo "${fixedChannelJsonString}" # 此时此值是错误结果
  exit 1
fi
echo "✅✅✅fixedChannelJsonString=${fixedChannelJsonString}"
iChannelName="荣耀"
# 从 fixedChannelJsonString 中获取 name 等于 iChannelName 的map
iChannelJsonString=$(printf "%s" "${fixedChannelJsonString}" | jq -r ".[]  | select(.name==\"${iChannelName}\")") # -r 去除字符串引号
echo "✅✅✅iChannelJsonString=${iChannelJsonString}"


echo "\n"
log_title "1.使用 arrayString 生成多渠道配置文件"
channelNameArrayString="华为 荣耀 小米 公交 自定义123abc✅"
FixedChannelFile="${Example_HomeDir_Absolute}/360channels_fixed.txt"
outputFilePath="${Example_HomeDir_Absolute}/$(date +"%m%d_%H%M%S").txt"
# outputFilePath="${Example_HomeDir_Absolute}/360channels_result.txt"
firstElementMustPerLine="CHANNEL"
echo "${YELLOW}正在执行测试命令(使用 arrayString 生成多渠道配置文件):《${BLUE} sh $qtool_360channel_file_scriptPath -nameArrayString '${channelNameArrayString}' -outputFile \"${outputFilePath}\" -firstElementMustPerLine \"${firstElementMustPerLine}\" ${YELLOW}》${NC}"
generateResult=$(sh $qtool_360channel_file_scriptPath -nameArrayString "${channelNameArrayString}" -fixedChannelF "${FixedChannelFile}" -outputFile "${outputFilePath}" -firstElementMustPerLine "${firstElementMustPerLine}")
if [ $? != 0 ]; then
  echo "${RED}${generateResult}${NC}"  # 此时此值是错误信息
  exit 1
fi
echo "${GREEN}${generateResult} ${GREEN}。${NC}"
open "${outputFilePath}"
