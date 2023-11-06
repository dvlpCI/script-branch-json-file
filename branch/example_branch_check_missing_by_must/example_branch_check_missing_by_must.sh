#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-06 15:35:13
 # @FilePath: example_branch_check_missing_by_must.sh
 # @Description: 测试 检查指定的分支有没有合入其必须合入的所有分支
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


branch_check_missing_by_must_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_missing_by_must.sh"


log_title "测试检查指定的分支有没有合入其必须合入的所有分支"
CHECK_BRANCH_NAME="dev_all"
HAS_CONTAIN_BRANCH_NAMES=("feature/login_wechat" "optimize/mall_goodsdetail")
MUST_CONTAIN_BY_JSON_FILE="${Example_HomeDir_Absolute}/example_branch_check_missing_by_must.json"
echo "${YELLOW}正在执行命令(检查分支是否包含应该包含的分支):《${BLUE} sh ${branch_check_missing_by_must_scriptPath} -checkBranchName \"${CHECK_BRANCH_NAME}\" -hasContainBranchNames \"${HAS_CONTAIN_BRANCH_NAMES[*]}\" -mustContainByJsonFile \"${MUST_CONTAIN_BY_JSON_FILE}\" ${YELLOW}》。${NC}"
sh ${branch_check_missing_by_must_scriptPath} -checkBranchName "${CHECK_BRANCH_NAME}" -hasContainBranchNames "${HAS_CONTAIN_BRANCH_NAMES[*]}" -mustContainByJsonFile "${MUST_CONTAIN_BY_JSON_FILE}"
if [ $? -eq 0 ]; then
    exit 1
fi