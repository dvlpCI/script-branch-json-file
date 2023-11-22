#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-23 20:48:26
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-21 22:29:39
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


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..



# 设置 Jenkins 服务器的地址、用户名和 API token
JENKINS_USER="lichaoqian"
JENKINS_API_TOKEN="114a967bff5f8cc3a4803aea747f2ddec4"
JENKINS_URL="http://192.168.72.211:8080"
JOB_NAME="wish_android"


title="HelloWorld$(date +%Y%m%d%H%M%S)"

BRANCH="origin/chore/pack"
PackageNetworkType="测试环境1"
PackageTargetType="生成最后只发布到蒲公英的包"
PgyerUploadUrlType="不上传"
ChangeLog="这是更新说明"
NotificatePeople="none"
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
    "title": "'"${title}"'",
    "BRANCH": "'"${BRANCH}"'",
    "PackageNetworkType": "'"${PackageNetworkType}"'",
    "PackageTargetType": "'"${PackageTargetType}"'",
    "PgyerUploadUrlType": "'"${PgyerUploadUrlType}"'",
    "ChangeLog": "'"${ChangeLog}"'",
    "NotificatePeople": "'"${NotificatePeople}"'",
    "channelsJsonString": '${channelsJsonString}'
}
'


# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# 📢注意：通过urlencode传递的 channelsJsonString 参数，在收到后需要执行以下代码，才能转回正常的值
# echo "===========old_channelsJsonString=${channelsJsonString}"
# channelsJsonStringFilePath_old="${CurrentDIR_Script_Absolute}/channelsJsonString_old.json"
# echo "$channelsJsonString" > "${channelsJsonStringFilePath_old}"
# echo "===========channelsJsonStringFilePath_old=${channelsJsonStringFilePath_old}"
# echo ""
# channelsJsonString=$(echo "${channelsJsonString}" | sed 's/^"//;s/"$//')
# channelsJsonString=$(echo "${channelsJsonString}" | sed "s/'/\"/g") # 将字符串中的所有的单引号换成双引号
# echo "===========new_channelsJsonString=${channelsJsonString}"
# channelsJsonStringFilePath_new="${CurrentDIR_Script_Absolute}/channelsJsonString_new.json"
# echo "$channelsJsonString" > "${channelsJsonStringFilePath_new}"
# echo "===========channelsJsonStringFilePath_new=${channelsJsonStringFilePath_new}"


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
