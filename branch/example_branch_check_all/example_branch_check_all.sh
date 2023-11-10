#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-09 23:45:12
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
ExampleCheckSelfName_HomeDir_Absolute=${CategoryFun_HomeDir_Absolute}/example_branch_check_self_name
ExampleCheckMissingByMust_HomeDir_Absolute=${CategoryFun_HomeDir_Absolute}/example_branch_check_missing_by_must
ExampleCheckMissingDiffOld_HomeDir_Absolute=${CategoryFun_HomeDir_Absolute}/example_branch_check_missing_diff_old

branch_all_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_all.sh"

# check self name
CHECK_BRANCH_NAME="development"
CHECK_IN_NETWORK_TYPE="product"
CHECK_BY_JSON_FILE="${ExampleCheckSelfName_HomeDir_Absolute}/example_branch_check_self_name.json"
# check missing by must
# CHECK_BRANCH_NAME="dev_all"
HAS_CONTAIN_BRANCH_NAMES=("feature/login_wechat" "optimize/mall_goodsdetail")
MUST_CONTAIN_BY_JSON_FILE="${ExampleCheckMissingByMust_HomeDir_Absolute}/example_branch_check_missing_by_must.json"


# check missing diff old
BRANCHLASTPACK_BRANCHINFO_FILE_PATH="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastPack.json"
BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_currentPack.json"
PACKED_BRANCHINFO_IN_KEY="package_merger_branchs"
PACKED_DATESTRING_IN_KEY="package_merger_branchs_searchFromDateString"
LAST_ONLINE_VERSION_JSON_FILE="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastOnline.json"
ONLINE_BRANCHINFO_IN_KEY="online_brances"
Personnel_FILE_PATH="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_personel.json"

ignoreCheckBranchNameArray="(master development)"
# ignoreCheckBranchNameArray="ignoreAll"

sh ${branch_all_scriptPath} \
    -checkBranchName "${CHECK_BRANCH_NAME}" -checkInNetwork "${CHECK_IN_NETWORK_TYPE}" -checkByJsonFile "${CHECK_BY_JSON_FILE}" \
    -hasContainBranchNames "${HAS_CONTAIN_BRANCH_NAMES[*]}" -mustContainByJsonFile "${MUST_CONTAIN_BY_JSON_FILE}" \
    -branchLastPackJsonF "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" -branchCurPackJsonF "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" -packBranchInfoInKey "${PACKED_BRANCHINFO_IN_KEY}" -packDateStringInKey "${PACKED_DATESTRING_IN_KEY}" \
    -lastOnlineJsonF "${LAST_ONLINE_VERSION_JSON_FILE}" -onlineBranchInfoInKey "${ONLINE_BRANCHINFO_IN_KEY}" \
    -peoJsonF "${Personnel_FILE_PATH}" \
    -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}"
if [ $? != 0 ]; then
    exit 1
fi