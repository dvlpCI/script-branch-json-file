#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-11-16 16:43:04
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-18 16:29:10
# @Description: 360加固的多渠道文件生成
###
# 渠道配置文件脚本
# 1、渠道值自定义简化与接收转化
# 2、渠道固定值的自动匹配与新增值的智能转义信息完善
# 3、多渠道文件生成与合规校验
# 4、打自定义渠道包的脚本优化

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"

qtool_channelFile_toJsonFile_360_scriptPath=$CurrentDIR_Script_Absolute/channelFile_toJsonFile_360.sh
qtool_360channel_file_scriptPath=$(qbase -path 360channel_file_generate)
qbase_convert_to_pinyin_scriptPath=$(qbase -path convert_to_pinyin)

# shell 参数具名化
# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -nameArrayString|--nameArrayString) argNameArrayString=$2; shift 2;;
        -fixedChannelF|--fixed-channel-file) FixedChannelFile=$2; shift 2;;
        -outputFile|--output-file-path) outputFilePath=$2; shift 2;;
        -shouldCheckOutput|--shouldCheckOutput) shouldCheckOutput=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ -z "$FixedChannelFile" ]; then
  echo "❌Error:您的 -FixedChannelFile 参数值不能为空，否则无法设置对指定的渠道名设置特殊的渠道号值，请检查。"
  exit 1
fi

if [ -z "$outputFilePath" ]; then
  echo "❌Error:您的 -file 参数值 ${outputFilePath} 不能为空，否则无法创建用来填写配置信息的文件，无法请检查。"
  exit 1
fi

fixedChannelJsonString=$(sh "$qtool_channelFile_toJsonFile_360_scriptPath" -channelTxtF "$FixedChannelFile")
if [ $? != 0 ]; then
  echo "${fixedChannelJsonString}" # 此时此值是错误结果
  exit 1
fi
# echo "✅✅✅fixedChannelJsonString=${fixedChannelJsonString}"
# argNameArrayString --> argNameArray --> argNameArrayString
# 使用set命令将输入字符串拆分为多个参数，并使用eval命令执行这个命令
eval set -- "$argNameArrayString"
channelNameArray=("$@") # 使用"$@"将将拆分结果存储到数组中
channelCount=${#channelNameArray[@]}

# 获取所有渠道名的渠道json信息
requestChannelLineStringArray=()
requestChannelLineStrings=''
happenErrorMessage=""
for ((i = 0; i < channelCount; i++)); do
  iChannelName="${channelNameArray[$i]}"
  # 从 fixedChannelJsonString 中获取 name 等于 iChannelName 的map
  iChannelJsonString=$(printf "%s" "${fixedChannelJsonString}" | jq -r ".[]  | select(.name==\"${iChannelName}\")") # -r 去除字符串引号
  # echo "$((i+1)).iChannelJsonString=${iChannelJsonString}"
  if [ -z "${iChannelJsonString}" ] || [ "${iChannelJsonString}" == "null" ]; then
    # echo "您的[$iChannelName]渠道不是固定值，将自动转化。"
    iChannelValue=$(python3 "$qbase_convert_to_pinyin_scriptPath" -originString "$iChannelName")
    if [ $? != 0 ]; then
      happenErrorMessage="${iChannelName}" # 此时此值是错误结果
      break
    fi
    # echo "您的[$iChannelName]渠道自动转化后的值为:${iChannelValue}"
  else
    # echo "您的[$iChannelName]渠道是固定值，无需转化。"
    iChannelValue=$(printf "%s" "${iChannelJsonString}" | jq -r ".value")
  fi
  iChannelLineString="CHANNEL ${iChannelName} ${iChannelValue}"
  # echo "$((i+1)).iChannelLineString=${iChannelLineString}"
  requestChannelLineStringArray[${#requestChannelLineStringArray[@]}]="${iChannelLineString}"
  if [ $i -gt 0 ]; then
    requestChannelLineStrings+=" "
  fi
  requestChannelLineStrings+="\"${iChannelLineString}\""
done
if [ -n "${happenErrorMessage}" ]; then
  echo "${happenErrorMessage}"
  exit 1
fi

# echo "=======requestChannelLineStrings=${requestChannelLineStrings}"
# argArrayString="'\"${requestChannelLineStrings}\"'"
argArrayString="${requestChannelLineStrings}"

# argArrayString=${requestChannelLineStringArray[*]}
# argArrayCount=${#argArrayString[@]}
# echo "=======argArrayCount=${argArrayCount}"
# for((i=0;i<argArrayCount;i++));
# do
#   echo "=======$((i+1)).${argArrayString[i]}"
# done

# printf "%s\n" "${argArrayString}"

# argArrayString='"CHANNEL 华为 huawei" "CHANNEL 小米 xiaomi" "CHANNEL 公交 gongjiao"'
# printf "%s\n" "${argArrayString}"
# exit
# echo "${YELLOW}正在执行命令(使用 arrayString 生成多渠道配置文件):《${BLUE} sh $qtool_360channel_file_scriptPath -arrayString '${argArrayString}' -outputFile \"${outputFilePath}\" -shouldCheckOutput \"${shouldCheckOutput}\" ${YELLOW}》${NC}"
generateResult=$(sh $qtool_360channel_file_scriptPath -arrayString "${argArrayString}" -outputFile "${outputFilePath}" -shouldCheckOutput "${shouldCheckOutput}")
if [ $? != 0 ]; then
  printf "%s" "${generateResult}"  # 此时此值是错误信息
  exit 1
fi
printf "%s" "${generateResult}"
