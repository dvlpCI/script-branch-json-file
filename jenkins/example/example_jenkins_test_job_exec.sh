#!/bin/bash

###
# @Author: dvlproad
# @Date: 2023-04-13 10:40:15
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 22:30:52
# @Description:
###
# curl -X POST JENKINS_URL/job/JOB_NAME/build \
#   --user USER:TOKEN \
#   --data-urlencode json='{"parameter": [{"name":"id", "value":"123"}, {"name":"verbosity", "value":"high"}]}'
# 1. 执行指定的 Jenkins 作业
# 2. 等待作业执行完成，并检查作业执行结果。
# 3. 如果作业执行成功，则输出日志信息。

# 请注意，这个示例脚本需要使用 curl 命令和 Python 3 运行 Python 脚本。如果您的系统上没有安装 curl 和 Python 3，请先安装它们。

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..




while [ -n "$1" ]
do
    case "$1" in
        -jenkinsUserName|--jenkins-user-name) JENKINS_USER=$2; shift 2;;
        -jenkinsUserToken|--jenkins-user-token) JENKINS_API_TOKEN=$2; shift 2;;
        -jenkins-base-url|--jenkins-base-url) JENKINS_URL=$2; shift 2;;
        -jobName|--job-name) JOB_NAME=$2; shift 2;;
        -jobParamJsonString|--job-parameter-json) JOB_PARAM_JsonString=$2; shift 2;;
        # -firstElementMustPerLine|--firstElementMustPerLine) firstElementMustPerLine=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done



# curl -X POST JENKINS_URL/job/JOB_NAME/build \
#   --user "$JENKINS_USER":"$JENKINS_API_TOKEN" \
#   --data-urlencode json='{"parameter": [{"name":"id", "value":"123"}, {"name":"verbosity", "value":"high"}]}'

# 设置 Jenkins 服务器的地址、用户名和 API token
JENKINS_USER="lichaoqian"
JENKINS_API_TOKEN="114a967bff5f8cc3a4803aea747f2ddec4"
JENKINS_URL="http://192.168.72.211:8080"
JOB_NAME="test"


title="HelloWorld$(date +%Y%m%d%H%M%S)"
channelsJsonString='
[
  "CHANNEL 华为 huawei",
  "CHANNEL 小米 xiaomi",
  "CHANNEL 抖音 douyin",
  "CHANNEL 360应用平台 1",
  "CHANNEL 谷歌市场 2",
  "CHANNEL 91手机商城 3",
  "CHANNEL 豌豆荚 4",
  "CHANNEL 安卓市场 5"
]'

networkParams='
{
    "id":"123", 
    "verbosity":"high", 
    "other1":"this is a text",
    "title": "'"${title}"'",
    "channelsJsonString": '${channelsJsonString}'
}
'
### 只有你已经在 jenkins 中定义的参数，您才能为其赋值
### 只有你已经在 jenkins 中定义的参数，您才能为其赋值
### 只有你已经在 jenkins 中定义的参数，您才能为其赋值

# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# echo "===========old_channelsJsonString=${channelsJsonString}"
# channelsJsonString=$(echo "$channelsJsonString" | sed "s/'/\"/g") # 将字符串中的所有的单引号换成双引号
# echo "===========new_channelsJsonString=${channelsJsonString}"
# channelsJsonStringFilePath="${CurrentDIR_Script_Absolute}/channelsJsonString.json"
# echo "$channelsJsonString" > "${channelsJsonStringFilePath}"
# echo "===========channelsJsonStringFilePath=${channelsJsonStringFilePath}"


# JOB_PARAM_JsonString='{"parameter": [{"name":"id", "value":"123"}, {"name":"verbosity", "value":"high"}]}'
# JOB_PARAM_JsonString='{"parameter": [{"name":"id", "value":"123"}, {"name":"verbosity", "value":"high"}]}'

# echo "正在执行命令(启动jenkins上的job任务):《 curl -X POST \"$JENKINS_URL\"/job/\"$JOB_NAME\"/build \
# --user \"$JENKINS_USER\":\"$JENKINS_API_TOKEN\" \
# --data-urlencode json=\"${JOB_PARAM_JsonString}\" 》"
# curl -X POST "$JENKINS_URL"/job/"$JOB_NAME"/build \
#   --user "$JENKINS_USER":"$JENKINS_API_TOKEN" \
#   --data-urlencode json="${JOB_PARAM_JsonString}"
# open "${JENKINS_URL}"
# exit 1


query_string=$(python3 ${CategoryFun_HomeDir_Absolute}/urlencode.py "${networkParams}")
if [ $? != 0 ]; then
    echo "${RED}urlencode.py脚本执行失败。${query_string}${NC}"
    exit 1
fi
echo "${GREEN}恭喜:query_string编码后的值如下:${BLUE} ${query_string} ${NC}"
PARAMS=${query_string}



JENKINS_JOB_URL="$JENKINS_URL/job/$JOB_NAME/buildWithParameters?$PARAMS"
echo "正在执行命令：《 curl -sS -X POST -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_JOB_URL\" 》"
curl -sS -X POST -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_JOB_URL"

open "${JENKINS_URL}"

# http://192.168.72.211:8080/job/wish_iOS_测试/buildWithParameters?PackageNetworkType=%E6%B5%8B%E8%AF%95%EF%BC%88%E6%B5%8B%E8%AF%95%E4%B8%80%E5%92%8C%E6%B5%8B%E8%AF%95%E4%BA%8C%EF%BC%89&BRANCH=a&ChangeLog=d&NotificatePeople=all&MultiChannel=false&channelNames=xiaomi+vivo+oppo+yingyongbao+360+baidu+alibaba+general+douyin&Test1=True&Test2=True&UseDoKit=true


# # 等待作业执行完成，并检查作业执行结果
# echo "Waiting for the job to complete..."
# while true; do
#     result=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/api/json | jq -r '.result')
#     if [ "$result" != "null" ]; then
#         if [ "$result" = "SUCCESS" ]; then
#             echo "Job completed successfully!"
#             echo "Log:"
#             curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/consoleText
#             exit 0
#         else
#             echo "Job failed with result: $result"
#             exit 1
#         fi
#     fi
#     sleep 5
# done
