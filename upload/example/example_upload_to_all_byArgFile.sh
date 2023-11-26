#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-28 02:15:50
 # @Description: 测试上传ipa到各个平台,平台参数来源于文件
### 


# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}      # 使用 %/* 方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

# ipa_file_path="${CurrentDIR_Script_Absolute}/App1Enterprise/App1Enterprise.ipa"
ipa_file_path="~/Project/CQCI/script-qbase/upload_app/App1Enterprise/App1Enterprise.ipa"
if [[ $ipa_file_path =~ ^~.* ]]; then
    # 如果 $ipa_file_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    ipa_file_path="${HOME}${ipa_file_path:1}"
fi

# updateDesString="测试蒲公英上传到指定位置，请勿下载"
updateDesFromFilePath="${CurrentDIR_Script_Absolute}/example_upload_to_all_byArgFile.json"
updateDesFromFileKey="package_des.chinese"

UploadPlatformArgsJson='
{
    "pgyer": {
        "owner": "xxxx@qq.com",
        "appKey": "da2bc35c7943aa78e66ee9c94fdd0824",
        "uploadChannelShortcut": "fzgy",
        "uploadChannelKey": "uploadChannelKey",
        "downloadChannelShortcut": "fzgy",
        "downloadChannelKey": "downloadChannelKey",
        "website_official": "xxx",
        "website_download": "yyy"
    },
    "cos": {
        "region": "ap-shanghai",
        "bucketName": "prod-xhw-image-1302324914",
        "bucketDir": "/mcms/download/app",
        "hostUrl": "https://images.xihuanwu.com"
    },
    "testFlight": {
        "username": "",
        "password": "",
        "website_official": "xxx",
        "website_download": "yyy"
    }
}
'

UploadPlatformArgsFilePath="${CurrentDIR_Script_Absolute}/example_upload_to_all_byArgFile.json"
UploadPlatformArgsFileKey="package_platform_arg"
UploadResult_FILE_Key="upload_result"


# 日志机器人的配置
LogPostToRobotUrl="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"
LogPostTextHeader="这是上传过程中对日志进行补充的标题"


# 示例
log_title "1.上传ipa到各个平台,平台参数来源于文件"
# sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh -ipa "${ipa_file_path}" \
#     -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
#     -uploadArgsFPath "${UploadPlatformArgsFilePath}" -uploadArgsFKey "${UploadPlatformArgsFileKey}" -uploadResultFKey "${UploadResult_FILE_Key}" \
#     -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}"
#     exit
responseJsonString=$(sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -uploadArgsFPath "${UploadPlatformArgsFilePath}" -uploadArgsFKey "${UploadPlatformArgsFileKey}" -uploadResultFKey "${UploadResult_FILE_Key}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    echo "${RED}Error❌:上传ipa到各个平台,平台参数来源于文件的错误信息如下:\n${BLUE} ${responseJsonString} ${RED}。${NC}"
    exit 1
fi

echo "${GREEN}上传ipa到各个平台成功。信息如下：${BLUE} \n$(cat "${UploadPlatformArgsFilePath}" | jq ".${UploadResult_FILE_Key}") ${GREEN}。\n更多详情请查看: ${UploadPlatformArgsFilePath} ${NC}"



# 示例
log_title "2.上传ipa到各个平台,平台参数来源于JsonString"
# sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh -ipa "${ipa_file_path}" \
#     -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
#     -uploadArgsJson "${UploadPlatformArgsJson}" -uploadResultFKey "${UploadResult_FILE_Key}" \
#     -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}"
#     exit
responseJsonString=$(sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -uploadArgsJson "${UploadPlatformArgsJson}" -uploadResultFKey "${UploadResult_FILE_Key}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    echo "${RED}Error❌:上传ipa到各个平台,平台参数来源于文件的错误信息如下:\n${BLUE} ${responseJsonString} ${RED}。${NC}"
    exit 1
fi

echo "${GREEN}上传ipa到各个平台成功。信息如下：${BLUE} \n$(cat "${UploadPlatformArgsFilePath}" | jq ".${UploadResult_FILE_Key}") ${GREEN}。\n更多详情请查看: ${UploadPlatformArgsFilePath} ${NC}"