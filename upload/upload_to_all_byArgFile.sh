#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 22:51:13
 # @Description: 上传ipa到各个平台,平台参数来源于文件
### 

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..

qscript_path_get_filepath="${bulidScriptCommon_dir_Absolute}/qscript_path_get.sh"
qbase_update_json_file_singleString_script_path="$(sh ${qscript_path_get_filepath} qbase update_json_file_singleString)"
qbase_upload_app_to_all_script_path="$(sh ${qscript_path_get_filepath} qbase upload_app_to_all)"


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

function debug_log() {
    # 只有直接执行本脚本的时候才能够输出日志，不然如果是形如 echo $(sh xx.sh) 的时候会导致结果值不对
    # is_Directly_execute_this_script=true
    if [ "${is_Directly_execute_this_script}" == true ]; then
        echo "$1"
    fi
}

exit_with_response_error_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    if [ -z "${responseJsonString}" ]; then
        responseJsonString='{
            
        }'
    fi
    uploadFailureTotalMessage=$(printf "%s" "${responseJsonString}" | jq -r '.uploadFailureTotalMessage')
    uploadFailureTotalMessage+=$1

    responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg uploadFailureTotalMessage "$uploadFailureTotalMessage" '. + { "uploadFailureTotalMessage": $uploadFailureTotalMessage }')
    printf "%s" "${responseJsonString}"
    exit 1
}

# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -ipa|--ipa-file-path) ipa_file_path=$2; shift 2;;

        -updateDesString|--updateDesString) updateDesString=$2; shift 2;; # 上传安装包时候附带的说明文案，优先使用此值。
        -updateDesFromFilePath|--updateDesFromFilePath) updateDesFromFilePath=$2; shift 2;; # 说明文案使用来源于哪个文件
        -updateDesFromFileKey|--updateDesFromFileKey) updateDesFromFileKey=$2; shift 2;; # 说明文案使用来源于文件的哪个key

        -uploadArgsFPath|--upload-args-file-path) UploadPlatformArgsFilePath=$2; shift 2;;
        -uploadArgsFKey|--upload-args-file-key) UploadPlatformArgsFileKey=$2; shift 2;;
        -uploadArgsJson|--upload-args-json) UploadPlatformArgsJson=$2; shift 2;;
        -uploadResultFKey|--upload-result-file-key) UploadResult_FILE_Key=$2; shift 2;;

        -LogPostToRobotUrl|--Log-PostTo-RobotUrl) LogPostToRobotUrl=$2; shift 2;; # 上传过程中的日志发送到哪个机器人
        -LogPostTextHeader|--Log-Post-TextHeader) LogPostTextHeader=$2; shift 2;; # 上传过程中对日志进行补充的标题
        --) break ;;
        *) break ;;
    esac
done

JQ_EXEC=$(which jq)



# 所有的配置
if [ -n "${UploadPlatformArgsJson}" ]; then
    PackageResultMap=${UploadPlatformArgsJson}
elif [ -n "${UploadPlatformArgsFilePath}" ] && [ -n "${UploadPlatformArgsFileKey}" ]; then
    PackageResultMap=$(cat ${UploadPlatformArgsFilePath} | ${JQ_EXEC} -r ".${UploadPlatformArgsFileKey}")
fi
debug_log "PackageResultMap=${PackageResultMap}"

# Pgyer的配置
PgyerArgumentMap=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".pgyer")
debug_log "PgyerArgumentMap=${PgyerArgumentMap}"
if [ -n "${PgyerArgumentMap}" ]; then
    # pgyerArgument='{
    #     "owner": "'"${network_pgyer_owner}"'",
    #     "appKey": "'"${network_pgyer_pgyerKey}"'",
    #     "uploadChannelShortcut": "'"${lastUploadShortcut}"'",
    #     "uploadChannelKey": "'"${lastUploadKey}"'",
    #     "downloadChannelShortcut": "'"${lastDownloadShortcut}"'",
    #     "downloadChannelKey": "'"${lastDownloadKey}"'",
    #     "website_official": "'"${network_pgyer_appOfficialWebsite}"'",
    #     "website_download": "'"${download_website}"'",
    # }'
    pgyerOwner=$(printf "%s" "${PgyerArgumentMap}" | ${JQ_EXEC} -r ".owner")
    pgyerApiKey=$(printf "%s" "${PgyerArgumentMap}" | ${JQ_EXEC} -r ".appKey")
    pgyerChannelKey=$(printf "%s" "${PgyerArgumentMap}" | ${JQ_EXEC} -r ".uploadChannelKey")
    pgyerChannelShortcut=$(printf "%s" "${PgyerArgumentMap}" | ${JQ_EXEC} -r ".uploadChannelShortcut")
    pgyerShouldUploadFast="false"
fi

# Cos的配置
CosUploadToREGION=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.region")
CosUploadToBUCKETName=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.bucketName")
CosUploadToBUCKETDir=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.bucketDir")
CosResultHostUrl=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.hostUrl")

# TestFlight的配置
Transporter_USERNAME=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".testFlight.username")
Transporter_PASSWORD=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".testFlight.password")

debug_log "上传参数======== pgyerOwner: ${pgyerOwner}"
debug_log "上传参数======== pgyerApiKey: ${pgyerApiKey}"
debug_log "上传参数======== pgyerChannelKey: ${pgyerChannelKey}"
debug_log "上传参数======== pgyerChannelShortcut: ${pgyerChannelShortcut}"
debug_log "上传参数======== pgyerShouldUploadFast: ${pgyerShouldUploadFast}"

debug_log "上传参数======== CosUploadToREGION: ${CosUploadToREGION}"
debug_log "上传参数======== CosUploadToBUCKETName: ${CosUploadToBUCKETName}"
debug_log "上传参数======== CosUploadToBUCKETDir: ${CosUploadToBUCKETDir}"
debug_log "上传参数======== CosResultHostUrl: ${CosResultHostUrl}"

debug_log "上传参数======== Transporter_USERNAME: ${Transporter_USERNAME}"
debug_log "上传参数======== Transporter_PASSWORD: ${Transporter_PASSWORD}"

# responseJsonString='{
#   "existingKey": "existingValue",
#   "pgyer": {
#     "code": "0",
#     "message": "上传 pgyer 成功",
#     "appNetworkUrl": "https://www.xcxwo.com/app/qrcodeHistory/xxxx"
#   },
#   "cos": {
#     "code": "0",
#     "message": "Success: /Users/qian/Project/CQCI/script-qbase/upload_app/App1Enterprise/App1Enterprise.ipa 文件上传cos成功，路径为https://images.xxx.com/mcms/download/app/App1Enterprise.ipa",
#     "appNetworkUrl": "https://images.xxx.com/mcms/download/app/App1Enterprise.ipa"
#   },
#   "uploadSuccessTypes": "pgyer cos",
#   "uploadFailureTypes": "",
#   "message": "",
#   "log": "温馨提示：您的此iOS包不会上传到AppStore。（因为您设置用来上传ipa的 Transporter 用户名和密码缺失，请先补充，所以此次无法自动上传。附:Transporter_USERNAME= Transporter_PASSWORD= )。"
# }'
debug_log "${YELLOW}正在执行上传命令:《${BLUE} sh ${qbase_upload_app_to_all_script_path} -ipa \"${ipa_file_path}\" -updateDesString \"${updateDesString}\" -updateDesFromFilePath \"${updateDesFromFilePath}\" -updateDesFromFileKey \"${updateDesFromFileKey}\" -pgyerHelpOwner \"${pgyerOwner}\" -pgyerHelpChannelKey \"${pgyerChannelKey}\" -pgyerApiKey \"${pgyerApiKey}\" -pgyerChannelShortcut \"${pgyerChannelShortcut}\" -pgyerShouldUploadFast \"${pgyerShouldUploadFast}\" -CosREGION \"${CosUploadToREGION}\" -CosBUCKETName \"${CosUploadToBUCKETName}\" -CosBUCKETDir \"${CosUploadToBUCKETDir}\" -CosResultHostUrl \"${CosResultHostUrl}\" -TransporterUserName \"${Transporter_USERNAME}\" -TransporterPassword \"${Transporter_PASSWORD}\" -LogPostToRobotUrl \"${LogPostToRobotUrl}\" -LogPostTextHeader \"${LogPostTextHeader}\" ${YELLOW}》${NC}"
responseJsonString=$(sh ${qbase_upload_app_to_all_script_path} -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -pgyerHelpOwner "${pgyerOwner}" -pgyerHelpChannelKey "${pgyerChannelKey}" \
    -pgyerApiKey "${pgyerApiKey}" -pgyerChannelShortcut "${pgyerChannelShortcut}" -pgyerShouldUploadFast "${pgyerShouldUploadFast}" \
    -CosREGION "${CosUploadToREGION}" -CosBUCKETName "${CosUploadToBUCKETName}" -CosBUCKETDir "${CosUploadToBUCKETDir}" -CosResultHostUrl "${CosResultHostUrl}" \
    -TransporterUserName "${Transporter_USERNAME}" -TransporterPassword "${Transporter_PASSWORD}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    exit_with_response_error_message "${responseJsonString}"
fi



uploadSuccessTypesString=$(printf "%s" "${responseJsonString}" | jq -r ".uploadSuccessTypes")
if [ "${uploadSuccessTypesString}" == "null" ]; then
    uploadSuccessTypesString=""
fi
uploadSuccessTypeArray=(${uploadSuccessTypesString})
uploadSuccessCount=${#uploadSuccessTypeArray[@]}
debug_log "${PURPLE} 上传结果成功 ${uploadSuccessCount} 个平台，分别为: ${uploadSuccessTypeArray[*]} ${PURPLE} 。${NC}"
uploadFailureTypesString=$(printf "%s" "${responseJsonString}" | jq -r ".uploadFailureTypes")
if [ "${uploadFailureTypesString}" == "null" ]; then
    uploadFailureTypesString=""
fi
uploadFailureTypeArray=(${uploadFailureTypesString})
uploadFailureCount=${#uploadFailureTypeArray[@]}
debug_log "${PURPLE} 上传结果失败 ${uploadFailureCount} 个平台，分别为: ${uploadFailureTypeArray[*]} ${PURPLE} 。${NC}"


# 将成功的信息写入文件的 ${UploadResult_FILE_Key} 键中
updateAppNetworkUrlToFile_errorMessage=""
for compontentKey in "${uploadSuccessTypeArray[@]}"; do
    compontentAppNetworkUrl=$(printf "%s" "${responseJsonString}" | jq -r ".${compontentKey}.appNetworkUrl")
    debug_log "${GREEN}上传ipa到 ${compontentKey}/${uploadSuccessTypeArray[*]} 成功，地址为 ${compontentAppNetworkUrl} .${NC}"
    sh ${qbase_update_json_file_singleString_script_path} -jsonF ${UploadPlatformArgsFilePath} -k "${UploadResult_FILE_Key}.${compontentKey}.download_url" -v "${compontentAppNetworkUrl}"
    if [ $? != 0 ]; then
        # echo "${RED}执行出错的命令如下:《${BLUE} sh ${qbase_update_json_file_singleString_script_path} -jsonF ${UploadPlatformArgsFilePath} -k \"${UploadResult_FILE_Key}.${compontentKey}.download_url\" -v \"${compontentAppNetworkUrl}\" ${RED}》${NC}"
        updateAppNetworkUrlToFile_errorMessage+="执行更新更新 ${compontentKey} 的地址值 ${compontentAppNetworkUrl} 到文件 ${UploadPlatformArgsFilePath} 失败。"
    fi
done
# 将失败的信息也写入文件的 ${UploadResult_FILE_Key} 键中，而不是上传失败和没有上传都不知道。
for compontentKey in "${uploadFailureTypeArray[@]}"; do
    compontentAppNetworkUrl=$(printf "%s" "${responseJsonString}" | jq -r ".${compontentKey}.appNetworkUrl")
    debug_log "${GREEN}上传ipa到 ${compontentKey}/${uploadSuccessTypeArray[*]} 失败，信息为 ${compontentAppNetworkUrl} .${NC}"
    sh ${qbase_update_json_file_singleString_script_path} -jsonF ${UploadPlatformArgsFilePath} -k "${UploadResult_FILE_Key}.${compontentKey}.download_url" -v "${compontentAppNetworkUrl}"
    if [ $? != 0 ]; then
        # echo "${RED}执行出错的命令如下:《${BLUE} sh ${qbase_update_json_file_singleString_script_path} -jsonF ${UploadPlatformArgsFilePath} -k \"${UploadResult_FILE_Key}.${compontentKey}.download_url\" -v \"${compontentAppNetworkUrl}\" ${RED}》${NC}"
        updateAppNetworkUrlToFile_errorMessage+="执行更新更新 ${compontentKey} 的地址值 ${compontentAppNetworkUrl} 到文件 ${UploadPlatformArgsFilePath} 失败。"
    fi
done
if [ -n "${updateAppNetworkUrlToFile_errorMessage}" ]; then
    exit_with_response_error_message "${updateAppNetworkUrlToFile_errorMessage}"
fi


printf "%s" "${responseJsonString}"
