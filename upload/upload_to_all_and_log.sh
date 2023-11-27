#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-08-03 11:44:37
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 21:49:30
 # @Description: 上传ipa到各个平台,平台参数来源于文件。并在上传结束,获取安装包的各种路径信息
### 

# 本地地址：/Users/linzehual.jenkins/workspace/wish_android_生产_蒲公英/wish/build/app/outputs/apk/release/
# Android_product_dev_dev_publish_in_1.18.01(18012051).apk
# 己已备份到本地目录：/sers/linzehual.jenkins/workspace/alLipa_output/product/dev/
# release_dev_publish_in_Android1.18.01(18012051)
# 官网：https://www.pgyer.com/bjprowishA(实际：https://www.pgyer.com/bjwishproAdown）
# 只是打包2

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
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
# CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
# CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
CategoryFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute}
# echo "CategoryFun_HomeDir_Absolute=${CategoryFun_HomeDir_Absolute}"

qtool_upload_result_log_scriptPath=${CategoryFun_HomeDir_Absolute}/upload_result_log.sh
qtool_upload_to_all_byArgFile_scriptPath=${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

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
        -uploadResultFPath|--upload-result-file-path) UploadResult_FILE_PATH=$2 shift 2;;
        -uploadResultFKey|--upload-result-file-key) UploadResult_FILE_Key=$2; shift 2;;

        -LogPostToRobotUrl|--Log-PostTo-RobotUrl) LogPostToRobotUrl=$2; shift 2;; # 上传过程中的日志发送到哪个机器人
        -LogPostTextHeader|--Log-Post-TextHeader) LogPostTextHeader=$2; shift 2;; # 上传过程中对日志进行补充的标题
        --) break ;;
        *) break ;;
    esac
done



# 1.进行上传
responseJsonString=$(sh ${qtool_upload_to_all_byArgFile_scriptPath} -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -uploadArgsFPath "${UploadPlatformArgsFilePath}" -uploadArgsFKey "${UploadPlatformArgsFileKey}" -uploadArgsJson "${UploadPlatformArgsJson}" -uploadResultFPath "${UploadResult_FILE_PATH}" -uploadResultFKey "${UploadResult_FILE_Key}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    echo "${RED}Error❌:上传ipa到各个平台,平台参数来源于文件的结果错误信息如下:\n${BLUE} ${responseJsonString} ${RED}。${NC}"
    # echo "${RED}执行错误的命令如下:《${BLUE} sh ${qtool_upload_to_all_byArgFile_scriptPath} -ipa \"${ipa_file_path}\" -updateDesString \"${updateDesString}\" -updateDesFromFilePath \"${updateDesFromFilePath}\" -updateDesFromFileKey \"${updateDesFromFileKey}\" -uploadArgsFPath \"${UploadPlatformArgsFilePath}\" -uploadArgsFKey \"${UploadPlatformArgsFileKey}\" -uploadResultFKey \"${UploadResult_FILE_Key}\" -LogPostToRobotUrl \"${LogPostToRobotUrl}\" -LogPostTextHeader \"${LogPostTextHeader}\" ${RED}》${NC}"
    exit 1
fi
# echo "${GREEN}上传ipa到各个平台成功。信息如下：\n${BLUE} $(cat "${UploadPlatformArgsFilePath}" | jq '.package_url_result') ${GREEN}。\n更多详情请查看: ${UploadPlatformArgsFilePath} ${NC}"


# 2.上传完成后，将各种路径信息日志返回给log
uploadResultLog=$(sh ${qtool_upload_result_log_scriptPath} -uploadResultFPath "${UploadResult_FILE_PATH}" -uploadResultFKey "${UploadResult_FILE_Key}")
if [ $? != 0 ]; then
    echo "${RED}Error❌:上传ipa到各个平台,上传完成后，将各种路径信息日志返回给log的错误信息如下:\n${BLUE} ${uploadResultLog} ${RED}。${NC}"
    exit 1
fi
# echo "${GREEN}上传结束后安装包的各种路径信息：${BLUE}\n${uploadResultLog} ${GREEN}。\n更多详情请查看: ${UploadResult_FILE_PATH} ${NC}"

responseJsonString=$(printf "%s" "$responseJsonString" | jq --arg uploadResultLog "$uploadResultLog" '. + { "uploadResultLog": $uploadResultLog }')
printf "%s" "${responseJsonString}"

