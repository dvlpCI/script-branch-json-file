#!/bin/bash
###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-02-27 21:38:10
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-29 04:03:49
# @FilePath: upload_result_log.sh
# @Description: 上传结束,获取安装包的各种路径信息
###

# uploadResultLog 的示例
# 本地地址：/User/qian/Project/package/xxx.ipa
# 已备份到本地目录：/User/qian/Project/package/backup/
# cos下载地址：https://www.cos.com/xxxx/yyyy.ipa
# pgyer主页：https://www.pgyer.com/xxxx/yyyy.ipa
# pgyer下载地址：https://www.pgyer.com/xxxx/yyyy.ipa
# "1.后续操作：
# 请确认包是否已自动上传到苹果TestFlight后台，若失败，请下载cos地址手动上传，若成功则。"
# ①请从电脑登录https://appstoreconnect.apple.com，进入'我的app'->XXX应用->顶部'TestFlight'->左侧'构建版本'
# ②操作想要发布的版本
# ③请版本检查更新人员更新最新的版本号、构件号、下载地址三要素
# "2.发布后检查(新版本下载方法也是如此):"
# ①请在iPhone上通过浏览器打开https://testflight.apple.com/join/TRKtWdEe，进入后跳到TestFlight即可看到应用
# ②打开旧版app，查看是否弹出后台指定的新版本更新提示
# ③官网下载也顺便看下 。


JQ_EXEC=$(which jq)

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


function debug_log() {
    if [ "${isRelease}" == true ]; then
        echo "$1"
    fi
}

function getTotalTextFromUploadSupplementArray() {
    uploadSupplementArray=$1

    uploadSupplementTotalText=""
    uploadSupplementCount=$(printf "%s" "${uploadSupplementArray}" | ${JQ_EXEC} ".|length")
    for ((i = 0; i < uploadSupplementCount; i++)); do
        uploadSupplementJson=$(printf "%s" "${uploadSupplementArray}" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        uploadSupplementStepTotalText=$(_getTotalStepTitleAndDesFromUploadSupplementStepJson "${uploadSupplementJson}")
        if [ $i -gt 0 ]; then
            uploadSupplementTotalText+="\n"
        fi
        uploadSupplementTotalText+=${uploadSupplementStepTotalText}
    done
    printf "%s" "${uploadSupplementTotalText}"
}

function _getTotalStepTitleAndDesFromUploadSupplementStepJson() {
    uploadSupplementJson=$1

    uploadSupplementStepTotalText=''

    # 添加 title
    appUploadCheckTitle=$(printf "%s" "${uploadSupplementJson}" | ${JQ_EXEC} ".title")
    uploadSupplementStepTotalText+=${appUploadCheckTitle}

    # 添加 steps
    appUploadCheckSteps=$(printf "%s" "${uploadSupplementJson}" | ${JQ_EXEC} ".step")
    appUploadCheckTotalStepString=$(_getTotalStepDesTextFromUploadSupplementStepArray "${appUploadCheckSteps}")
    uploadSupplementStepTotalText+="\n${appUploadCheckTotalStepString}"

    printf "%s" "${uploadSupplementStepTotalText}"
}

function _getTotalStepDesTextFromUploadSupplementStepArray() {
    appUploadCheckSteps=$1

    appUploadCheckTotalStepString=""
    appUploadCheckStepCount=$(printf "%s" "${appUploadCheckSteps}" | ${JQ_EXEC} ".|length")
    for ((j = 0; j < appUploadCheckStepCount; j++)); do
        appUploadCheckStepString=$(printf "%s" "${appUploadCheckSteps}" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
        if [ $j -gt 0 ]; then
            appUploadCheckTotalStepString+="\n"
        fi
        appUploadCheckTotalStepString+="${appUploadCheckStepString}"
    done

    printf "%s" "${appUploadCheckTotalStepString}"
}

function addText_for_PackageUploadHeaderTextResult() {
    if [ -n "${PackageUploadHeaderTextResult}" ]; then
        PackageUploadHeaderTextResult+="\n"
    fi
    PackageUploadHeaderTextResult+="$1"
}


# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        -uploadResultFPath|--pload-result-file-path) UploadResult_FILE_PATH=$2 shift 2;;
        -uploadResultFKey|--upload-result-file-key) UploadResult_FILE_Key=$2; shift 2;;
        --) break ;;
        *) break ;;
        esac
done


if [ ! -f "${UploadResult_FILE_PATH}" ]; then
    printf "%s" "${RED}❌Error:您填写【保存打包信息文件】的文件 ${UploadResult_FILE_PATH} 未设置或不存在，请检查。${NC}\n"
    exit 1
fi


Package_Url_Result=$(cat ${UploadResult_FILE_PATH} | ${JQ_EXEC} ".${UploadResult_FILE_Key}") # 不能去除引号，不能下面取值会出错
if [ "${isRelease}" == true ]; then
    echo "获取到之前已计算得到的安装包各种路径信息 ${BLUE}.${UploadResult_FILE_Key} ${NC}的值(在文件 ${BLUE}${UploadResult_FILE_PATH} ${NC}中)如下:"
    cat ${UploadResult_FILE_PATH} | ${JQ_EXEC} ".${UploadResult_FILE_Key}"
fi

Package_Local_File_Url=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} '.local.origin_url' | sed 's/\"//g') # 去除引号
Package_Local_Backup_Dir=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} '.local.backup_dir' | sed 's/\"//g') # 去除引号
Package_Network_File_Url=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} '.cos.download_url' | sed 's/\"//g')
Pgyer_Official_Url=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} '.pgyer.official_url' | sed 's/\"//g')
Pgyer_Download_Url=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} '.pgyer.download_url' | sed 's/\"//g')


# echo "Package_Local_File_Url=${Package_Network_File_Url}"
# echo "Package_Local_Backup_Dir=${Package_Local_Backup_Dir}"
# echo "Package_Network_File_Url=${Package_Network_File_Url}"

if [ -n "${Package_Local_File_Url}" ] && [ "${Package_Local_File_Url}" != "package local url" ]; then
    PackageDirOrFilePathResult_text="本地地址：${Package_Local_File_Url}"
    PackageDirOrFilePathResult_markdown="本地地址：[${Package_Local_File_Url}](${Package_Local_File_Url})"
fi

if [ -n "${Package_Local_Backup_Dir}" ] && [ "${Package_Local_Backup_Dir}" != "package local backup dir" ]; then
    PackageDirOrFilePathResult_text+="\n已备份到本地目录：${Package_Local_Backup_Dir}"
    PackageDirOrFilePathResult_markdown+="\n已备份到本地目录：[${Package_Local_Backup_Dir}](${Package_Local_Backup_Dir})"
fi

if [ -n "${Package_Network_File_Url}" ] && [ "${Package_Network_File_Url}" != "package cos url" ]; then
    PackageDirOrFilePathResult_text+="\ncos下载地址：${Package_Network_File_Url}"
    PackageDirOrFilePathResult_markdown+="\ncos下载地址：[${Package_Network_File_Url}](${Package_Network_File_Url})"
fi

if [ -n "${Pgyer_Official_Url}" ] && [ "${Pgyer_Official_Url}" != "package cos url" ]; then
    PackageDirOrFilePathResult_text+="\npgyer主页：${Pgyer_Official_Url}"
    PackageDirOrFilePathResult_markdown+="\npgyer主页：[${Pgyer_Official_Url}](${Pgyer_Official_Url})"
fi

if [ -n "${Pgyer_Download_Url}" ] && [ "${Pgyer_Download_Url}" != "package cos url" ]; then
    PackageDirOrFilePathResult_text+="\npgyer下载地址：${Pgyer_Download_Url}"
    PackageDirOrFilePathResult_markdown+="\npgyer下载地址：[${Pgyer_Download_Url}](${Pgyer_Download_Url})"
fi

uploadSupplementArray=$(printf "%s" "${Package_Url_Result}" | ${JQ_EXEC} ".testFlight.uploadSupplement")
uploadSupplementTotalText=$(getTotalTextFromUploadSupplementArray "${uploadSupplementArray}")
if [ -n "${uploadSupplementTotalText}" ]; then
    PackageDirOrFilePathResult_text+="\n${uploadSupplementTotalText}"
    PackageDirOrFilePathResult_markdown+="\n${uploadSupplementTotalText}"
fi
# ③官网路径(用于上传失败的时候，提示可去下载之前的包)
# ④打包成功后的，后续其他操作提示文案
printf "%s" "${PackageDirOrFilePathResult_text}"


