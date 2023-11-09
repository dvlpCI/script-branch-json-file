#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 19:02:53
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-11-09 23:59:53
 # @Description: 检查指定的分支能否打包指定的环境
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

exit_with_response_error_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    if [ -z "${responseJsonString}" ]; then
        responseJsonString='{
            "code": 1
        }'
    fi
    message=$1

    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
    exit 1
}

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}


JQ_EXEC=`which jq`

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute} # 使用此方法可以避免路径上有..

branch_check_self_name_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_self_name.sh"
branch_check_missing_by_must_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_missing_by_must.sh"
branch_check_missing_diff_old_scriptPath="${CategoryFun_HomeDir_Absolute}/branch_check_missing_diff_old.sh"



while [ -n "$1" ]
do
    case "$1" in
        # branch_check_self_name
        -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        -checkInNetwork|--check-in-network-type) CHECK_IN_NETWORK_TYPE=$2; shift 2;;
        -checkByJsonFile|--check-by-json-file) CHECK_BY_JSON_FILE=$2; shift 2;;
        # branch_check_missing_by_must
        # -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        -hasContainBranchNames|--check-branch-has-contain) HAS_CONTAIN_BRANCH_NAMES=$2; shift 2;;
        -mustContainByJsonFile|--check-must-by-json-file) MUST_CONTAIN_BY_JSON_FILE=$2; shift 2;;
        # branch_check_missing_diff_old
        -branchLastPackJsonF|--branch-lastPack-branchInfo-json-file) BRANCHLASTPACK_BRANCHINFO_FILE_PATH=$2; shift 2;; # 本分支最后一个打包的分支信息
        -branchCurPackJsonF|--branch-curPack-branchInfo-json-file) BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH=$2; shift 2;; # 本分支当前打包的分支信息
        -packBranchInfoInKey|--packed-branchInfo-in-key) PACKED_BRANCHINFO_IN_KEY=$2; shift 2;; # 打包生成的分支信息在文件中的哪个key
        -packDateStringInKey|--packed-dateString-in-key) PACKED_DATESTRING_IN_KEY=$2; shift 2;; # 打包时间在文件中的哪个key

        -lastOnlineJsonF|--last-online-package-json-file) LAST_ONLINE_VERSION_JSON_FILE=$2; shift 2;; # 当前线上最有一个版本的分支信息文件
        -onlineBranchInfoInKey|--online-branchInfo-in-key) ONLINE_BRANCHINFO_IN_KEY=$2; shift 2;; # 上线版本的分支信息在文件中的哪个key

        -peoJsonF|--product-personnel-json-file) Personnel_FILE_PATH=$2; shift 2;; # 可选：人物文件，用来当有缺失时候，获取该分支谁负责
        --) break ;;

        *) break ;;
    esac
done


if [ ! -f "${CHECK_BY_JSON_FILE}" ]; then
    echo "${YELLOW}您用于【检查分支名】合规的配置文件不存在，所以此次不会检查，请检查${BLUE} ${CHECK_BY_JSON_FILE} ${YELLOW}。${NC}"
else
    check_self_name_responseJsonString=$(sh ${branch_check_self_name_scriptPath} -checkBranchName "${CHECK_BRANCH_NAME}" -checkInNetwork "${CHECK_IN_NETWORK_TYPE}" -checkByJsonFile "${CHECK_BY_JSON_FILE}")
    if [ $? != 0 ]; then
        echo "$check_self_name_responseJsonString" # 此时是错误信息
        exit 1
    fi
fi

if [ ! -f "${MUST_CONTAIN_BY_JSON_FILE}" ]; then
    echo "${YELLOW}您用于【检查分支必须包含的分支】合规的配置文件不存在，所以此次不会检查，请检查${BLUE} ${MUST_CONTAIN_BY_JSON_FILE} ${YELLOW}。${NC}"
else
    # echo "${YELLOW}正在执行命令(检查分支是否包含应该包含的分支):《${BLUE} sh ${branch_check_missing_by_must_scriptPath} -checkBranchName \"${CHECK_BRANCH_NAME}\" -hasContainBranchNames \"${HAS_CONTAIN_BRANCH_NAMES[*]}\" -mustContainByJsonFile \"${MUST_CONTAIN_BY_JSON_FILE}\" ${YELLOW}》。${NC}"
    check_missing_by_must_responseJsonString=$(sh ${branch_check_missing_by_must_scriptPath} -checkBranchName "${CHECK_BRANCH_NAME}" -hasContainBranchNames "${HAS_CONTAIN_BRANCH_NAMES[*]}" -mustContainByJsonFile "${MUST_CONTAIN_BY_JSON_FILE}")
    if [ $? != 0 ]; then
        echo "$check_missing_by_must_responseJsonString" # 此时是错误信息
        exit 1
    fi
fi


if [ ! -f "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" ]; then
    echo "${YELLOW}您要检查的【本分支当前打包的分支信息】文件不存在，所以此次不会检查，请检查${BLUE} ${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH} ${YELLOW}。${NC}"
else
    sh ${branch_check_missing_diff_old_scriptPath} -branchLastPackJsonF "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" -branchCurPackJsonF "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" -packBranchInfoInKey "${PACKED_BRANCHINFO_IN_KEY}" -packDateStringInKey "${PACKED_DATESTRING_IN_KEY}" \
        -lastOnlineJsonF "${LAST_ONLINE_VERSION_JSON_FILE}" -onlineBranchInfoInKey "${ONLINE_BRANCHINFO_IN_KEY}" \
        -peoJsonF "${Personnel_FILE_PATH}"
    if [ $? != 0 ]; then
        exit 1
    fi
fi