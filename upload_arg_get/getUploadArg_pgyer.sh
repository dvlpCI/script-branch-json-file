#!/bin/bash

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


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -pgyerDownJsonFPath|--pgyer-download-json-file) Pgyer_Download_FILE_PATH=$2; shift 2;;
        -pgyerDownJsonFKey|--pgyer-download-json-key) Pgyer_Download_FILE_KEY=$2; shift 2;;
        -pgyerUploadUrlType|--pgyer-upload-url-type) PgyerUploadUrlType=$2; shift 2;;
        -p|--platformType) PlatformType=$2; shift 2;;
        -pt|--package_target_type) PackageTargetType=$2; shift 2;;
        -pn|--package_network_type) PackageNetworkType=$2; shift 2;;
        -curBranchName|--current-branch-name) CurrentBranchName=$2; shift 2;;
        --) continue ;;
        *) break ;;
    esac
done


if [ -z "${Pgyer_Download_FILE_PATH}" ] || [ ! -f "${Pgyer_Download_FILE_PATH}" ]; then
    echo "您的 -pgyerDownJsonF 参数值 ${Pgyer_Download_FILE_PATH} 指向的配置所有环境使用的蒲公英上传参数的配置文件不存在，请检查！"
    exit 1
fi

if [ -z "${PgyerUploadUrlType}" ]; then
    echo "您未设置蒲公英上传方式，请检查 -pgyerUploadUrlType 参数"
    exit 1
fi
debug_log "------PgyerUploadUrlType:${PgyerUploadUrlType}"
debug_log "------PlatformType:${PlatformType}"
debug_log "------PackageTargetType:${PackageTargetType}"
debug_log "------PackageNetworkType:${PackageNetworkType}"
ShortBranceName=${CurrentBranchName##*/}
debug_log "------ShortBranceName=$ShortBranceName"

networkKey="${PackageNetworkType}" 
branchKey="${ShortBranceName}" 
platformKey="${PlatformType}"


pgyerParamsRootMapString=$(cat "${Pgyer_Download_FILE_PATH}" | ${JQ_EXEC} -r ".${Pgyer_Download_FILE_KEY}")
if [ "${pgyerParamsRootMapString}" == "null" ] || [ -z "${pgyerParamsRootMapString}" ]; then
    echo "你的${Pgyer_Download_FILE_PATH}中未添加package_pgyer_params参数，会导致即使打包成功，蒲公英也无法上传成功"
    exit 1
fi
# echo "您所有环境的蒲公英配置参数信息如下:"
# printf "%s" "${pgyerParamsRootMapString}" | jq "."
# exit

# 获取指定环境的所有打包依据
# 是map时候
#network_PgyerRootMapString=$(echo ${pgyerParamsRootMapString} | ${JQ_EXEC} -r --arg networkKey "$networkKey" '.[].$networkKey')

# 是数组时候
network_PgyerRootMapString=$(printf "%s" "${pgyerParamsRootMapString}" | jq -r ".[] | select(.network==\"${PackageNetworkType}\")")
# network_PgyerRootMapString=$(jq -r --arg networkType "$PackageNetworkType" '.[] | select(.network == $networkType)' <<< "$pgyerParamsRootMapString")
# debug_log "network_PgyerRootMapString=${network_PgyerRootMapString}"
if [ "${network_PgyerRootMapString}" == "null" ] || [ -z "${network_PgyerRootMapString}" ]; then
    echo "没有 ${PackageNetworkType} 环境的配置，请检查您的参数或者 ${Pgyer_Download_FILE_PATH} 文件中 package_pgyer_params 的值！"
    exit 1
fi
# echo "您 ${PackageNetworkType} 环境的蒲公英配置参数信息如下:"
# printf "%s" "${network_PgyerRootMapString}" | jq "."
# exit

# 遍历所有允许打包的依据，检查指定分支是否可打包及其依据
function checkAndGetAllowBasis() {
    networkKey=$1   #'preproduct'
    branchKey=$2    #'dev_publish_in'
    platformKey=$3  #'iOS'

    network_allowBranchConfig_String=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig[]")
    if [ -z "${network_allowBranchConfig_String}" ] || [ "${network_allowBranchConfig_String}" == "null" ]; then
        echo "执行命令失败(获取所有允许打包的依据):《 echo \"${network_PgyerRootMapString}\" | ${JQ_EXEC} -r \".allowBranchConfig[]\" 》"
        return 1
    fi
    network_allowBranchConfig_Count=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig|length")
    # debug_log "network_allowBranchConfig_Count=${network_allowBranchConfig_Count},\n network_allowBranchConfig_String=${network_allowBranchConfig_String}"
    
    hasFoundBranchConfig='false'
    targetAllowBranchConfig_String=""
    for ((i=0;i<network_allowBranchConfig_Count;i++))
    do
        iAllowBranchConfig_String=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".allowBranchConfig[$i]")
        #debug_log "$((i+1)) iAllowBranchConfig_String=${iAllowBranchConfig_String}"

        # 1、有配置正则的时候，先判断是否符合正则
        allowBranchRegularsString=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchRegulars")
        if [ -n "${allowBranchRegularsString}" ] && [ "${allowBranchRegularsString}" != "null" ]; then
            debug_log "${PackageNetworkType}环境支持使用符合以下正则的分支来打包，正则内容如下：${allowBranchRegularsString}"
            allowBranchsRegularCount=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchRegulars|length")
            #debug_log "$((i+1)) allowBranchsNameCount=${allowBranchsNameCount}, allowBranchNamesString=${allowBranchNamesString}"
            for ((j=0;j<allowBranchsRegularCount;j++))
            do
                allowBranchRegular=$(echo "${allowBranchRegularsString}" | ${JQ_EXEC} -r ".[$j]")
                #debug_log "$((i+1)).$((j+1)) allowBranchRegular=${allowBranchRegular}, branchKey=${branchKey}"
                # if echo "${allowBranchNamesString[@]}" | grep -wq "*" &>/dev/null; then
                if echo "$branchKey" | grep -qE "${allowBranchRegular}"; then
                    targetAllowBranchConfig_String=$iAllowBranchConfig_String
                    hasFoundBranchConfig='true'
                    break
                fi
            done

            if [ "${hasFoundBranchConfig}" == 'true' ]; then
                debug_log "恭喜:${PackageNetworkType}环境支持使用${branchKey}分支来打包(附其判断依据为:${targetAllowBranchConfig_String})"
                break
            fi
        fi

        # 2、没有配置正则内容的时候，或者匹配不上的时候，判断是否符合具体分支
        allowBranchNamesString=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchNames")
        if [ -n "${allowBranchNamesString}" ] && [ "${allowBranchNamesString}" != "null" ]; then
            allowBranchsNameCount=$(echo "${iAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchNames|length")
            #debug_log "$((i+1)) allowBranchsNameCount=${allowBranchsNameCount}, allowBranchNamesString=${allowBranchNamesString}"
            for ((j=0;j<allowBranchsNameCount;j++))
            do
                allowBranchName=$(echo "${allowBranchNamesString}" | ${JQ_EXEC} -r ".[$j]")
                #debug_log "$((i+1)).$((j+1)) allowBranchName=${allowBranchName}, branchKey=${branchKey}"
                if [ "${allowBranchName}" == ${branchKey} ]; then
                    debug_log "---------------------------------"
                    targetAllowBranchConfig_String=$iAllowBranchConfig_String
                    hasFoundBranchConfig='true'
                    break
                fi
            done

            if [ "${hasFoundBranchConfig}" == 'true' ]; then
                debug_log "恭喜:${PackageNetworkType}环境支持使用${branchKey}分支来打包(附其判断依据为:${targetAllowBranchConfig_String})"
                break
            fi
        fi
    done

    if [ "${hasFoundBranchConfig}" != 'true' ]; then
        return 1
    fi
}

# 遍历获取指定分支使用的渠道（同一个环境不同分支可以上传到不同渠道，不能不设置，如果是要上传到所有渠道则 "branchRegulars" : ["v*"] )
checkAndGetAllowBasis "${PackageNetworkType}" "${ShortBranceName}" "${PlatformType}"
if [ $? != 0 ]; then
    echo "失败:${PackageNetworkType}环境不支持使用${branchKey}分支来打包"
    exit 1
fi
debug_log "恭喜:${PackageNetworkType}环境支持使用${branchKey}分支来打包targetAllowBranchConfig_String=${targetAllowBranchConfig_String}"




    targetBranchConfig_mayString=$(echo "${targetAllowBranchConfig_String}" | ${JQ_EXEC} -r ".branchChannelConfig")
    #echo "targetBranchConfig_mayString=${targetBranchConfig_mayString}"
    debug_log "=================${branchKey}分支的蒲公英匹配参数为targetBranchConfig_mayString=${targetBranchConfig_mayString}"
    if [ -z "${targetBranchConfig_mayString}" ] || [ "${targetBranchConfig_mayString}" == "null" ]; then
        echo "允许打蒲公英${PackageNetworkType}环境的包，未包括${branchKey}分支，故无法找到本包上传蒲公英时候的匹配参数，请检查【${Pgyer_Download_FILE_PATH}】文件中的package_pgyer_params参数"
        return 1
    fi
    

    network_branch_platform_pgyerRootMapString=$(echo "${targetBranchConfig_mayString}" | ${JQ_EXEC} -r --arg platformKey "$platformKey" '.[$platformKey]')
    debug_log "*************************network_branch_platform_pgyerRootMapString=${network_branch_platform_pgyerRootMapString}"
    if [ -z "${network_branch_platform_pgyerRootMapString}" ] || [ "${network_branch_platform_pgyerRootMapString}" == "null" ]; then
        return 1
    fi
        
    # 先获取 upload 和 download 的 channelShortcut 和 channelKey 值
    packagePgyerChannelShortcutResult_upload=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".uploadChannelShortcut")
    debug_log "packagePgyerChannelShortcutResult_upload=${packagePgyerChannelShortcutResult_upload}"
    packagePgyerChannelKeyResult_upload=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".uploadChannelKey")
    debug_log "packagePgyerChannelKeyResult_upload=${packagePgyerChannelKeyResult_upload}"
    packagePgyerChannelShortcutResult_download=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".downloadChannelShortcut")
    debug_log "packagePgyerChannelShortcutResult_download=${packagePgyerChannelShortcutResult_download}"
    packagePgyerChannelKeyResult_download=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".downloadChannelKey")
    debug_log "packagePgyerChannelKeyResult_download=${packagePgyerChannelKeyResult_download}"

    # 再根据上传位置判断 upload 和 download 的值是否缺失
    if [ "$PgyerUploadUrlType" == "toDownUrl" ]; then   # 上传到下载地址
        debug_log "友情提示🤝：想直接上传到下载地址，所以上传地址为最终的下载地址(故也无需检查上传的 channelShortcut 和 channelKey 值)"
        
        if [ "${packagePgyerChannelShortcutResult_download}" == "*" ]; then # 不用到指定渠道
            lastUploadShortcut=""
            lastUploadKey=""
        # elif [ -z "${packagePgyerChannelShortcutResult_download}" ] || [ "${packagePgyerChannelShortcutResult_download}" == "null" ]; then
        #     echo "友情提示🤝:下载地址缺失，所以非指定情况下，下载地址 即为 上传地址"
        #     lastUploadShortcut=""
        #     lastUploadKey=""
        else    # 上传到指定渠道
            if [ -z "${packagePgyerChannelKeyResult_download}" ] || [ "${packagePgyerChannelKeyResult_download}" == "null" ] ||
            [ -z "${packagePgyerChannelShortcutResult_download}" ] || [ "${packagePgyerChannelShortcutResult_download}" == "null" ]; then
                echo "你将直接上传到下载地址，且要上传到指定渠道，所以下载地址的渠道shortCut和key不能不设置。所以请在${Pgyer_Download_FILE_PATH}为${PackageNetworkType}环境的${ShortBranceName}分支创建${PlatformType}平台的渠道信息"
                exit 1
            fi

            lastUploadShortcut=${packagePgyerChannelShortcutResult_download}
            lastUploadKey=${packagePgyerChannelKeyResult_download}
        fi

    elif [ "$PgyerUploadUrlType" == "toUploadUrl" ]; then # 上传到上传地址（可以作为未发布前的临时地址，要发布时候再从蒲公英后台为该渠道添加上去）
        if [ "${packagePgyerChannelShortcutResult_upload}" == "*" ]; then # 不用到指定渠道
            lastUploadShortcut=""
            lastUploadKey=""
        else    # 上传到指定渠道
            if [ -z "${packagePgyerChannelKeyResult_upload}" ] || [ "${packagePgyerChannelKeyResult_upload}" == "null" ] ||
            [ -z "${packagePgyerChannelShortcutResult_upload}" ] || [ "${packagePgyerChannelShortcutResult_upload}" == "null" ]; then
                echo "你将先上传到上传地址，且要上传到指定渠道，所以上传地址的渠道shortCut和key不能不设置。所以请在${Pgyer_Download_FILE_PATH}为${PackageNetworkType}环境的${ShortBranceName}分支创建${PlatformType}平台的渠道信息"
                exit 1
            fi

            lastUploadShortcut=${packagePgyerChannelShortcutResult_upload}
            lastUploadKey=${packagePgyerChannelKeyResult_upload}
        fi
    fi

    if [ -z "${packagePgyerChannelShortcutResult_download}" ] || [ "${packagePgyerChannelShortcutResult_download}" == "null" ]; then
        lastDownloadShortcut=${lastUploadShortcut}
        lastDownloadKey=${lastUploadKey}
    else
        lastDownloadShortcut=${packagePgyerChannelShortcutResult_download}
        lastDownloadKey=${packagePgyerChannelKeyResult_download}
    fi

    # 需事先在蒲公英上建立此渠道短链，否则会提示The channel shortcut URL is invalid
    if [ -n "${lastUploadShortcut}" ]; then
        debug_log "上传目标：只会上传到蒲公英的上的【指定渠道】:${lastUploadShortcut}"
    else
        debug_log "上传目标：会上传到蒲公英的上的【所有渠道】"
    fi
    
    
    

# sh ${CommonFun_HomeDir_Absolute}/update_json_file.sh -f "${Pgyer_Download_FILE_PATH}" -k "package_pgyer_params_current" -v "${network_PgyerRootMapString}"
# if [ $? != 0 ]; then
#     echo "更新 package_pgyer_params_current 属性失败，请检查！"
#     exit 1
# fi
# debug_log "原本依据：${network_PgyerRootMapString}"


network_pgyer_owner=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".owner")
network_pgyer_pgyerKey=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r ".pgyerKey")
debug_log "network_pgyer_owner=${network_pgyer_owner}"
debug_log "network_pgyer_pgyerKey=${network_pgyer_pgyerKey}"

network_platform_pgyer_Map=$(echo "${network_PgyerRootMapString}" | ${JQ_EXEC} -r --arg platformKey "$platformKey" '.[$platformKey]')
network_pgyer_appOfficialWebsite=$(echo "${network_platform_pgyer_Map}" | ${JQ_EXEC} -r ".appOfficialWebsite")
debug_log "network_pgyer_appOfficialWebsite=${network_pgyer_appOfficialWebsite}" # 网址有斜杠，所以使用sed_text.sh中的方法，其已帮处理斜杠问题

# [Mac环境下shell脚本中的map](https://www.jianshu.com/p/a55480b793b0)
download_website="https://www.pgyer.com/${lastDownloadShortcut}"
pgyerArgument='{
    "owner": "'"${network_pgyer_owner}"'",
    "website_official": "'"${network_pgyer_appOfficialWebsite}"'",
    "website_download": "'"${download_website}"'",
    "appKey": "'"${network_pgyer_pgyerKey}"'",
    "uploadChannelShortcut": "'"${lastUploadShortcut}"'",
    "uploadChannelKey": "'"${lastUploadKey}"'",
    "downloadChannelShortcut": "'"${lastDownloadShortcut}"'",
    "downloadChannelKey": "'"${lastDownloadKey}"'"
}'

printf "%s" "${pgyerArgument}"