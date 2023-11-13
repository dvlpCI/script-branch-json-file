#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-02-27 19:02:53
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-06 14:55:41
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

while [ -n "$1" ]
do
    case "$1" in
        -checkBranchName|--check-branch-name) CHECK_BRANCH_NAME=$2; shift 2;;
        -checkInNetwork|--check-in-network-type) CHECK_IN_NETWORK_TYPE=$2; shift 2;;
        -checkByJsonFile|--check-by-json-file) CHECK_BY_JSON_FILE=$2; shift 2;;
        --) break ;;
        *) break ;;
    esac
done

if [ -z "${CHECK_BRANCH_NAME}" ]; then
    echo "缺失 -checkBranchName 参数，请检查。"
    exit 1
fi

if [ -z "${CHECK_IN_NETWORK_TYPE}" ]; then
    echo "缺失 -checkInNetwork 参数，请检查。"
    exit 1
fi

if [ ! -f "${CHECK_BY_JSON_FILE}" ]; then
    echo "您的 -checkByJsonFile 的参数值指向的文件 ${CHECK_BY_JSON_FILE} 不存在，请检查。"
    exit 1
fi

CHECK_BRANCH_NAME=${CHECK_BRANCH_NAME##*/}
# echo "------CHECK_BRANCH_NAME=$CHECK_BRANCH_NAME"
# echo "------CHECK_IN_NETWORK_TYPE=${CHECK_IN_NETWORK_TYPE}"


# 获取指定环境的所有打包依据
# 是map时候
#network_PgyerRootMapString=$(cat ${CHECK_BY_JSON_FILE} | ${JQ_EXEC} -r --arg networkKey "$networkKey" '.[].$networkKey')
# 是数组时候
network_PgyerRootMapString=$(cat ${CHECK_BY_JSON_FILE} | ${JQ_EXEC} -r ".[] | select(.network==\"${CHECK_IN_NETWORK_TYPE}\")")
# echo "network_PgyerRootMapString=${network_PgyerRootMapString}"
if [ "${network_PgyerRootMapString}" == "null" ] || [ -z "${network_PgyerRootMapString}" ]; then
    exit_with_response_error_message "您的 ${CHECK_BY_JSON_FILE} 文件中没有指定环境 ${CHECK_IN_NETWORK_TYPE} 的配置，请检查！"
fi


# 遍历所有允许打包的依据，检查指定分支是否可打包及其依据
network_allowBranchConfig_String=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig[]")
if [ -z "${network_allowBranchConfig_String}" ] || [ "${network_allowBranchConfig_String}" == "null" ]; then
    exit_with_response_error_message "您的 ${CHECK_BY_JSON_FILE} 文件中缺少 .allowBranchConfig 数组数据，请检查！"
fi

network_allowBranchConfig_Count=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig|length")
# echo "network_allowBranchConfig_Count=${network_allowBranchConfig_Count},\n network_allowBranchConfig_String=${network_allowBranchConfig_String}"

hasFoundBranchConfig='false'
targetAllowBranchConfig_String=""
for ((i=0;i<network_allowBranchConfig_Count;i++))
do
    iAllowBranchConfig_String=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig[$i]")
    #debug_log "$((i+1)) iAllowBranchConfig_String=${iAllowBranchConfig_String}"

    # 1、有配置正则的时候，先判断是否符合正则
    allowBranchRegularsString=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchRegulars")
    if [ -n "${allowBranchRegularsString}" ] && [ "${allowBranchRegularsString}" != "null" ]; then
        debug_log "${CHECK_IN_NETWORK_TYPE}环境支持使用符合以下正则的分支来打包，正则内容如下: ${allowBranchRegularsString}"
        allowBranchsRegularCount=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchRegulars|length")
        #debug_log "$((i+1)) allowBranchsNameCount=${allowBranchsNameCount}, allowBranchNamesString=${allowBranchNamesString}"
        for ((j=0;j<allowBranchsRegularCount;j++))
        do
            allowBranchRegular=$(echo "${allowBranchRegularsString}" | ${JQ_EXEC} -r ".[$j]")
            #debug_log "$((i+1)).$((j+1)) allowBranchRegular=${allowBranchRegular}, CHECK_BRANCH_NAME=${CHECK_BRANCH_NAME}"
            # if echo "${allowBranchNamesString[@]}" | grep -wq "*" &>/dev/null; then
            if echo "$CHECK_BRANCH_NAME" | grep -qE "${allowBranchRegular}"; then
                targetAllowBranchConfig_String=$iAllowBranchConfig_String
                hasFoundBranchConfig='true'
                break
            fi
        done

        if [ "${hasFoundBranchConfig}" == 'true' ]; then
            debug_log "恭喜:${CHECK_IN_NETWORK_TYPE}环境支持使用${CHECK_BRANCH_NAME}分支来打包(附其判断依据为:${targetAllowBranchConfig_String})"
            break
        fi
    fi

    # 2、没有配置正则内容的时候，或者匹配不上的时候，判断是否符合具体分支
    allowBranchNamesString=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchNames")
    if [ -n "${allowBranchNamesString}" ] && [ "${allowBranchNamesString}" != "null" ]; then
        allowBranchsNameCount=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchNames|length")
        #echo "$((i+1)) allowBranchsNameCount=${allowBranchsNameCount}, allowBranchNamesString=${allowBranchNamesString}"
        for ((j=0;j<allowBranchsNameCount;j++))
        do
            allowBranchName=$(echo "${allowBranchNamesString}" | ${JQ_EXEC} -r ".[$j]")
            #echo "$((i+1)).$((j+1)) allowBranchName=${allowBranchName}, CHECK_BRANCH_NAME=${CHECK_BRANCH_NAME}"
            if [ "${allowBranchName}" == ${CHECK_BRANCH_NAME} ]; then
                debug_log "---------------------------------"
                targetAllowBranchConfig_String=$iAllowBranchConfig_String
                hasFoundBranchConfig='true'
                break
            fi
        done

        if [ "${hasFoundBranchConfig}" == 'true' ]; then
            debug_log "恭喜:${CHECK_IN_NETWORK_TYPE}环境支持使用${CHECK_BRANCH_NAME}分支来打包(附其判断依据为:${targetAllowBranchConfig_String})"
            break
        fi
    fi
done

if [ "${hasFoundBranchConfig}" != 'true' ]; then
    exit_with_response_error_message "失败:${CHECK_IN_NETWORK_TYPE}环境不支持使用${CHECK_BRANCH_NAME}分支来打包"
fi



message="恭喜:${CHECK_IN_NETWORK_TYPE}环境支持使用${CHECK_BRANCH_NAME}分支来打包。"
debug_log "判断依据如下：\n${targetAllowBranchConfig_String} 。\n原本依据：${network_PgyerRootMapString}"

responseJsonString='{
    "code": 0
}'
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')
printf "%s" "${responseJsonString}"