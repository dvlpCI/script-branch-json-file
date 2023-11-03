#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-11-04 02:01:01
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-04 02:40:03
 # @FilePath: /AutoPackage-CommitInfo/bulidScriptCommon/branchs_can_pack/example/example_branch_check_missing_diff_old.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 
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
LAST_ONLINE_VERSION_JSON_FILE="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_lastPack.json"
ONLINE_BRANCHINFO_IN_KEY="online_brances"
Personnel_FILE_PATH="${Example_HomeDir_Absolute}/example_branch_check_missing_diff_old_personel.json"
sh ${branch_check_missing_diff_old_scriptPath} -branchLastPackJsonF "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" -branchCurPackJsonF "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" -packBranchInfoInKey "${PACKED_BRANCHINFO_IN_KEY}" -packDateStringInKey "${PACKED_DATESTRING_IN_KEY}" \
    -lastOnlineJsonF "${LAST_ONLINE_VERSION_JSON_FILE}" -onlineBranchInfoInKey "${ONLINE_BRANCHINFO_IN_KEY}" \
    -peoJsonF "${Personnel_FILE_PATH}"
if [ $? -eq 0 ]; then
    exit 1
fi