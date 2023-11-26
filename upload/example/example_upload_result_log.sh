#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-28 18:29:19
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
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

UploadResult_FILE_PATH="${CurrentDIR_Script_Absolute}/example_upload_result_log.json"
UploadResult_FILE_Key="upload_result"


# 示例
log_title "上传结束,获取安装包的各种路径信息"
test_script=${CommonFun_HomeDir_Absolute}/upload_result_log.sh
uploadResultLog=$(sh ${test_script} -uploadResultFPath "${UploadResult_FILE_PATH}" -uploadResultFKey "${UploadResult_FILE_Key}")
if [ $? != 0 ]; then
    echo "${RED}Error❌:上传ipa到各个平台结束后获取各种路径信息的错误信息如下:\n${BLUE} ${uploadResultLog} ${RED}。${NC}"
    exit 1
fi

echo "${GREEN}上传结束后安装包的各种路径信息：${BLUE}\n${uploadResultLog} ${GREEN}。\n更多详情请查看: ${UploadResult_FILE_PATH} ${NC}"