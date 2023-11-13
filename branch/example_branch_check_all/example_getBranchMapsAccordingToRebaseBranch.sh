#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-13 18:55:48
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

qtool_getBranchMapsAccordingToRebaseBranch_scriptPath="${CategoryFun_HomeDir_Absolute}/getBranchMapsAccordingToRebaseBranch.sh"


# branch_quickcmd/getBranchNames_accordingToRebaseBranch.sh
REBASE_BRANCH="origin/master"
add_value="1"
# add_type=
ONLY_NAME="false" # 名字是否只取最后部分，不为true时候为全名


# check self name
CHECK_IN_NETWORK_TYPE="product"
CHECK_BY_JSON_FILE="${ExampleCheckSelfName_HomeDir_Absolute}/example_branch_check_self_name.json"
# check missing by must
MUST_CONTAIN_BY_JSON_FILE="${ExampleCheckMissingByMust_HomeDir_Absolute}/example_branch_check_missing_by_must.json"


# check missing diff old
BRANCHLASTPACK_BRANCHINFO_FILE_PATH="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastPack.json"
PACKED_BRANCHINFO_IN_KEY="package_merger_branchs"
LAST_PACK_BRANCH_NAMES=$(cat "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" | jq ".${PACKED_BRANCHINFO_IN_KEY}" | jq -r '.[].name') # -r 去除字符串引号

PACKED_DATESTRING_IN_KEY="package_merger_branchs_searchFromDateString"
LAST_PACK_FROM_DATE=$(cat ${BRANCHLASTPACK_BRANCHINFO_FILE_PATH} | jq -r ".${PACKED_DATESTRING_IN_KEY}")

LAST_ONLINE_VERSION_JSON_FILE="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastOnline.json"
ONLINE_BRANCHINFO_IN_KEY="online_brances"
LAST_ONLINE_BRANCH_NAMES=$(cat "${LAST_ONLINE_VERSION_JSON_FILE}" | jq ".${ONLINE_BRANCHINFO_IN_KEY}" | jq -r '.[].name') # -r 去除字符串引号

Personnel_FILE_PATH="${ExampleCheckMissingDiffOld_HomeDir_Absolute}/example_branch_check_missing_diff_old_personel.json"


# branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh
BranceMaps_From_Directory_PATH="${CurrentDIR_Script_Absolute}/featureBrances"
BranchMapAddToJsonFile="${CurrentDIR_Script_Absolute}/app_branch_info.json"
BranchMapAddToKey="package_merger_branchs"
ignoreCheckBranchNameArray="(master development dev_publish_out dev_publish_in dev_all)"
shouldDeleteHasCatchRequestBranchFile=false


sh ${qtool_getBranchMapsAccordingToRebaseBranch_scriptPath} \
    -rebaseBranch "${REBASE_BRANCH}" --add-value "${add_value}" -addType "${add_type}" -onlyName "${ONLY_NAME}" \
    -checkInNetwork "${CHECK_IN_NETWORK_TYPE}" -checkByJsonFile "${CHECK_BY_JSON_FILE}" \
    -mustContainByJsonFile "${MUST_CONTAIN_BY_JSON_FILE}" \
    -lastPackBranchNames "${LAST_PACK_BRANCH_NAMES}" -lastPackFromDate "${LAST_PACK_FROM_DATE}" -lastOnlineBranchNames "${LAST_ONLINE_BRANCH_NAMES}" \
    -peoJsonF "${Personnel_FILE_PATH}" \
    -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray}" -shouldDeleteHasCatchRequestBranchFile "${shouldDeleteHasCatchRequestBranchFile}"
if [ $? != 0 ]; then
    exit 1
fi