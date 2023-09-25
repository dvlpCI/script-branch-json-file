#!/bin/bash
#sh all_packing_upload.sh -envInfoF "${Package_Environment_FILE_PATH}" -ipa "${ipa_file_path}"
#sh all_packing_upload.sh -envInfoF "../example_packing_info/app_info.json" -ipa "~/Desktop/dianzan.svg"
:<<!
上传
!
cmdself=$0
echo $cmdself        #  ./keep.sh

#截取字符/后面所有字符
cmdfilename=${cmdself#*/}
echo "cmdfilename=${cmdfilename}"

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"

qscript_path_get_filepath="${bulidScriptCommon_dir_Absolute}/qscript_path_get.sh"
qbase_update_json_file_singleString_script_path="$(sh ${qscript_path_get_filepath} qbase update_json_file_singleString)"
qbase_upload_app_to_pgyer_script_path="$(sh ${qscript_path_get_filepath} qbase upload_app_to_pgyer)"


source ${bulidScriptCommon_dir_Absolute}/a_function.sh ${bulidScriptCommon_dir_Absolute} # 为了使用 updatePackageErrorCodeAndMessage

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# shell 参数具名化
show_usage="args: [-envInfoF, -ipa]\
                                  [--environment-json-file=, --ipa-file-path=]"

while [ -n "$1" ]
do
        case "$1" in
                -envInfoF|--environment-json-file) Package_Environment_FILE_PATH=$2; shift 2;;
                -ipa|--ipa-file-path) ipa_file_path=$2; shift 2;;
                -TransporterUserName|--Transporter-username) Transporter_USERNAME=$2; shift 2;; # 用户账号
                -TransporterPassword|--Transporter-password) Transporter_PASSWORD=$2; shift 2;; # 使用的是秘钥，形如 "djjj-bjkz-rghr-aish"
                -uploadSupplementJsonF|--upload-spplement-json-file) Upload_Supplement_JsonFile=$2; shift 2;;
                -uploadNotificationShowType|--uploadNotification-showType) UploadNotificationShowType=$2; shift 2;; # None \ Pure(只有打包结果) \ Detail(打包分支信息+打包结果)
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

if [ -z "${Transporter_USERNAME}" ] || [ -z "${Transporter_PASSWORD}" ]; then
    printf "用来上传ipa的 Transporter 用户名和密码缺失，请先补充，此次无法自动上传。"
    exit 1
fi


JQ_EXEC=`which jq`

#echo "$0 的入参如下：Package_Environment_FILE_PATH=${Package_Environment_FILE_PATH}"

BRANCH=$(cat $Package_Environment_FILE_PATH | ${JQ_EXEC} .package_from_brance | sed 's/\"//g')
PlatformType=$(cat $Package_Environment_FILE_PATH | ${JQ_EXEC} .platform_type | sed 's/\"//g')
PackageTargetType=$(cat $Package_Environment_FILE_PATH | ${JQ_EXEC} .package_default_target | sed 's/\"//g')
# PackageNetworkType=$(cat $Package_Environment_FILE_PATH | ${JQ_EXEC} .package_default_env | sed 's/\"//g')


PackageResultMap=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r ".package_result")
echo "PackageResultMap=${PackageResultMap}"


if [ ! -f "${Upload_Supplement_JsonFile}" ]; then
    echo "⚠️Warning:上传完成后要补充的信息文件${Upload_Supplement_JsonFile}未填写或不存在，等下将缺失这部分数据。如要使用，请补充此入参"
else
    sh ${qbase_update_json_file_singleString_script_path} -jsonF "${Package_Environment_FILE_PATH}" -k "uploadSupplementJsonFile" -v "${Upload_Supplement_JsonFile}"
fi


# 获取提供给蒲公英的更新说明
function getBranchUpdateMessageForPgyer() {
    # 检查输出文件的路径是否设置且存在
    RESULT_SALE_TO_JSON_FILE_PATH=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r '.branchsResultJsonFile')
    if [ ! -f "${RESULT_SALE_TO_JSON_FILE_PATH}" ]; then
        echo "❌Error: 您的环境文件${Package_Environment_FILE_PATH}中的branchsResultJsonFile键值，没有将之前您存放分支信息的那个文件路径保存起来或者该文件${RESULT_SALE_TO_JSON_FILE_PATH}不存在，请检查是不是取错了！"
        return 1
    fi
    RESULT_ALL_STRING_SALE_BY_KEY="branch_info_result.Pgyer.all.text"
    lastAllChangeLogResult=$(cat ${RESULT_SALE_TO_JSON_FILE_PATH} | ${JQ_EXEC} ".${RESULT_ALL_STRING_SALE_BY_KEY}")
}

function uploadToPgyer() {
    PYGERKEY=$(echo "${PackageResultMap}" | ${JQ_EXEC} -r ".shoudUploadToPgyerKey")
    echo "PYGERKEY=${PYGERKEY}"
    
    getBranchUpdateMessageForPgyer
    pgyerChangeLog=${lastAllChangeLogResult}
#    echo "替换英文分号前pgyerChangeLog=\n${pgyerChangeLog}" # 注意:如果蒲公英更新说明里有分号;，则分号后的文案不能被提交上去
    pgyerChangeLog=`echo "${pgyerChangeLog//;/；}"`
#    echo "替换英文分号后pgyerChangeLog=\n${pgyerChangeLog}" # 注意:如果蒲公英更新说明里有分号;，则分号后的文案不能被提交上去

    PgyerOwner=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r ".package_result.shoudUploadToPgyerOwner")
    
    targetBranchConfig_String=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r ".package_result.pgyer_branch_config")
    echo "=====================${BRANCH}分支的蒲公英上传配置信息targetBranchConfig_String=${targetBranchConfig_String}"
    platformKey=$PlatformType
    #network_branch_platform_pgyerRootMapString=$(echo "${targetBranchConfig_String}" | ${JQ_EXEC} -r --arg platformKey "$platformKey" '.[$platformKey]')
    network_branch_platform_pgyerRootMapString=$(echo "${targetBranchConfig_String}")
    echo "=====================${BRANCH}分支${platformKey}的蒲公英上传配置信息network_branch_platform_pgyerRootMapString=${network_branch_platform_pgyerRootMapString}"
    PgyerChannelShortcut=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".uploadChannelShortcut")
    PgyerChannelKey=$(echo "${network_branch_platform_pgyerRootMapString}" | ${JQ_EXEC} -r ".uploadChannelKey")
    echo "=====================${BRANCH}分支的蒲公英上传位置为PgyerOwner=${PgyerOwner},PgyerChannelShortcut=${PgyerChannelShortcut},PgyerChannelKey=${PgyerChannelKey}"
    
    PgyerChannelWordCount=`echo "${PgyerChannelShortcut}" | awk '{print NF}'`
    echo "PgyerChannel的单词数=${PgyerChannelWordCount}"
    ShouldUploadFast="false"
    if [ "${PgyerChannelShortcut}" != "null" ] && [ -n "${PgyerChannelShortcut}" ] && [ ${PgyerChannelWordCount} -eq 1 ] && [ "${PgyerChannelShortcut}" != "unknow upload pgyer channelShortcut" ] && [ "${PgyerChannelShortcut}" != "upload to all pgyer channelShortcut" ]; then
        sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "正在上传pgyer......(${PgyerOwner})${PgyerChannelShortcut}[${ipa_file_path}]"
        printf "${BLUE}正在执行命令(上传安装包到蒲公英上)：《 ${YELLOW}sh ${qbase_upload_app_to_pgyer_script_path} -f \"${ipa_file_path}\" -k $PYGERKEY --pgyer-channel \"${PgyerChannelShortcut}\" -d \"${pgyerChangeLog}\" --should-upload-fast \"${ShouldUploadFast}\" ${BLUE}》...${NC}\n"
        sh ${qbase_upload_app_to_pgyer_script_path} -f "${ipa_file_path}" -k $PYGERKEY --pgyer-channel "${PgyerChannelShortcut}" -d "${pgyerChangeLog}" --should-upload-fast "${ShouldUploadFast}"
    else
        sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "正在上传pgyer......(${PgyerOwner})[${ipa_file_path}]"
        printf "${BLUE}正在执行命令(上传安装包到蒲公英上)：《 ${YELLOW}sh ${qbase_upload_app_to_pgyer_script_path} -f \"${ipa_file_path}\" -k $PYGERKEY -d \"${pgyerChangeLog}\" --should-upload-fast \"${ShouldUploadFast}\" ${BLUE}》...${NC}\n"
        sh ${qbase_upload_app_to_pgyer_script_path} -f "${ipa_file_path}" -k $PYGERKEY -d "${pgyerChangeLog}" --should-upload-fast "${ShouldUploadFast}"
    fi
    pgyerUploadScriptResultCode=$?
    echo "$PWD $0 111.pgyerUploadScriptResultCode=${pgyerUploadScriptResultCode}"
    if [ ${pgyerUploadScriptResultCode} != 0 ]; then
        echo "$PWD $0 222.pgyerUploadScriptResultCode=${pgyerUploadScriptResultCode}"
        PackageErrorCode=-1
        PackageErrorMessage="上传到蒲公英的脚本执行失败${PYGERKEY}_${PgyerChannelShortcut}.............."
        updatePackageErrorCodeAndMessage ${PackageErrorCode} "${PackageErrorMessage}"
    fi
}


function uploadToCos() {
    sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "正在上传cos......[${ipa_file_path}]"
    echo "正在执行《source ${CurrentDIR_Script_Absolute}/upload_cos.sh \"${ipa_file_path}\"》..."
    source ${CurrentDIR_Script_Absolute}/upload_cos.sh "${ipa_file_path}"
    if [ $? != 0 ]; then
        PackageErrorCode=-1
        PackageErrorMessage="上传到腾讯云cos的脚本执行失败.............."
        updatePackageErrorCodeAndMessage ${PackageErrorCode} "${PackageErrorMessage}"
    fi
    echo "Cos_Network_File_Url=$Cos_Network_File_Url"
    if [ ${#Cos_Network_File_Url} != 0 ]; then
        sh ${qbase_update_json_file_singleString_script_path} -jsonF ${Package_Environment_FILE_PATH} -k 'package_url_result.package_cos_url' -v "${Cos_Network_File_Url}"
        if [ $? != 0 ]; then
            PackageErrorCode=-1
            PackageErrorMessage="更新要上传的cos地址失败.............."
            updatePackageErrorCodeAndMessage ${PackageErrorCode} "${PackageErrorMessage}"
        fi
    fi
}

function uploadToAppStore() {
    sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "正在上传appstore......[${ipa_file_path}]"
#    echo "正在执行《/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/itms/bin/iTMSTransporter -m upload -assetFile \"${ipa_file_path}\" -u '${Transporter_USERNAME}' -p '${Transporter_PASSWORD}'》..."
#    /Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/itms/bin/iTMSTransporter -m upload -assetFile "${ipa_file_path}" -u "${Transporter_USERNAME}" -p "${Transporter_PASSWORD}"
    iTMSTransporter_EXEC=`which iTMSTransporter`
    
    if [ -z "${iTMSTransporter_EXEC}" ]; then
        echo "友情提示⚠️：which iTMSTransporter 执行无结果，将检查 Xcode 中的 iTMSTransporter，若存在，则使用之"
        iTMSTransporter_EXEC_XcodeApp="/Applications/Xcode.app/Contents/SharedFrameworks/ContentDeliveryServices.framework/itms/bin/iTMSTransporter"
        if [ -f "${iTMSTransporter_EXEC_XcodeApp}" ]; then
            iTMSTransporter_EXEC=${iTMSTransporter_EXEC_XcodeApp}
        fi
    fi
    
    if [ -z "${iTMSTransporter_EXEC}" ]; then
        echo "友情提示⚠️：which iTMSTransporter 执行无结果，将检查 TransporterApp 中的 iTMSTransporter，若存在，则使用之"
        iTMSTransporter_EXEC_TransporterApp="/Applications/Transporter.app/Contents/itms/bin/iTMSTransporter"
        if [ -f "${iTMSTransporter_EXEC_TransporterApp}" ]; then
            iTMSTransporter_EXEC=${iTMSTransporter_EXEC_TransporterApp}
        fi
    fi
    
    echo "正在执行上传命令：《${iTMSTransporter_EXEC} -m upload -assetFile \"${ipa_file_path}\" -u '${Transporter_USERNAME}' -p '${Transporter_PASSWORD}' -asc_provider 'U8PA5WCJPR'》..."
    ${iTMSTransporter_EXEC} -m upload -assetFile "${ipa_file_path}" -u "${Transporter_USERNAME}" -p "${Transporter_PASSWORD}" -asc_provider 'U8PA5WCJPR'
    if [ $? != 0 ]; then
        PackageErrorCode=-1
        PackageErrorMessage="上传到AppStore的脚本执行失败..............(请手动将 ${ipa_file_path} 通过 Transporter.app 上传)"
        updatePackageErrorCodeAndMessage ${PackageErrorCode} "${PackageErrorMessage}"
    fi
}

function checkCommon_And_updateAppPackageErrorCodeAndMessage_for_upload() {
    getCommonScriptResultJSONResultCodeAndMessage
    if [ $? != 0 ]; then
        New_PackageErrorCode=${CommonScriptResultJSON_PackageErrorCodeResult}
        sh ${qbase_update_json_file_singleString_script_path} -jsonF ${Package_Environment_FILE_PATH} -k 'package_code' -v "${New_PackageErrorCode}"
    
        New_PackageErrorMessage=${CommonScriptResultJSON_PackageErrorMessageResult}
        sh ${qbase_update_json_file_singleString_script_path} -jsonF ${Package_Environment_FILE_PATH} -k 'package_message' -v "${New_PackageErrorMessage}"
        
#        sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} --log-robottype "error"
#        exit_script
    fi
}



# 获取通知的数据，保存到文件，并读取，分断通知到企业微信(长度超过4096会发送失败，所以需截端)
function getNotificationInterceptAndPostToWeChat_Detail() {
    PackageErrorCode=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r '.package_code') # -r 去除字符串引号
    if [ "${PackageErrorCode}" == "package_code_0" ] ; then
        UploadLogRobotType="result"
    else
        UploadLogRobotType="error"
    fi

    # 获取指定的类型 all.intercept ，后面才能使用
    branchLogType="Notification"
    #echo "正在引入函数文件(用于获取最后的打包通知消息)：《source ${CurrentDIR_Script_Absolute}/upload/upload_result_log.sh》"
    source ${CurrentDIR_Script_Absolute}/upload_result_log.sh
    getUpdateLog_all -envInfoF "${Package_Environment_FILE_PATH}" -comScriptHomeDir "${bulidScriptCommon_dir_Absolute}" --update-log-use-type "${branchLogType}"
    if [ $? != 0 ]; then
        echo "❌Error:执行 getUpdateLog_all 的时候出错"
        return 1
    fi
    # LongLog=${PackageUploadResultText}

    # echo "\n"
    # echo "正在执行命令(发送打包是成功/失败的结果通知)：《sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll \"${LongLog}\" --log-robottype \"${UploadLogRobotType}\"》"
    # sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "${LongLog}" --log-robottype "${UploadLogRobotType}" --enableMarkdown "true"


    # 将结果发送通知
    TEST_DATA_RESULT_FILE_PATH=$(cat ${Package_Environment_FILE_PATH} | jq -r '.branchsResultJsonFile')
    
    AllInterceptArrayKey="branch_info_result.${branchLogType}.all.intercept"
    echo "测试命令《cat ${TEST_DATA_RESULT_FILE_PATH} | jq \".${AllInterceptArrayKey}\" | jq \".|length\"》"
    TEST_ROBOT_CONENT_COUNT=$(cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${AllInterceptArrayKey}" | jq ".|length")
    echo "=============TEST_ROBOT_CONENT_COUNT=${TEST_ROBOT_CONENT_COUNT}"
    if [ ${TEST_ROBOT_CONENT_COUNT} -eq 0 ]; then
        echo "友情提醒💡💡💡：没有找到可发送的测试数据"
        return 1
    fi
    for (( i = 0; i < ${TEST_ROBOT_CONENT_COUNT}; i++ )); do
        echo "输出测试命令($((i+1))/$TEST_ROBOT_CONENT_COUNT)：《cat ${TEST_DATA_RESULT_FILE_PATH} | jq \".${AllInterceptArrayKey}\" | jq \".[${i}]\"》"
        TEST_ROBOT_CONENT=$(cat ${TEST_DATA_RESULT_FILE_PATH} | jq ".${AllInterceptArrayKey}" | jq ".[${i}]")
        # TEST_ROBOT_CONENT="\"我是测试数据\""
        TEST_ROBOT_CONENT=${TEST_ROBOT_CONENT: 1:${#TEST_ROBOT_CONENT}-2}
        
        
        IGNORE_VERSION_HEADER="false"
        if [ $i -gt 0 ]; then
            IGNORE_VERSION_HEADER="true"
        fi

        echo "正在执行命令(发送打包是成功/失败的结果通知)：《sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll \"${TEST_ROBOT_CONENT}\" --log-robottype \"${UploadLogRobotType}\" --ignore-verion-header \"${IGNORE_VERSION_HEADER}\" --enableMarkdown \"true\"》"
        sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "${TEST_ROBOT_CONENT}" --log-robottype "${UploadLogRobotType}" --ignore-verion-header "${IGNORE_VERSION_HEADER}" --enableMarkdown "true"
        if [ $? != 0 ]; then
            echo "❌Error: $FUNCNAME 中发送第($((i+1))/$TEST_ROBOT_CONENT_COUNT)条消息失败"
        else
            echo "✅Success: $FUNCNAME 中发送第($((i+1))/$TEST_ROBOT_CONENT_COUNT)条消息成功"
        fi
        
        if [ $i -eq $((TEST_ROBOT_CONENT_COUNT-1)) ]; then
            echo "发送截断的通知结束"
        fi
    done
}


function sendTesterResultByNotification() {
    PackageErrorCode=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r '.package_code') # -r 去除字符串引号
    # 将结果发送通知
    if [ "${PackageErrorCode}" == "package_code_0" ] ; then
        #ToTesterMessage=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r '.package_notification_argument_current.result_last_message | select(.name==\"${devBranchName}\")') # -r 去除字符串引号
        Result_last_message_Map=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r '.package_notification_argument_current.result_last_message') # -r 去除字符串引号
        ToTesterMessage=$(echo ${Result_last_message_Map} | ${JQ_EXEC} -r --arg PackageTargetType "$PackageTargetType" '.[$PackageTargetType]') # -r 去除字符串引号
        echo "ToTesterMessage=${ToTesterMessage}"
        sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${Package_Environment_FILE_PATH} -ll "${ToTesterMessage}" --log-robottype "result"
    fi
}



PgyerUploadUrlType=$(echo "${PackageResultMap}" | ${JQ_EXEC} -r ".pgyerUploadUrlType")
echo "PgyerUploadUrlType=${PgyerUploadUrlType}"
if [ "${PgyerUploadUrlType}" == "toDownUrl" ] || [ "${PgyerUploadUrlType}" == "toUploadUrl" ] ; then
    uploadToPgyer
else
    printf "${PURPLE} 温馨提示：您的包不会上传到蒲公英。（因为您未对 ${YELLOW}${Package_Environment_FILE_PATH} ${PURPLE}文件配置 ${BLUE}package_result 里的 ${BLUE}pgyerUploadUrlType 值为 toDownUrl/toUploadUrl ${PURPLE}》${NC}\n"
fi

ShoudUploadToCos=$(echo "${PackageResultMap}" | ${JQ_EXEC} -r ".shoudUploadToCos")
echo "ShoudUploadToCos=${ShoudUploadToCos}"
if [ "${ShoudUploadToCos}" == "true" ] ; then
    uploadToCos
else
    printf "${PURPLE} 温馨提示：您的包不会上传到腾讯Cos。（因为您未对 ${YELLOW}${Package_Environment_FILE_PATH} ${PURPLE}文件配置 ${BLUE}package_result 里的 ${BLUE}shoudUploadToCos 值为 true ${PURPLE}》${NC}\n"
fi

ShoudUploadToAppStrore=$(cat ${Package_Environment_FILE_PATH} | ${JQ_EXEC} -r ".package_result.shoudUploadToAppStrore")
echo "ShoudUploadToAppStrore=${ShoudUploadToAppStrore}"
if [ "${ShoudUploadToAppStrore}" == "true" ] && [ "${PlatformType}" == "iOS" ] ; then
    uploadToAppStore
else
    printf "${PURPLE} 温馨提示：您的包不会上传到AppStore。（因为您未对 ${YELLOW}${Package_Environment_FILE_PATH} ${PURPLE}文件配置 ${BLUE}package_result 里的 ${BLUE}shoudUploadToAppStrore 值为 true ${PURPLE}》${NC}\n"
fi
checkCommon_And_updateAppPackageErrorCodeAndMessage_for_upload
sh ${qbase_update_json_file_singleString_script_path} -jsonF ${Package_Environment_FILE_PATH} -k 'packing_state' -v "pack and upload finished"


if [ "${UploadNotificationShowType}" == "Detail" ]; then
    getNotificationInterceptAndPostToWeChat_Detail
    sendTesterResultByNotification
elif [ "${UploadNotificationShowType}" == "Pure" ]; then
    sendTesterResultByNotification
fi

echo "上传脚本执行结束"
