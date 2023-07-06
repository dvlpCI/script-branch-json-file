#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-07-03 21:28:47
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-06 11:12:08
 # @Description: 
### 
#sh env_update_for_choosingEnvFile.sh -appEnvF "${AppEnvFilePath}" -p "${PlatformType}" -b "${BRANCH}" -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -d "${ChangeLog}" -v $VERSION -bd $BUILD
#sh env_update_for_choosingEnvFile.sh -appEnvF "app_info.json" -p iOS -b dev_all -pt pgyer -pn preproduct -d "更新说明略\n分支信息:\ndev_fix:功能修复" -v 1.0.0 -bd 11041000


# echo "===============进入脚本:$0"


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
bulidScriptApp_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
bulidScriptHome_dir_Absolute=${bulidScriptApp_dir_Absolute%/*}
bulidScriptCommon_dir_Absolute=${bulidScriptHome_dir_Absolute}/buildScriptSource/bulidScriptCommon
#echo "bulidScriptCommon_dir_Absolute=${bulidScriptCommon_dir_Absolute}"

# 包来源分支
# shell 参数具名化
show_usage="args: [-appEnvF, -p , -b , -pt , -pn , -d, -v , -bd , -supPgyer, -supCos, -supAppStore, -np]\
                                  [--app-env-json-file=, --platformType=, --feature-branch=, --package_target_type=, --package_network_type=,\
                                  --update-description=, --version=, --build=,\
                                  --notificate-forPeople=]"

while [ -n "$1" ]
do
        case "$1" in
                -appEnvDir|--app-env-file-dir-path) AppEnvFile_DirPath=$2; shift 2;; # App环境文件的所在目录
                -pn|--package_network_type) PackageNetworkType=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

JQ_EXEC=`which jq`

if [ ! -d "${AppEnvFile_DirPath}" ];then
    echo "❌:您的 AppEnvFile_DirPath=${AppEnvFile_DirPath} 文件目录不存在，请检查！"
    exit_script
fi


if [ "${PackageNetworkType}" == "开发环境1" ]; then
    echo "这个是【开发1】包"
    PackageNetworkType='develop1'
elif [ "${PackageNetworkType}" == "开发环境2" ]; then
    echo "这个是【开发2】包"
    PackageNetworkType='develop2'
elif [ "${PackageNetworkType}" == "测试环境1" ]; then
    echo "这个是【测试1】包"
    PackageNetworkType='test1'
elif [ "${PackageNetworkType}" == "测试环境2" ]; then
    echo "这个是【测试2】包"
    PackageNetworkType='test2'
elif [ "${PackageNetworkType}" == "预生产环境" ]; then
    echo "这个是【预生产】包"
    PackageNetworkType='preproduct'
elif [ "${PackageNetworkType}" == "生产环境" ]; then
    echo "这个是【生产】包"
    PackageNetworkType='product'
else
    printf "${RED}发生错误，${YELLOW}$0 ${RED}脚本中未处理输入源为 ${YELLOW}${PackageNetworkType}${RED} 时候，应该映射到的【网络环境】，请先调整你的输入源！${NC}\n"
    exit_script
fi
AppEnvFilePath="${AppEnvFile_DirPath}/$PackageNetworkType.json"



sh ${bulidScriptCommon_dir_Absolute}/json_check/json_file_check.sh -checkedJsonF "${AppEnvFilePath}"


# 版本号version+build/VersionCode
# 更改app信息，并返回 VERSION 和 BUILD
#VERSION="1."$(date "+%m.%d") # 1.02.21
#BUILD=$(date "+%m%d%H%M") # 02211506
cur_date_month=$(date "+%m")
cur_date_month=$((cur_date_month+12)) # 隔年了
cur_date_day=$(date "+%d")
cur_date_hour=$(date "+%H")
cur_date_minute=$(date "+%M")
#VERSION="1.${cur_date_month}.${cur_date_day}"   # 1.02.21
BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506
if [ -n "$BUILD" ]; then
    # sed -i '' "s/package unknow buildNumber/${BUILD}/g" ${AppEnvFilePath}
    sh ${bulidScriptCommon_dir_Absolute}/update_json_file_singleString.sh -jsonF ${AppEnvFilePath} -k 'BUILD_NUMBER' -v "${BUILD}"
fi
