#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-11-16 16:50:27
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-18 14:44:34
 # @Description: 检查360加固的多渠道配置文件是否合规(接收文件路径作为参数)
### 
#!/bin/bash

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

while [ -n "$1" ]
do
    case "$1" in
        -channelTxtF|--channel-txt-file-path) ChannelTxtFilePath=$2; shift 2;;
        # -firstElementMustPerLine|--firstElementMustPerLine) firstElementMustPerLine=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done


# 检查文件是否存在
if [ ! -f "$ChannelTxtFilePath" ]; then
  echo "您要转化的360加固配置文件不存在，请检查您的 -channelTxtF 的参数值 $ChannelTxtFilePath 。"
  exit 1
fi


# 初始化 JSON 数组
json_array="["


# 逐行检查文件内容是否符合规范
while IFS= read -r line; do
  # 打印每一行的内容
  debug_log "行内容: $line"

  # 切割行内容为数组
  IFS=' ' read -ra elements <<< "$line"

  # 检查元素数量是否为3
  if [ "${#elements[@]}" -ne 3 ]; then
    echo "不符合规范: 元素数量不为3"
    exit 1
  fi

  # 检查第一个元素是否为CHANNEL
  # if [ "${elements[0]}" != "${firstElementMustPerLine}" ]; then
  #   echo "不符合规范: 第一个元素不是${firstElementMustPerLine}"
  #   exit 1
  # fi

  # 提取最后一个元素，并检查最后一个元素是否只包含字母和数字
  last_element="${elements[2]}"
  if [[ ! "$last_element" =~ ^[[:alnum:]]+$ ]]; then
    echo "不符合规范: 最后一个元素不只包含字母和数字"
    exit 1
  fi

  debug_log "符合规范"
  name="${elements[1]}"
  value="${elements[2]}"
  # 拼接 JSON 对象
  json_object="{ \"name\": \"$name\", \"value\": \"$value\" },"
  # 添加到 JSON 数组
  json_array+="$json_object"

done < "$ChannelTxtFilePath"


# 移除最后一个逗号
json_array=${json_array%,}

# 结束 JSON 数组
json_array+="]"

# 输出到 JSON 文件
printf "%s" "$json_array"
