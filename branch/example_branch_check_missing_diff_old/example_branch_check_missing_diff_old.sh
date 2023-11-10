#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-06 14:42:37
 # @FilePath: example_branch_check_missing_diff_old.sh
 # @Description: 测试
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


branch_check_missing_diff_old_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_missing_diff_old.sh"


BRANCHLASTPACK_BRANCHINFO_FILE_PATH="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastPack.json"
BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_currentPack.json"
PACKED_BRANCHINFO_IN_KEY="package_merger_branchs"
PACKED_DATESTRING_IN_KEY="package_merger_branchs_searchFromDateString"
LAST_ONLINE_VERSION_JSON_FILE="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastOnline.json"
ONLINE_BRANCHINFO_IN_KEY="online_brances"
Personnel_FILE_PATH="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_personel.json"

CURRENT_PACK_BRANCH_NAMES=$(cat "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" | jq ".${PACKED_BRANCHINFO_IN_KEY}" | jq -r '.[].name') # -r 去除字符串引号
CURRENT_PACK_FROM_DATE=$(cat ${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH} | jq -r ".${PACKED_DATESTRING_IN_KEY}")
LAST_PACK_BRANCH_NAMES=$(cat "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" | jq ".${PACKED_BRANCHINFO_IN_KEY}" | jq -r '.[].name') # -r 去除字符串引号
LAST_PACK_FROM_DATE=$(cat ${BRANCHLASTPACK_BRANCHINFO_FILE_PATH} | jq -r ".${PACKED_DATESTRING_IN_KEY}")
LAST_ONLINE_BRANCH_NAMES=$(cat "${LAST_ONLINE_VERSION_JSON_FILE}" | jq ".${ONLINE_BRANCHINFO_IN_KEY}" | jq -r '.[].name') # -r 去除字符串引号
sh ${branch_check_missing_diff_old_scriptPath} -curPackBranchNames "${CURRENT_PACK_BRANCH_NAMES}" -curPackFromDate "${CURRENT_PACK_FROM_DATE}" -lastPackBranchNames "${LAST_PACK_BRANCH_NAMES}" -lastPackFromDate "${LAST_PACK_FROM_DATE}" -lastOnlineBranchNames "${LAST_ONLINE_BRANCH_NAMES}" \
    -peoJsonF "${Personnel_FILE_PATH}"
if [ $? != 0 ]; then
    exit 1
fi