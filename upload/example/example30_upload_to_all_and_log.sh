#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-16 16:06:35
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 21:42:18
 # @Description: 测试上传ipa到各个平台,平台参数来源于文件。并在上传结束,获取安装包的各种路径信息
### 


# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
Example_HomeDir_Absolute=${CurrentDIR_Script_Absolute}      
CategoryFun_HomeDir_Absolute=${Example_HomeDir_Absolute%/*} # 使用 %/* 方法可以避免路径上有..
qtool_homedir_abspath=${CategoryFun_HomeDir_Absolute%/*}    # 使用 %/* 方法可以避免路径上有..

qbase_update_json_file_singleString_script_path="$(sh ${qscript_path_get_filepath} qbase update_json_file_singleString)"
qtool_getUploadArg_pgyer_scriptPath=$qtool_homedir_abspath/upload_arg_get/getUploadArg_pgyer.sh

function log_title() {
    echo "${PURPLE}------------------ $1 ------------------${NC}"
}
function error_exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    echo "${RED}❌Error:发生错误了${NC}"
    exit 1
}

PlatformType="iOS"
PackageTargetType="formal"
PackageNetworkType="product"
CurrentBranchName="${BRANCH}"

PgyerUploadUrlType="toUploadUrl"
ShouldBackupToCos="true"
ShouldUploadToAppStore="false"

function getUploadArg_Pgyer_Cos_AppStore() {
    echo "PgyerUploadUrlType=${PgyerUploadUrlType}"
    if [ "${PgyerUploadUrlType}" == "直接上传到最终地址" ]; then
        PgyerUploadUrlType="toDownUrl"
    elif [ "${PgyerUploadUrlType}" == "先上传到临时地址，通过后再添加到最终地址" ]; then
        PgyerUploadUrlType="toUploadUrl"
    elif [ "${PgyerUploadUrlType}" == "不上传" ]; then
        PgyerUploadUrlType="toNoneUrl"
    else
        printf "%s" "${RED}PgyerUploadUrlType=${YELLOW}${PgyerUploadUrlType}${RED} 不正确，请检查${NC}\n"
        exit 1
    fi

    pygerArgument='{}'
    if [ "${PgyerUploadUrlType}" != "toNoneUrl" ]; then
        # "测试蒲公英上传参数"
        Pgyer_Argument_FILE_PATH="${qtool_homedir_abspath}/upload_arg_get/example/example_getUploadArg_pgyer.json"
        Pgyer_Argument_FILE_KEY=""
        echo "正在执行命令:（获取蒲公英参数):《 sh ${qtool_getUploadArg_pgyer_scriptPath} -pgyerJsonsFPath \"${Pgyer_Argument_FILE_PATH}\" -pgyerJsonsFKey \"${Pgyer_Argument_FILE_KEY}\" -pgyerUploadUrlType \"${PgyerUploadUrlType}\" -pl \"${PlatformType}\" -pn \"${PackageNetworkType}\" -curBranchName \"${CurrentBranchName}\" 》"
        pygerArgument=$(sh ${qtool_getUploadArg_pgyer_scriptPath} -pgyerJsonsFPath "${Pgyer_Argument_FILE_PATH}" -pgyerJsonsFKey "${Pgyer_Argument_FILE_KEY}" -pgyerUploadUrlType "${PgyerUploadUrlType}" -pl "${PlatformType}" -pn "${PackageNetworkType}" -curBranchName "${CurrentBranchName}")
        if [ $? != 0 ]; then
            echo "${pygerArgument}"
            exit 1
        fi
        # pgyerArgument='{
        #     "owner": "'"${network_pgyer_owner}"'",
        #     "website_official": "'"${network_pgyer_appOfficialWebsite}"'",
        #     "website_download": "'"${download_website}"'",
        #     "appKey": "'"${network_pgyer_pgyerKey}"'",
        #     "uploadChannelShortcut": "'"${lastUploadShortcut}"'",
        #     "uploadChannelKey": "'"${lastUploadKey}"'",
        #     "downloadChannelShortcut": "'"${lastDownloadShortcut}"'",
        #     "downloadChannelKey": "'"${lastDownloadKey}"'"
        # }'
    fi
    
    cosArgument='{}'
    if [ "${ShouldBackupToCos}" == "true" ]; then
        cosArgument='{
            "region": "ap-shanghai",
            "bucketName": "prod-xhw-image-1302324914",
            "bucketDir": "/mcms/download/app/",
            "hostUrl": "https://images.xihuanwu.com"
        }'
    fi

    testFlightArgument='{}'
    if [ "${ShouldUploadToAppStore}" == "true" ]; then
        home_appOfficialWebsite="http://h5.xxx.com/pages-h5/share/download-app"
        if [ "${PlatformType}" == "iOS" ]; then
            real_downloadUrl="https://testflight.apple.com/join/TRKtWdEe"
        else
            real_downloadUrl=""
        fi

        testFlightArgument='{
            "username": "app1@company.com",
            "password": "app1@companyPasd",
            "website_official": "'"${home_appOfficialWebsite}"'",
            "website_download":  "'"${real_downloadUrl}"'"
        }'
    fi

    UploadPlatformArgsJson='{
        "pgyer": '${pygerArgument}',
        "cos": '${cosArgument}',
        "testFlight": '${testFlightArgument}'
    }
    '
    echo "上传使用的所有参数如下:"
    # echo "UploadPlatformArgsJson==========${UploadPlatformArgsJson}"
    printf "%s" "${UploadPlatformArgsJson}" | jq "."
}

getUploadArg_Pgyer_Cos_AppStore


appVersionAndBuildNumberJson=$(qbase -quick getAppVersionAndBuildNumber)
packageVersion=$(echo ${appVersionAndBuildNumberJson} | jq -r ".version")
packageBuildNumber=$(echo ${appVersionAndBuildNumberJson} | jq -r ".buildNumber")

#更新安装包的中英文信息,方便后面直接取值
function getPackageDes() {
    # 1、版本的英文信息 package_des.english
    PackageDesEnglish="[${CurrentBranchName}]${PackageTargetType}_${PackageNetworkType}_${PlatformType}V${packageVersion}(${packageBuildNumber})"
    echo "==============PackageDesEnglish=${PackageDesEnglish}"

    # 2、版本的中文信息 package_des.chinese
    if [ "${PgyerUploadUrlType}" == "toDownUrl" ]; then
        PackagePgyerPublishStateDes="会直接发布的"
    elif [ "${PgyerUploadUrlType}" == "toUploadUrl" ]; then
        PackagePgyerPublishStateDes="待发布的"
    elif [ "${PgyerUploadUrlType}" == "toNoneUrl" ]; then
        PackagePgyerPublishStateDes="不会发布的"
    else
        PackagePgyerPublishStateDes=""
    fi

    if [ "${PackageNetworkType}" == "develop1" ] || [ "${PackageNetworkType}" == "develop2" ]; then
        PackageTargetNetworkDes='开发包'
    elif [ "${PackageNetworkType}" == "test1" ] || [ "${PackageNetworkType}" == "test2" ]; then
        PackageTargetNetworkDes='测试包'
    elif [ "${PackageNetworkType}" == "preproduct" ] ; then
        PackageTargetNetworkDes='预生产包'
    elif [ "${PackageNetworkType}" == "product" ] ; then
        PackageTargetNetworkDes="生产包"
    else
        PackageTargetNetworkDes="${PackageNetworkType}包"
    fi
    #echo "PackageTargetNetworkDes=${PackageTargetNetworkDes}"
    PackageDesChinese="${PackagePgyerPublishStateDes}${PlatformType}${PackageTargetNetworkDes}"
    echo "==============PackageDesChinese=${PackageDesChinese}"

    # sh ${qbase_update_json_file_singleString_script_path} -jsonF ${FILE_PATH} -k 'package_des.english' -v "${PackageDesEnglish}"
    # sh ${qbase_update_json_file_singleString_script_path} -jsonF ${FILE_PATH} -k 'package_des.chinese' -v "${PackageDesChinese}"
}
getPackageDes

# 示例
log_title "上传ipa到各个平台,平台参数来源于文件"
# ipa_file_path="${Example_HomeDir_Absolute}/App1Enterprise/App1Enterprise.ipa"
ipa_file_path="~/Project/CQCI/script-qbase/upload_app/App1Enterprise/App1Enterprise.ipa"
if [[ $ipa_file_path =~ ^~.* ]]; then
    # 如果 $ipa_file_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    ipa_file_path="${HOME}${ipa_file_path:1}"
fi
TEST_JSON_FILE="${Example_HomeDir_Absolute}/example30_upload_to_all_and_log.json"

# updateDesString="测试蒲公英上传到指定位置，请勿下载"
updateDesFromFilePath=${TEST_JSON_FILE}
updateDesFromFileKey="package_des.chinese"

# UploadPlatformArgsFilePath=${TEST_JSON_FILE}
# UploadPlatformArgsFileKey="package_platform_arg"
UploadResult_FILE_PATH=${TEST_JSON_FILE}
UploadResult_FILE_Key="upload_result"


# 日志机器人的配置
LogPostToRobotUrl="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=925776da-1ff4-417a-922a-d5ced384050e"
LogPostTextHeader="这是上传过程中对日志进行补充的标题"
# sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_byArgFile.sh -ipa "${ipa_file_path}" \
#     -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
#     -uploadArgsFPath "${UploadPlatformArgsFilePath}" -uploadArgsFKey "${UploadPlatformArgsFileKey}" -uploadArgsJson "${UploadPlatformArgsJson}" \
#     -uploadResultFPath "${UploadResult_FILE_PATH}" -uploadResultFKey "${UploadResult_FILE_Key}" \
#     -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}"
#     exit
responseJsonString=$(sh ${CategoryFun_HomeDir_Absolute}/upload_to_all_and_log.sh -ipa "${ipa_file_path}" \
    -updateDesString "${updateDesString}" -updateDesFromFilePath "${updateDesFromFilePath}" -updateDesFromFileKey "${updateDesFromFileKey}" \
    -uploadArgsFPath "${UploadPlatformArgsFilePath}" -uploadArgsFKey "${UploadPlatformArgsFileKey}" -uploadArgsJson "${UploadPlatformArgsJson}" \
    -uploadResultFPath "${UploadResult_FILE_PATH}" -uploadResultFKey "${UploadResult_FILE_Key}" \
    -LogPostToRobotUrl "${LogPostToRobotUrl}" -LogPostTextHeader "${LogPostTextHeader}" \
    )
if [ $? != 0 ]; then
    echo "${responseJsonString}" # 此时值为错误信息
    exit 1
fi
echo "${GREEN}上传ipa到各个平台的脚本执行成功，json结果如下:${NC}"
printf "%s" "${responseJsonString}" | jq "."

echo ""
uploadResultLog=$(printf "%s" "${responseJsonString}" | jq -r ".uploadResultLog")
echo "${GREEN}上传结束后安装包的各种路径信息整理成字符串如下：${NC}"
printf "%s" "${uploadResultLog}"

echo ""
echo "${GREEN}更多详情请查看: ${UploadPlatformArgsFilePath} ${NC}"



