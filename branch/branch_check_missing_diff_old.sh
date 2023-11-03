#!/bin/bash
:<<!
检查本分支的本次打包是否漏掉本分支上次打包的分支
# 主要是为了处理情况1：某个版本分支一直打包，但突然该版本分支合入错误，需要删除掉重新rebase再重新合入所有功能分支。
# 分支打包文件 version/v1.2.3_1009.json \ master.json
# 所以，分支的比较不能先以 rebase 时间判断是不是新版本的第一次打包
checkHasMissingBranchDiffOld
!

JQ_EXEC=`which jq`

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

responseJsonString='{

}'
exit_response_with_code_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
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
    exit "$code"
}


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
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

if [ -z "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" ]; then
    echo "缺少 -branchLastPackJsonF 参数，请补充"
    exit 1
fi

if [ -z "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" ]; then
    echo "缺少 -branchCurPackJsonF 参数，请补充"
    exit 1
fi

if [ -z "${PACKED_BRANCHINFO_IN_KEY}" ]; then
    echo "缺少 -packBranchInfoInKey 参数，请补充"
    exit 1
fi
if [ -z "${PACKED_DATESTRING_IN_KEY}" ]; then
    echo "缺少 -packDateStringInKey 参数，请补充"
    exit 1
fi


if [ -z "${LAST_ONLINE_VERSION_JSON_FILE}" ]; then
    echo "缺少 -lastOnlineJsonF 参数，请补充"
    exit 1
fi

if [ -z "${ONLINE_BRANCHINFO_IN_KEY}" ]; then
    echo "缺少 -onlineBranchInfoInKey 参数，请补充"
    exit 1
fi



    
allContainBranchArray=$(cat "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" | ${JQ_EXEC} ".${PACKED_BRANCHINFO_IN_KEY}") # -r 去除字符串引号
#echo "allContainBranchArray=${allContainBranchArray}"
if [ -z "${allContainBranchArray}" ] || [ "${allContainBranchArray}" == "null" ]; then
    allContainBranchArray="" # null" 也设置成空字符串
    exit_response_with_code_message -code 1 -message "❌Error:未找到当前分支合入的其他分支信息，将退出allContainBranchArray=${allContainBranchArray}"
fi
allContainBranchNames=$(cat "${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH}" | ${JQ_EXEC} ".${PACKED_BRANCHINFO_IN_KEY}" | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
allContainBranchNames=($allContainBranchNames) # 此时才是真正的数组
debug_log "本分支【本次打包】包含的分支功能allContainBranchNames值如下:\n${allContainBranchNames[*]}\n"

if [ ! -f "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" ]; then # BRANCHLASTPACK_BRANCHINFO_FILE_PATH 加引号，避免名称中有空格，导致的错误
    exit_response_with_code_message -code 0 -message "您的 ${BRANCHLASTPACK_BRANCHINFO_FILE_PATH} 文件不存在，代表当前包是上线包之后的第一次打包"
fi
debug_log "本分支最后一个打包的分支信息的文件存在，即代表当前包在上线包之后已经有打过包了，所以要检查下新的包是否都包含了之前的包的需求功能，防止漏掉出现测试bug重新打开问题"

#[在shell脚本中验证JSON文件的语法](https://qa.1r1g.com/sf/ask/2966952551/)
lastPackageInfoFileJsonString=$(cat "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" | json_pp) # 文件名加引号，加引号，避免名称中有空格，导致的错误
#echo "lastPackageInfoFileJsonString=${lastPackageInfoFileJsonString}"
lastPackageInfoFileJsonLength=${#lastPackageInfoFileJsonString}
#echo "lastPackageInfoFileJsonLength=${#lastPackageInfoFileJsonLength}"
if [ ${lastPackageInfoFileJsonLength} == 0 ]; then
    exit_response_with_code_message -code 1 -message "您的 ${BRANCHLASTPACK_BRANCHINFO_FILE_PATH} 不是标准的json格式，弃用，本次忽略检查新包是否包含旧包"
fi


lastFeatureBranceNamesArray=$(cat "${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}" | ${JQ_EXEC} ".${PACKED_BRANCHINFO_IN_KEY}" | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
lastFeatureBranceNamesArray=($lastFeatureBranceNamesArray) # 此时才是真正的数组
debug_log "下面将验证本分支此次打包应是否至少包含本分支【上次打包】包含的如下所有分支功能:\n${lastFeatureBranceNamesArray[*]}\n"

lastFeatureBranceNameCount=${#lastFeatureBranceNamesArray[@]}
for ((i=0;i<lastFeatureBranceNameCount;i++))
do
    devBranchName=${lastFeatureBranceNamesArray[i]}
    if [ ${i} -gt 0 ]; then
        debug_log "\n"
    fi
    if [[ "${allContainBranchNames[*]}" =~ ${devBranchName} ]]; then
        debug_log "恭喜:新包包含旧包的${devBranchName}"
    else
        debug_log "抱歉❌:新包缺失旧包的${devBranchName}"
        missingContainBranchNameArray[${#missingContainBranchNameArray[@]}]=${devBranchName}
    fi
done
# 未发现丢失分支
if [ -z "${missingContainBranchNameArray}" ]; then
    exit_response_with_code_message -code 0 -message "恭喜:新包包含旧包的所有分支功能"
fi



# 发现了可能丢失的分支，比如所有版本的测试包都用 dev_all 分支打包，则会出现缺失了某些功能，但实际上是因为上线后rebase了
mayMissingWarningMessage="您当前打包的需求较上次有所缺失，缺失分支${#missingContainBranchNameArray[@]}个,如下:${missingContainBranchNameArray[*]} 。"

current_searchFromDateString=$(cat ${BRANCHCURRENTPACK_BRANCHINFO_FILE_PATH} | ${JQ_EXEC} -r ".${PACKED_DATESTRING_IN_KEY}")
old_searchFromDateString=$(cat ${BRANCHLASTPACK_BRANCHINFO_FILE_PATH} | ${JQ_EXEC} -r ".${PACKED_DATESTRING_IN_KEY}")
debug_log "old_searchFromDateString=${old_searchFromDateString}"
debug_log "current_searchFromDateString=${current_searchFromDateString}"
if [ "${current_searchFromDateString}" != "${old_searchFromDateString}" ]; then # BRANCHLASTPACK_BRANCHINFO_FILE_PATH 加引号，避免名称中有空格，导致的错误
    debug_log "$mayMissingWarningMessage 但由于此次打包是上次上线代码合并${current_searchFromDateString}后的第一次打包，所以会进一步检查所漏分支是不是因为已经上线。(排查方法:所漏分支在最后一个版本里)"
    
    lastVersionFeatureBranceArray=$(cat "${LAST_ONLINE_VERSION_JSON_FILE}" | ${JQ_EXEC} ".${ONLINE_BRANCHINFO_IN_KEY}") # -r 去除字符串引号
    if [ $? != 0 ] || [ "${lastVersionFeatureBranceArray}" == "null" ]; then
        exit_response_with_code_message -code 1 -message "您的 ${LAST_ONLINE_VERSION_JSON_FILE} 文件中没有找到 ${ONLINE_BRANCHINFO_IN_KEY} 字段，请检查是不是其不存在或者位置不对。"
    fi

    lastVersionFeatureBranceNamesArray=$(printf "%s" "${lastVersionFeatureBranceArray}" | ${JQ_EXEC} -r '.[].name') # -r 去除字符串引号
    if [ $? != 0 ]; then
        exit_response_with_code_message -code 1 -message "您的 ${LAST_ONLINE_VERSION_JSON_FILE} 文件中 ${ONLINE_BRANCHINFO_IN_KEY} 数组字段值不对，请检查。"
    fi
    lastVersionFeatureBranceNamesArray=($lastVersionFeatureBranceNamesArray) # 此时才是真正的数组
    lastVersionFeatureBranceNamesCount=${#lastVersionFeatureBranceNamesArray[@]}
    debug_log "最后上线的版本有${lastVersionFeatureBranceNamesCount}个分支,分别如下lastVersionFeatureBranceNamesArray=${lastVersionFeatureBranceNamesArray[*]}"
    
    missingContainBranchNameCount=${#missingContainBranchNameArray[@]}
    for ((i=0;i<missingContainBranchNameCount;i++))
    do
        mayMissingBranchName=${missingContainBranchNameArray[i]}
        if [ ${i} -gt 0 ]; then
            debug_log "\n"
        fi
        if [[ "${lastVersionFeatureBranceNamesArray[*]}" =~ ${mayMissingBranchName} ]]; then
            debug_log "恭喜:新包相比旧包丢失的${mayMissingBranchName}已上线"
        else
            debug_log "抱歉:新包相比旧包丢失的${mayMissingBranchName}未上线"
            realMissingContainBranchNameArray[${#realMissingContainBranchNameArray[@]}]=${mayMissingBranchName}
        fi
    done
    
else
    debug_log "$mayMissingWarningMessage 且由于此次打包不是上次上线代码合并${current_searchFromDateString}后的第一次打包，所以不会进一步检查所漏分支是不是因为已经上线。(排查方法:所漏分支在最后一个版本里)"
    realMissingContainBranchNameArray=${missingContainBranchNameArray}
fi

# 没有实际缺失的分支
if [ -z "${realMissingContainBranchNameArray}" ]; then
    exit_response_with_code_message -code 0 -message "恭喜:新包包含旧包的所有分支功能"
fi

# 确实有缺失的分支
PackageErrorMessage="您当前打包的需求较上次有所缺失，请先补全，再打包，缺失分支${#realMissingContainBranchNameArray[@]}个,如下:${realMissingContainBranchNameArray[*]}。"
PackageErrorMessage+="可能原因如下:这些分支未合并进来，或者是其有新的提交也会造成这个问题。"
PackageErrorMessage+="具体信息如下:之前分支功能有${lastFeatureBranceNamesArray[*]}。而现在功能是${allContainBranchNames[*]}。"
PackageErrorMessage+="【附：如果某个分支已确实不需要使用。可以前往${BRANCHLASTPACK_BRANCHINFO_FILE_PATH}删除.package_merger_branchs中的那个分支】"
## 获取缺失的分支是谁负责的
realMissingContainBranchNameCount=${#realMissingContainBranchNameArray[@]}

# 获取分支最后提交用户信息
function getBranchLastCommitUserMap() {
    branchName=$1

    # 检查分支是否不存在
    if ! git rev-parse --quiet --verify "origin/$branchName" >/dev/null; then
        echo "分支 origin/$branchName 不存在，您可执行《 echo \$(git rev-parse --quiet --verify origin/\"${branchName}\") 》验证，有值就代表存在。"
        return 1
    fi

    debug_log "正在执行命令(获取指定本地分支最后一次提交的用户)：《 git show --format=%aN -b origin/\"${branchName}\" -s 》"
    branchLastCommitUserName=$(git show --format=%aN -b origin/"${branchName}" -s)
    # debug_log "正在执行命令(获取指定远程分支最后一次提交的用户，有些分支返回正常，有些分支失败)：《git ls-remote --heads \"${branchName}\" | cut -f 1 | xargs -I {} git show --format=%aN {} -s | head -n 1》"
    # branchLastCommitUserName=$(git ls-remote --heads "${branchName}" | cut -f 1 | xargs -I {} git show --format=%aN {} -s | head -n 1)
    if [ $? != 0 ]; then
        echo "执行命令(获取指定本地分支最后一次提交的用户)失败：《 git show --format=%aN -b origin/\"${branchName}\" -s 》"
        return 0
    fi

    if [ ! -f "${Personnel_FILE_PATH}" ]; then
        echo "您用来获取分支最后提交用户信息的文件 ${Personnel_FILE_PATH} 不存在，请检查 -peoJsonF 参数值。"
        return 1
    fi
    # [jq --arg传递的变量select()没有硬编码值就不能工作吗？](https://cloud.tencent.com/developer/ask/sof/355822/answer/594723)
    Product_Personnel_Array=$(cat ${Personnel_FILE_PATH} | ${JQ_EXEC} -r '.[]') # -r 去除字符串引号
    # echo ${Product_Personnel_Array} | ${JQ_EXEC} -r --arg branchLastCommitUserName "$branchLastCommitUserName" 'select(.git_name=="qian")' 
    # echo ${Product_Personnel_Array} | ${JQ_EXEC} -r --arg branchLastCommitUserName "$branchLastCommitUserName" 'select(.git_name==$branchLastCommitUserName)'
    CurrentBranch_Personnel_Map=$(echo ${Product_Personnel_Array} | ${JQ_EXEC} -r --arg branchLastCommitUserName "$branchLastCommitUserName" 'select(.git_name==$branchLastCommitUserName)') # -r 去除字符串引号
    if [ -z "${CurrentBranch_Personnel_Map}" ] || [ "${CurrentBranch_Personnel_Map}" == "null" ]; then
        echo "您用来获取分支最后提交用户信息的文件 $ 中的 .git_name 属性不存在值为 $branchLastCommitUserName 的用户"
        return 1
    fi
    printf "%s" "${CurrentBranch_Personnel_Map}"
}
for ((i=0;i<realMissingContainBranchNameCount;i++))
do
    realMissingBranchName=${realMissingContainBranchNameArray[i]}
    branch_Personnel_Map=$(getBranchLastCommitUserMap "${realMissingBranchName}")
    # getBranchLastCommitUserMap "${realMissingBranchName}"
    # branch_Personnel_Map=$CurrentBranch_Personnel_Map
    if [ $? != 0 ]; then
        # echo "$branch_Personnel_Map" # 此时此值是错误信息
        CurrentBranch_Personnel_Uid="${realMissingBranchName}_unkonw_last_commit_uid"
    else
        CurrentBranch_Personnel_Uid=$(printf "%s" ${branch_Personnel_Map} | ${JQ_EXEC} -r ".uid") # -r 去除字符串引号
    fi
    realMissingBranchUidArray[${#realMissingBranchUidArray[@]}]=${CurrentBranch_Personnel_Uid}
done


# 整理发现丢失的结果并输出
code=1
message=$PackageErrorMessage
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg code "$code" '. + { "code": $code }')
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg message "$message" '. + { "message": $message }')

responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg missingBranchUserWechatId "${realMissingBranchUidArray[*]}" '. + { "missingBranchUserWechatId": $missingBranchUserWechatId }')
responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg missingBranchNames "${realMissingContainBranchNameArray[*]}" '. + { "missingBranchNames": $missingBranchNames }')
printf "%s" "${responseJsonString}"
