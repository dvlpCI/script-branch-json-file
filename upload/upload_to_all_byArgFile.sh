#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-27 20:01:21
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

exit_with_message() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    printf "%s" "$1"
    exit 1
}


# shell 参数具名化
show_usage="args: [-envInfoF, -ipa]\
                                  [--environment-json-file=, --ipa-file-path=]"

while [ -n "$1" ]
do
        case "$1" in
                -ipa|--ipa-file-path) ipa_file_path=$2; shift 2;;

                -updateDesString|--updateDesString) updateDesString=$2; shift 2;; # 上传安装包时候附带的说明文案，优先使用此值。
                -updateDesFromFilePath|--updateDesFromFilePath) updateDesFromFilePath=$2; shift 2;; # 说明文案使用来源于哪个文件
                -updateDesFromFileKey|--updateDesFromFileKey) updateDesFromFileKey=$2; shift 2;; # 说明文案使用来源于文件的哪个key

                -uploadArgsFPath|--upload-args-file) UploadPlatformArgsFilePath=$2; shift 2;;
                -uploadArgsFKey|--upload-args-file-key) UploadPlatformArgsFileKey=$2; shift 2;;

                -LogPostToRobotUrl|--Log-PostTo-RobotUrl) LogPostToRobotUrl=$2; shift 2;; # 上传过程中的日志发送到哪个机器人
                -LogPostTextHeader|--Log-Post-TextHeader) LogPostTextHeader=$2; shift 2;; # 上传过程中对日志进行补充的标题
                --) break ;;
                *) break ;;
        esac
done

JQ_EXEC=$(which jq)



# 蒲公英的配置
PackageResultMap=$(cat ${UploadPlatformArgsFilePath} | ${JQ_EXEC} -r ".${UploadPlatformArgsFileKey}")
debug_log "PackageResultMap=${PackageResultMap}"

pgyerOwner=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".shoudUploadToPgyerOwner")
pgyerChannelKey=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".pgyer_branch_config.uploadChannelKey")
pgyerApiKey=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".shoudUploadToPgyerKey")
pgyerChannelShortcut=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".pgyer_branch_config.uploadChannelShortcut")
pgyerShouldUploadFast="false"

# Cos的配置
CosUploadToREGION=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.region")
CosUploadToBUCKETName=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.bucketName")
CosUploadToBUCKETDir=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.bucketDir")
CosResultHostUrl=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".cos.hostUrl")

# TestFlight的配置
Transporter_USERNAME=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".testFlight.username")
Transporter_PASSWORD=$(printf "%s" "${PackageResultMap}" | ${JQ_EXEC} -r ".testFlight.password")

responseJsonString='{
  "existingKey": "existingValue",
  "pgyer": {
    "code": "0",
    "message": "上传成功",
    "appNetworkUrl": "https://www.xcxwo.com/app/qrcodeHistory/xxxx"
  },
  "cos": {
    "code": "0",
    "message": "Success: /Users/qian/Project/CQCI/script-qbase/upload_app/App1Enterprise/App1Enterprise.ipa 文件上传cos成功，路径为https://images.xxx.com//mcms/download/app/App1Enterprise.ipa",
    "appNetworkUrl": "https://images.xxx.com//mcms/download/app/App1Enterprise.ipa"
  },
  "code": "0",
  "message": "",
  "log": "温馨提示：您的此iOS包不会上传到AppStore。（因为您设置用来上传ipa的 Transporter 用户名和密码缺失，请先补充，所以此次无法自动上传。附:Transporter_USERNAME= Transporter_PASSWORD= )。"
}'
# responseJsonString=$(sh ${qbase_upload_app_to_all_script_path} -ipa "${ipa_file_path}" \
#     -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
#     -pgyerHelpOwner "${pgyerOwner}" -pgyerHelpChannelKey "${pgyerChannelKey}" \
#     -pgyerApiKey "${pgyerApiKey}" -pgyerChannelShortcut "${pgyerChannelShortcut}" -pgyerShouldUploadFast "${pgyerShouldUploadFast}" \
#     -CosREGION "${CosUploadToREGION}" -CosBUCKETName "${CosUploadToBUCKETName}" -CosBUCKETDir "${CosUploadToBUCKETDir}" -CosResultHostUrl "${CosResultHostUrl}" \
#     -TransporterUserName "${Transporter_USERNAME}" -TransporterPassword "${Transporter_PASSWORD}" \
#     -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
#     )
if [ $? != 0 ]; then
    exit_with_message "${RED}上传ipa到各个平台失败的结果显示如下:${BLUE} ${responseJsonString} ${BLUE}。${NC}"
fi

uploadResultCode=$(printf "%s" "${responseJsonString}" | jq -r '.code')
if [ "${uploadResultCode}" != "0" ]; then
    uploadResultMessage=$(printf "%s" "${responseJsonString}" | jq -r '.message')
    exit_with_message "${RED}上传ipa到各个平台失败的具体原因显示如下:${BLUE} ${uploadResultMessage} ${BLUE}。${NC}"
fi



# 上传成功后更新地址到
function tryUpdateAppNetworkUrlForCompontentKey() {
    compontentKey=$1
    # 上传成功，并更新地址给文件
    compontentAppNetworkUrl=$(printf "%s" "${responseJsonString}" | jq -r ".${compontentKey}.appNetworkUrl")
    if [ -z "${compontentAppNetworkUrl}" ] || [ "${compontentAppNetworkUrl}" == "null" ]; then
        return 0
    fi
    
    sh ${qbase_update_json_file_singleString_script_path} -jsonF ${UploadPlatformArgsFilePath} -k "package_url_result.package_${compontentKey}_url" -v "${compontentAppNetworkUrl}"
    if [ $? != 0 ]; then
        compontentResultMessage="更新要上传的 ${compontentKey} 地址失败，地址为 ${compontentAppNetworkUrl} 。"
        return 1
    fi
}

tryUpdateAppNetworkUrlForCompontentKey "pgyer"
if [ $? != 0 ]; then
    exit_with_message "${compontentResultMessage}"
fi

tryUpdateAppNetworkUrlForCompontentKey "cos"
if [ $? != 0 ]; then
    exit_with_message "${compontentResultMessage}"
fi

tryUpdateAppNetworkUrlForCompontentKey "testFlight"
if [ $? != 0 ]; then
    exit_with_message "${compontentResultMessage}"
fi

