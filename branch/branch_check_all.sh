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
        -curPackBranchNames|--curPack-branchNames) CURRENT_PACK_BRANCH_NAMES=$2; shift 2;; # 本分支【当前打包】的所有分支名数组字符串
        -curPackFromDate|--curPack-fromDateString) CURRENT_PACK_FROM_DATE=$2; shift 2;; # 本分支【当前打包】的所获得的所有分支名数组是从哪个时间点开始获取来的
        -lastPackBranchNames|--lastPack-branchNames) LAST_PACK_BRANCH_NAMES=$2; shift 2;; # 本分支【上次打包】的所有分支名数组字符串
        -lastPackFromDate|--lastPack-fromDateString) LAST_PACK_FROM_DATE=$2; shift 2;; # 本分支【上次打包】的所获得的所有分支名数组是从哪个时间点开始获取来的
        -lastOnlineBranchNames|--lastOnline-branchNames) LAST_ONLINE_BRANCH_NAMES=$2; shift 2;; # 本分支【上次上线】的所有分支名数组字符串

        -peoJsonF|--product-personnel-json-file) Personnel_FILE_PATH=$2; shift 2;; # 可选：人物文件，用来当有缺失时候，获取该分支谁负责
        
        # check map
        -checkBranchMapsInJsonF|--branch-maps-json-file) BranchMaps_JsonFilePath=$2; shift 2;; # 要检查的maps在哪个文件
        -checkBranchMapsInJsonK|--branch-maps-json-key) BranchMapsInJsonKey=$2; shift 2;; # 要检查的maps在文件的哪个key
        -ignoreCheckBranchNames|--ignoreCheck-branchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
        
        --) break ;;

        *) break ;;
    esac
done

echo "\n---------- check_self_name ----------"
if [ ! -f "${CHECK_BY_JSON_FILE}" ]; then
    echo "${YELLOW}跳过：您用于【检查分支名】合规的配置文件不存在，所以此次不会检查，请检查 -checkByJsonFile 的参数值${BLUE} ${CHECK_BY_JSON_FILE} ${YELLOW}。${NC}"
else
    check_self_name_SkipTip="${YELLOW}附：若不想进行此分支名自身检查，请勿设置${BLUE} -checkByJsonFile ${YELLOW}即可。${NC}"
    check_self_name_responseJsonString=$(sh ${branch_check_self_name_scriptPath} -checkBranchName "${CHECK_BRANCH_NAME}" -checkInNetwork "${CHECK_IN_NETWORK_TYPE}" -checkByJsonFile "${CHECK_BY_JSON_FILE}")
    if [ $? != 0 ]; then
        echo "${RED} $check_self_name_responseJsonString\n${check_self_name_SkipTip} ${NC}" # 此时是错误信息
        exit 1
    fi
    check_self_name_responseCode=$(printf "%s" "$check_self_name_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_self_name_responseMessage=$(printf "%s" "$check_self_name_responseJsonString" | jq -r '.message')
    if [ "${check_self_name_responseCode}" != 0 ]; then
        echo "${RED} ${check_self_name_responseMessage}\n${check_self_name_SkipTip} ${NC}"
        exit 1
    fi
    echo "$check_self_name_responseMessage"
fi


echo "\n---------- check_missing_by_must ----------"
if [ ! -f "${MUST_CONTAIN_BY_JSON_FILE}" ]; then
    echo "${YELLOW}跳过：您用于【检查分支必须包含的分支】合规的配置文件不存在，所以此次不会检查，请检查 -mustContainByJsonFile 的参数值 ${BLUE} ${MUST_CONTAIN_BY_JSON_FILE} ${YELLOW}。${NC}"
else
    check_missing_by_must_SkipTip="${YELLOW}附：若不想进行此分支必须包含检查，请勿设置${BLUE} -mustContainByJsonFile ${YELLOW}即可。${NC}"
    # echo "${YELLOW}正在执行命令(检查分支是否包含应该包含的分支):《${BLUE} sh ${branch_check_missing_by_must_scriptPath} -checkBranchName \"${CHECK_BRANCH_NAME}\" -hasContainBranchNames \"${HAS_CONTAIN_BRANCH_NAMES[*]}\" -mustContainByJsonFile \"${MUST_CONTAIN_BY_JSON_FILE}\" ${YELLOW}》。${NC}"
    check_missing_by_must_responseJsonString=$(sh ${branch_check_missing_by_must_scriptPath} -checkBranchName "${CHECK_BRANCH_NAME}" -hasContainBranchNames "${HAS_CONTAIN_BRANCH_NAMES[*]}" -mustContainByJsonFile "${MUST_CONTAIN_BY_JSON_FILE}")
    if [ $? != 0 ]; then
        echo "${RED} $check_missing_by_must_responseJsonString\n${check_missing_by_must_SkipTip} ${NC}" # 此时是错误信息
        exit 1
    fi
    check_missing_by_must_responseCode=$(printf "%s" "$check_missing_by_must_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_missing_by_must_responseMessage=$(printf "%s" "$check_missing_by_must_responseJsonString" | jq -r '.message')
    if [ "${check_missing_by_must_responseCode}" != 0 ]; then
        echo "${RED}${check_missing_by_must_responseMessage}\n${check_missing_by_must_SkipTip} ${NC}"
        exit 1
    fi
    echo "$check_missing_by_must_responseMessage"
fi


echo "\n---------- check_missing_diff_old ----------"
if [ -z "${CURRENT_PACK_BRANCH_NAMES}" ]; then
    echo "${YELLOW}跳过：您要检查的【本分支当前打包的分支名】 -curPackBranchNames 的参数值未设置，所以此次不会检查，请留意并且其他检查将继续。${NC}"
else
    check_missing_diff_old_responseJsonString=$(sh ${branch_check_missing_diff_old_scriptPath} -curPackBranchNames "${CURRENT_PACK_BRANCH_NAMES}" -curPackFromDate "${CURRENT_PACK_FROM_DATE}" -lastPackBranchNames "${LAST_PACK_BRANCH_NAMES}" -lastPackFromDate "${LAST_PACK_FROM_DATE}" -lastOnlineBranchNames "${LAST_ONLINE_BRANCH_NAMES}" \
        -peoJsonF "${Personnel_FILE_PATH}")
    if [ $? != 0 ]; then
        exit 1
    fi

    check_missing_diff_old_responseCode=$(printf "%s" "$check_missing_diff_old_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_missing_diff_old_responseMessage=$(printf "%s" "$check_missing_diff_old_responseJsonString" | jq -r '.message')
    if [ "${check_missing_diff_old_responseCode}" != 0 ]; then
        echo "${RED}${check_missing_diff_old_responseMessage}\n${YELLOW}附：若不想进行此分支遗漏检查，请勿设置${BLUE} -curPackBranchNames ${YELLOW}即可。${NC}"
        exit 1
    fi
    echo "$check_missing_diff_old_responseMessage"
fi


echo "\n---------- check_map ----------"
PackageNetworkType=$CHECK_IN_NETWORK_TYPE
if [  ! -f "${BranchMaps_JsonFilePath}" ]; then
    echo "${YELLOW}跳过：您的 -checkBranchMapsInJsonF 参数值为 ${BranchMaps_JsonFilePath} 指向的文件不存在 ，所以【将不会进行map的属性在${BLUE} ${PackageNetworkType} ${YELLOW}环境下的检查】。${NC}"
else
    errorMessage=$(sh $(qbase -path branchMapsFile_checkMap) -branchMapsJsonF "${BranchMaps_JsonFilePath}" -branchMapsJsonK "${BranchMapsInJsonKey}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray[*]}" -pn "${PackageNetworkType}")
    if [ $? != 0 ]; then
        echo "${RED}${errorMessage}${NC}\n${YELLOW}附：若不想进行此分支文件map哥属性的检查，请勿设置${BLUE} -checkBranchMapsInJsonF ${YELLOW}即可。${NC}"
        exit 1
    fi
    echo "${GREEN}恭喜：检查branchMaps通过，在 ${PackageNetworkType} 环境下未缺失信息。${NC}"
fi



