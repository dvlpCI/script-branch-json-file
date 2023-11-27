#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-26 19:00:32
 # @FilePath: example_branch_check_missing_by_must.sh
 # @Description: 测试 蒲公英参数的获取
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

getUploadArg_pgyer_scriptPath="${CategoryFun_HomeDir_Absolute}/getUploadArg_pgyer.sh"




log_title "测试蒲公英上传参数"
Pgyer_Download_FILE_PATH="${Example_HomeDir_Absolute}/example_getUploadArg_pgyer.json"
Pgyer_Download_FILE_KEY=""
PgyerUploadUrlType="toUploadUrl"
PlatformType="iOS"
PackageNetworkType="product"
CurrentBranchName="version/v1.2.0_0811"
sh ${getUploadArg_pgyer_scriptPath} -pgyerJsonsFPath "${Pgyer_Download_FILE_PATH}" -pgyerJsonsFKey "${Pgyer_Download_FILE_KEY}" -pgyerUploadUrlType "${PgyerUploadUrlType}" -pl "${PlatformType}" -pn "${PackageNetworkType}" -curBranchName "${CurrentBranchName}"
if [ $? != 0 ]; then
    exit 1
fi