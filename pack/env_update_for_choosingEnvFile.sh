#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-07-03 21:28:47
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-06 11:12:08
 # @Description: 
### 
#sh env_update_for_choosingEnvFile.sh -appEnvDir "${AppEnvFile_DirPath}" -pn "${PackageNetworkType}"
#sh env_update_for_choosingEnvFile.sh -appEnvDir "~/Project/CQCI/script-branch-json-file/test" -pn 生产环境


# echo "===============进入脚本:$0"

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#currentScriptHome_dir_Absolute=${CurrentDIR_Script_Absolute}/..
currentScriptHome_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qscript_path_get_filepath="${currentScriptHome_dir_Absolute}/qscript_path_get.sh"
qbase_update_json_file_singleString_script_path="$(sh ${qscript_path_get_filepath} qbase update_json_file_singleString)"
qbase_json_file_check_script_path="$(sh ${qscript_path_get_filepath} qbase json_file_check)"



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

if [[ $AppEnvFile_DirPath =~ ^~.* ]]; then
    # 如果 $AppEnvFile_DirPath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    AppEnvFile_DirPath="${HOME}${AppEnvFile_DirPath:1}"
fi
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



sh ${qbase_json_file_check_script_path} -checkedJsonF "${AppEnvFilePath}"

# 版本号version+build/VersionCode
# 更改app信息，并返回 VERSION 和 BUILD
#VERSION="1."$(date "+%m.%d") # 1.02.21
#BUILD=$(date "+%m%d%H%M") # 02211506
cur_date_month_haszero=$(date "+%m")
# 在Bash shell中，以0开头的数字表示一个八进制数。例如，08被解释为一个八进制数字，但是八进制数字中只允许出现0~7，因此会提示错误。
# 为了解决这个问题，你可以将date命令的输出的月份信息转换为十进制数，而不是八进制数。你可以通过在%m选项前添加%-来实现
cur_date_month_nozero=$(date "+%-m")
cur_date_month=$((cur_date_month_nozero+12))    # 隔年了
cur_date_day=$(date "+%d")
cur_date_hour=$(date "+%H")
cur_date_minute=$(date "+%M")
#VERSION="1.${cur_date_month}.${cur_date_day}"   # 1.02.21
BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506
if [ -n "$BUILD" ]; then
    # sed -i '' "s/package unknow buildNumber/${BUILD}/g" ${AppEnvFilePath}
    sh ${qbase_update_json_file_singleString_script_path} -jsonF ${AppEnvFilePath} -k 'BUILD_NUMBER' -v "${BUILD}"
    open "${AppEnvFilePath}"
fi
