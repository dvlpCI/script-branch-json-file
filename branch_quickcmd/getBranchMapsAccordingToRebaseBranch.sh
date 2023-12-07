#!/bin/bash

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
fi
# echo "========       last_arg=${last_arg}"

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
else # 最后一个元素不是 verbose
    verbose=false
fi

function debug_log() {
    if [ "${verbose}" == true ]; then
        echo "$1"
    fi
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurCategoryFun_HomeDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
qbase_homedir_abspath=${CurCategoryFun_HomeDir_Absolute%/*}   # 使用 %/* 方法可以避免路径上有..

branch_check_self_name_scriptPath="${qbase_homedir_abspath}/branch/branch_check_self_name.sh"
branch_check_missing_by_must_scriptPath="${qbase_homedir_abspath}/branch/branch_check_missing_by_must.sh"
branch_check_missing_diff_old_scriptPath="${qbase_homedir_abspath}/branch/branch_check_missing_diff_old.sh"


quickCmdArgs="$@"
# echo "==========所有参数为: ${quickCmdArgs[*]}"

# shift 1
while [ -n "$1" ]
do
    case "$1" in
        # branch_quickcmd/getBranchNames_accordingToRebaseBranch.sh
        -rebaseBranch|--rebase-branch) REBASE_BRANCH=$2; shift 2;;
        -addValue|--add-value) add_value="$2" shift 2;;
        -addType|--add-type) add_type="$2" shift 2;;
        -onlyName|--only-name) ONLY_NAME=$2; shift 2;; # 名字是否只取最后部分，不为true时候为全名

        # branch_check_self_name
        # -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        -checkInNetwork|--check-in-network-type) CHECK_IN_NETWORK_TYPE=$2; shift 2;;
        -checkByJsonFile|--check-by-json-file) CHECK_BY_JSON_FILE=$2; shift 2;;
        # branch_check_missing_by_must
        # -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        # -hasContainBranchNames|--check-branch-has-contain) HAS_CONTAIN_BRANCH_NAMES=$2; shift 2;;
        -mustContainByJsonFile|--check-must-by-json-file) MUST_CONTAIN_BY_JSON_FILE=$2; shift 2;;
        # branch_check_missing_diff_old
        -shouldCheckMissingDiffOld|--should-checkMissing-diffOld) shouldCheckMissingDiffOld=$2; shift 2;;
        # -curPackBranchNames|--curPack-branchNames) CURRENT_PACK_BRANCH_NAMES=$2; shift 2;; # 本分支【当前打包】的所有分支名数组字符串
        # -curPackFromDate|--curPack-fromDateString) CURRENT_PACK_FROM_DATE=$2; shift 2;; # 本分支【当前打包】的所获得的所有分支名数组是从哪个时间点开始获取来的
        -lastPackBranchNames|--lastPack-branchNames) LAST_PACK_BRANCH_NAMES=$2; shift 2;; # 本分支【上次打包】的所有分支名数组字符串
        -lastPackFromDate|--lastPack-fromDateString) LAST_PACK_FROM_DATE=$2; shift 2;; # 本分支【上次打包】的所获得的所有分支名数组是从哪个时间点开始获取来的
        -lastOnlineBranchNames|--lastOnline-branchNames) LAST_ONLINE_BRANCH_NAMES=$2; shift 2;; # 本分支【上次上线】的所有分支名数组字符串
        -peoJsonF|--product-personnel-json-file) Personnel_FILE_PATH=$2; shift 2;; # 可选：人物文件，用来当有缺失时候，获取该分支谁负责
        

        # branchMaps_10_resouce_get/addBranchMaps_toJsonFile.sh
        -branchMapsFromDir|--branchMaps-is-from-dir-path) BranceMaps_From_Directory_PATH=$2; shift 2;;
        -branchMapsAddToJsonF|--branchMaps-add-to-json-file) BranchMapAddToJsonFile=$2; shift 2;;
        -branchMapsAddToKey|--branchMaps-add-to-key) BranchMapAddToKey=$2; shift 2;;
        # -requestBranchNamesString|--requestBranchNamesString) requestBranchNamesString=$2; shift 2;;
        # -checkPropertyInNetwork|--package-network-type) CheckPropertyInNetworkType=$2; shift 2;;
        -ignoreCheckBranchNames|--ignoreCheck-branchNameArray) ignoreCheckBranchNameArray=$2; shift 2;;
        -shouldDeleteHasCatchRequestBranchFile|--should-delete-has-catch-request-branch-file) shouldDeleteHasCatchRequestBranchFile=$2; shift 2;; # 如果脚本执行成功是否要删除掉已经捕获的文件(一般用于在版本归档时候删除就文件)

        # 发送信息 notification/notification2wechat.sh
        -robot|--robot-url) ROBOT_URL=$2; shift 2;;
        # 注意📢：at 属性，尽在text时候有效,markdown无效。所以如果为了既要markdown又要at，则先markdown值，再at一条text信息。
        -at|--at-middleBracket-ids-string) 
            shift 1; avalue="$@"; # shift 1; 去除-at的key，然后使用 $@ 取剩余的数据，注意这个参数要放在最后，不然会取错
            # 提取以 ] 结尾的值作为 AtMiddleBracketIdsString
            # 在Mac的shell下，如果你希望打印$a的原始值而不是解释转义字符，你可以使用printf命令而不是echo命令。printf命令可以提供更精确的控制输出格式的能力。
            AtMiddleBracketIdsString=$(printf "%s" "$avalue" | grep -o ".*\]") # 不需要写成 '".*\]"'
            # 去除首尾的双引号
            AtMiddleBracketIdsString=${AtMiddleBracketIdsString#\"}
            AtMiddleBracketIdsString=${AtMiddleBracketIdsString%\"}
            # 计算数组个数
            array_count=$(echo "$bvalue" | sed 's/[^,]//g' | wc -c)
            array_count=$((array_count))
            # echo "AtMiddleBracketIdsString count: $array_count"
            shift $array_count;;
        # -xxx|--xxx) xxx=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

debug_log "========1.1=======✅-rebaseBranch:${REBASE_BRANCH}"
debug_log "========1.2=======✅--add-value:${add_value}"
debug_log "========1.3=======✅--add-type:${add_type}"
debug_log "========1.4=======✅-onlyName:${ONLY_NAME}"
debug_log "========2.1=======✅-branchMapsFromDir:${BranceMaps_From_Directory_PATH}"
debug_log "========2.2=======✅-branchMapsAddToJsonF:${BranchMapAddToJsonFile}"
debug_log "========2.3=======✅-branchMapsAddToKey:${BranchMapAddToKey}"

# debug_log "========2.3=======✅-showCategoryName:${showCategoryName}"
# debug_log "========2.3=======✅-showFlag:${showBranchLogFlag}"
# debug_log "========2.3=======✅-showName:${showBranchName}"
# debug_log "========2.3=======✅-showTime:${showBranchTimeLog}"
# debug_log "========2.3=======✅-showAt:${showBranchAtLog}"
# debug_log "========2.3=======✅-shouldMD:${shouldMarkdown}"
lowercase_shouldMarkdown=$(echo "$shouldMarkdown" | tr '[:upper:]' '[:lower:]') # 将值转换为小写形式
if [[ "${lowercase_shouldMarkdown}" == "true" ]]; then # 将shouldMarkdown的值转换为小写
    msgtype='markdown'
else
    msgtype='text'
fi
function printfAndNotificationErrorMessage() {
    errorMessage=$1
    printf "%s" "${errorMessage}" # 这是错误信息，其内部已经对输出内容，添加${RED}等颜色区分了
    notification2wechat_scriptPath=$(qbase -path notification2wechat)
    sh ${notification2wechat_scriptPath} -robot "${ROBOT_URL}" -content "${errorMessage}" -at "${AtMiddleBracketIdsString}" -msgtype "${msgtype}"
    if [ $? != 0 ]; then
        exit 1
    fi
}


debug_log "========2.5=======✅-shouldDeleteHasCatchRequestBranchFile:${shouldDeleteHasCatchRequestBranchFile}"

# 发送信息所需的参数
# debug_log "========3.1=======✅-robot:${ROBOT_URL}"
# debug_log "========3.2=======✅-at:${AtMiddleBracketIdsString}"
# debug_log "========3.4=======✅-xxx:${xxx}"


echo "\n---------- getBranchNamesAccordingToRebaseBranch ----------"
# qbase_getBranchNames_accordingToRebaseBranch_scriptPath=$(qbase -path getBranchNames_accordingToRebaseBranch)
debug_log "${YELLOW}正在执行命令(根据rebase,获取分支名):《${BLUE} qbase -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch \"${REBASE_BRANCH}\" -addValue \"${add_value}\" -addType \"${add_type}\" -onlyName \"${ONLY_NAME}\" ${YELLOW}》${NC}"
resultBranchResponseJsonString=$(qbase -quick getBranchNamesAccordingToRebaseBranch -rebaseBranch "${REBASE_BRANCH}" -addValue "${add_value}" -addType "${add_type}" -onlyName "${ONLY_NAME}")
if [ $? != 0 ]; then
    echo "${resultBranchResponseJsonString}"
    exit 1
fi
if ! jq -e . <<< "$resultBranchResponseJsonString" >/dev/null 2>&1; then
    echo "❌ getBranchNamesAccordingToRebaseBranch 失败，返回的结果不是json。其内容如下:"
    echo "$resultBranchResponseJsonString"
    exit 1
fi
resultBranchNames=$(printf "%s" "${resultBranchResponseJsonString}" | jq -r '.mergerRecords')
resultBranchNames_searchFromDate=$(printf "%s" "${resultBranchResponseJsonString}" | jq -r '.searchFromDate')
if [ -z "${resultBranchNames}" ]; then
    echo "${RED}您当前目录${BLUE}($PWD)${RED}下的项目，没有新的提交记录，更不用说分支了，请检查确保cd到正确目录，或者提交了代码。${NC}"
    exit 1
fi
echo "${GREEN}恭喜：获取当前分支【在 rebase ${REBASE_BRANCH} 后】的所有分支名的结果如下：${BLUE} $resultBranchNames ${GREEN}。${NC}"



    CHECK_BRANCH_NAME=$(git branch --show-current) # 获取当前分支

    HAS_CONTAIN_BRANCH_NAMES=${resultBranchNames}

    CURRENT_PACK_BRANCH_NAMES=${resultBranchNames}
    CURRENT_PACK_FROM_DATE=${resultBranchNames_searchFromDate}


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
    if ! jq -e . <<< "$check_self_name_responseJsonString" >/dev/null 2>&1; then
        echo "❌ check_self_name 失败，返回的结果不是json。其内容如下:"
        echo "$check_self_name_responseJsonString"
        exit 1
    fi

    check_self_name_responseCode=$(printf "%s" "$check_self_name_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_self_name_responseMessage=$(printf "%s" "$check_self_name_responseJsonString" | jq -r '.message')
    if [ "${check_self_name_responseCode}" != 0 ]; then
        echo "${RED} ${check_self_name_responseMessage}\n${check_self_name_SkipTip} ${NC}"
        exit 1
    fi
    echo "${GREEN}$check_self_name_responseMessage${NC}"
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
    if ! jq -e . <<< "$check_missing_by_must_responseJsonString" >/dev/null 2>&1; then
        echo "❌ check_missing_by_must 失败，返回的结果不是json。其内容如下:"
        echo "$check_missing_by_must_responseJsonString"
        exit 1
    fi

    check_missing_by_must_responseCode=$(printf "%s" "$check_missing_by_must_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_missing_by_must_responseMessage=$(printf "%s" "$check_missing_by_must_responseJsonString" | jq -r '.message')
    if [ "${check_missing_by_must_responseCode}" != 0 ]; then
        echo "${RED}${check_missing_by_must_responseMessage}\n${check_missing_by_must_SkipTip} ${NC}"
        exit 1
    fi
    echo "${GREEN}$check_missing_by_must_responseMessage${NC}"
fi


echo "\n---------- check_missing_diff_old ----------"
if [ "${shouldCheckMissingDiffOld}" != "true" ]; then
    echo "${YELLOW}跳过：您的 -shouldCheckMissingDiffOld 的参数值 ${shouldCheckMissingDiffOld} 不是 true ，所以此次不会进行分支遗漏的检查，请留意并且其他检查将继续。${NC}"
else
    check_missing_diff_old_responseJsonString=$(sh ${branch_check_missing_diff_old_scriptPath} -curPackBranchNames "${CURRENT_PACK_BRANCH_NAMES}" -curPackFromDate "${CURRENT_PACK_FROM_DATE}" -lastPackBranchNames "${LAST_PACK_BRANCH_NAMES}" -lastPackFromDate "${LAST_PACK_FROM_DATE}" -lastOnlineBranchNames "${LAST_ONLINE_BRANCH_NAMES}" \
        -peoJsonF "${Personnel_FILE_PATH}")
    if [ $? != 0 ]; then
        exit 1
    fi
    if ! jq -e . <<< "$check_missing_diff_old_responseJsonString" >/dev/null 2>&1; then
        echo "❌ check_missing_diff_old 失败，返回的结果不是json。其内容如下:"
        echo "$check_missing_diff_old_responseJsonString"
        exit 1
    fi

    check_missing_diff_old_responseCode=$(printf "%s" "$check_missing_diff_old_responseJsonString" | jq -r '.code') # jq -r 去除双引号
    check_missing_diff_old_responseMessage=$(printf "%s" "$check_missing_diff_old_responseJsonString" | jq -r '.message')
    if [ "${check_missing_diff_old_responseCode}" != 0 ]; then
        echo "${RED}${check_missing_diff_old_responseMessage}\n${YELLOW}附：若不想进行此分支遗漏检查，请勿设置${BLUE} -shouldCheckMissingDiffOld ${YELLOW}即可。${NC}"
        exit 1
    fi
    echo "${GREEN}$check_missing_diff_old_responseMessage${NC}"
fi



echo "\n---------- addBranchMaps_toJsonFile + checkMap ----------"
qbase_addBranchMaps_toJsonFile_scriptPath=$(qbase -path addBranchMaps_toJsonFile)
requestBranchNameArray=${resultBranchNames}
CheckPropertyInNetworkType=${CHECK_IN_NETWORK_TYPE}
debug_log "========r.r=======✅-requestBranchNamesString:${requestBranchNameArray[*]}"
debug_log "${YELLOW}正在执行命令(获取所有指定分支名的branchMaps输出到指定文件中):《${BLUE} sh ${qbase_addBranchMaps_toJsonFile_scriptPath} -branchMapsFromDir \"${BranceMaps_From_Directory_PATH}\" -branchMapsAddToJsonF \"${BranchMapAddToJsonFile}\" -branchMapsAddToKey \"${BranchMapAddToKey}\" -requestBranchNamesString \"${requestBranchNameArray[*]}\" -checkPropertyInNetwork \"${CheckPropertyInNetworkType}\" -ignoreCheckBranchNames \"${ignoreCheckBranchNameArray}\" -shouldDeleteHasCatchRequestBranchFile \"${shouldDeleteHasCatchRequestBranchFile}\" ${YELLOW}》${NC}"
errorMessage=$(sh ${qbase_addBranchMaps_toJsonFile_scriptPath} -branchMapsFromDir "${BranceMaps_From_Directory_PATH}" -branchMapsAddToJsonF "${BranchMapAddToJsonFile}" -branchMapsAddToKey "${BranchMapAddToKey}" -requestBranchNamesString "${requestBranchNameArray[*]}" -checkPropertyInNetwork "${CheckPropertyInNetworkType}" -ignoreCheckBranchNames "${ignoreCheckBranchNameArray}" -shouldDeleteHasCatchRequestBranchFile "${shouldDeleteHasCatchRequestBranchFile}")
if [ $? != 0 ]; then
    printfAndNotificationErrorMessage "${errorMessage}"
    exit 1
fi
echo "${GREEN}恭喜：获取branchMaps成功，详情查看${BLUE} ${BranchMapAddToJsonFile} ${GREEN}。${NC}"