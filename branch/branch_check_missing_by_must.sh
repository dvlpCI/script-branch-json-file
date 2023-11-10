#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 19:02:53
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-06 14:55:41
 # @Description: 检查指定的分支有没有合入其必须合入的所有分支
### 

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

JQ_EXEC=$(which jq)


function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

responseJsonString='{

}'
update_response_with_code_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    while [ -n "$1" ]; do
        case "$1" in
            -code|--code) code=$2; shift 2;;
            -message|--message) message=$2; shift 2;;
            --) break ;;
            *) break ;;
        esac
    done
    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg code "$code" '. + { "code": $code }')
    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
    printf "%s" "${responseJsonString}"
}



while [ -n "$1" ]
do
    case "$1" in
        -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        -hasContainBranchNames|--check-branch-has-contain) HAS_CONTAIN_BRANCH_NAMES=$2; shift 2;;
        -mustContainByJsonFile|--check-must-by-json-file) MUST_CONTAIN_BY_JSON_FILE=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${CHECK_BRANCH_NAME}" ]; then
    echo "缺少 -checkBranchName 参数，请补充"
    exit 1
fi

if [ -z "${HAS_CONTAIN_BRANCH_NAMES}" ]; then
    echo "缺少 -hasContainBranchNames 参数，即未找到/未传入当前分支合入的其他分支信息，请补充"
    exit 1
fi
debug_log "====要检查本分支是否包含以下分支 HAS_CONTAIN_BRANCH_NAMES=${HAS_CONTAIN_BRANCH_NAMES}"


if [ -z "${MUST_CONTAIN_BY_JSON_FILE}" ]; then
    update_response_with_code_message -code 0 -message "缺少 -mustContainByJsonFile 参数，此次将不会进行必须包含的检查"
    exit 0
fi


mustContainMap=$(cat "${MUST_CONTAIN_BY_JSON_FILE}" | ${JQ_EXEC} ".${CHECK_BRANCH_NAME}") # -r 去除字符串引号

# mustContainBranchNames=($mustContainBranchNames) # 外部已把数组换成了字符串
mustContainBranchNames=$(printf "%s" "${mustContainMap}" | ${JQ_EXEC} '.mustContain_branchNames') # -r 去除字符串引号
mustContainReasonText=$(printf "%s" "${mustContainMap}" | ${JQ_EXEC} '.mustContain_reasonText') # -r 去除字符串引号
debug_log "mustContainBranchNames=${mustContainBranchNames[*]}"
#echo "mustContainReasonText=${mustContainReasonText}"
if [ -z "${mustContainBranchNames}" ] || [ "${mustContainBranchNames}" == "null" ]; then
    update_response_with_code_message -code 0 -message "友情提示：您的${CHECK_BRANCH_NAME}分支没有必须合入的分支。"
    exit 0
fi


# 检查是否缺失哪个必须合入的分支
debug_log "本分支有必须要合入的分支的检查,下面开始检查=============="

missingMustContainBranchNameArray=()
mustContainBranchNameCount=$(printf "%s" "${mustContainBranchNames}" | ${JQ_EXEC} '.|length')
for ((i=0;i<mustContainBranchNameCount;i++))
do
    mustContainBranchName=${mustContainBranchNames[i]}
    if [[ "${HAS_CONTAIN_BRANCH_NAMES[*]}" =~ ${mustContainBranchName} ]]; then
        debug_log "本分支有包含必须合入的 ${mustContainBranchName} 分支"
    else
        missingMustContainBranchNameArray[${#missingMustContainBranchNameArray[@]}]=${mustContainBranchName}
    fi
done

# echo "${missingMustContainBranchNameArray[*]}"
if [ ${#missingMustContainBranchNameArray[@]} == 0 ]; then
    update_response_with_code_message -code 0 -message "恭喜，您的${CHECK_BRANCH_NAME}分支包含所有必须合入的分支。即包含 ${mustContainBranchNames[*]} "
    exit 0
fi


PackageErrorMessage="本分支${CHECK_BRANCH_NAME}不能缺少${missingMustContainBranchNameArray[*]}分支上的代码，请检查是否合入且全部合入。"
if [ -n "${mustContainReasonText}" ]; then
    PackageErrorMessage+="（修复帮助：${mustContainReasonText}）"
fi
update_response_with_code_message -code 1 -message "${PackageErrorMessage}"
exit 0



