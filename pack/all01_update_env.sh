#!/bin/bash
:<<!
更新项目的①code环境；②json环境

updateJsonEnv_scriptFile_Absolute="/Users/qian/Project/AppProject/appdemo/bulidScriptCommon/app_info_out_update"
updateIOSCodeEnv_scriptFile_Absolute="/Users/qian/Project/AppProject/appdemo/buildScriptSource/bulidScript/update_app_info_ios.sh"
updateAndroidCodeEnv_scriptFile_Absolute="/Users/qian/Project/AppProject/appdemo/buildScriptSource/bulidScript/update_app_info_android.sh"
PlatformType="Android"
PackageTargetType="生成最后只发布到蒲公英的包"
PackageNetworkType="测试"
APPEVN_SAVE_TO_FILE="/Users/qian/Project/AppProject/appdemo/bulidScript/app_info.json"
echo "正在执行《sh all01_update_env.sh -updateJsonEnvScriptFile \"${updateJsonEnv_scriptFile_Absolute}\" -updateIOSCodeEnvScriptFile \"${updateIOSCodeEnv_scriptFile_Absolute}\" -updateAndroidCodeEnvScriptFile \"${updateAndroidCodeEnv_scriptFile_Absolute}\" -pl ${PlatformType} -pt $PackageTargetType -pn $PackageNetworkType -saveToF \"${APPEVN_SAVE_TO_FILE}\" 》"
sh all01_update_env.sh -updateJsonEnvScriptFile "${updateJsonEnv_scriptFile_Absolute}" -updateIOSCodeEnvScriptFile "${updateIOSCodeEnv_scriptFile_Absolute}" -updateAndroidCodeEnvScriptFile "${updateAndroidCodeEnv_scriptFile_Absolute}" -pl ${PlatformType} -pt $PackageTargetType -pn $PackageNetworkType -saveToF "${APPEVN_SAVE_TO_FILE}"
exit
!


# shell 参数具名化
show_usage="args: [-updateJsonEnvScriptFile, -updateIOSCodeEnvScriptFile, -updateAndroidCodeEnvScriptFile, -pl , -pt , -pn, -saveToF]\
                                  [--updateJsonEnv_scriptFile_Absolute=, --updateIOSCodeEnv_scriptFile_Absolute=, --updateAndroidCodeEnv_scriptFile_Absolute=, --platformType=, --package_target_type=, --package_network_type=, --save_to_file=]"

while [ -n "$1" ]
do
        case "$1" in
                -updateJsonEnvScriptFile|--updateJsonEnv_scriptFile_Absolute) updateJsonEnv_scriptFile_Absolute=$2; shift 2;;
                -updateIOSCodeEnvScriptFile|--updateIOSCodeEnv_scriptFile_Absolute) updateIOSCodeEnv_scriptFile_Absolute=$2; shift 2;;
                -updateAndroidCodeEnvScriptFile|--updateAndroidCodeEnv_scriptFile_Absolute) updateAndroidCodeEnv_scriptFile_Absolute=$2; shift 2;;
                -b|--feature-branch) BRANCH=$2; shift 2;;
                -pl|--platformType) PlatformType=$2; shift 2;;
                -pt|--package_target_type) PackageTargetType=$2; shift 2;;
                -pn|--package_network_type) PackageNetworkType=$2; shift 2;;
                -saveToF|--save_to_file) APPEVN_SAVE_TO_FILE=$2; shift 2;;
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

echo "APPEVN_SAVE_TO_FILE=$APPEVN_SAVE_TO_FILE"
echo "PlatformType=$PlatformType"
echo "PackageTargetType=$PackageTargetType"
echo "PackageNetworkType=$PackageNetworkType"


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
    printf "${RED}发生错误，脚本中未处理输入源为 ${YELLOW}${PackageNetworkType}${RED} 时候，应该映射到的【网络环境】，请先调整你的输入源！${NC}\n"
    exit_script
fi

#ShortBranceName=${BRANCH##*/}
#echo "ShortBranceName=$ShortBranceName"
#if [ "${ShortBranceName}" == "master" -o "${ShortBranceName}" == "development" -o "${ShortBranceName}" == "dev_publish_out" ] ; then
#    PackageFeatureType="formal"
#elif [ "${ShortBranceName}" == "dev_publish_in" ] ; then
#    PackageFeatureType="inner"
#else
#    PackageFeatureType="test"
#fi

if [ "${PackageTargetType}" == "生成最后要发布到AppStore的包" ] ; then
    PackageTargetType="formal"
elif [ "${PackageTargetType}" == "生成最后只发布到TestFlight的包" ] ; then
    PackageTargetType="inner"
elif [ "${PackageTargetType}" == "生成最后只发布到蒲公英的包" ] ; then
    PackageTargetType="dev"
else
    printf "${RED}发生错误，脚本中未处理输入源为 ${YELLOW}${PackageTargetType}${RED} 时候，应该映射到的【发布平台】，请先调整你的输入源！${NC}\n"
    exit_script
fi

echo "PlatformType=$PlatformType"
#echo "PackageFeatureType=$PackageFeatureType"
echo "PackageTargetType=$PackageTargetType"
echo "PackageNetworkType=$PackageNetworkType"



# 更改app信息，并返回 VERSION 和 BUILD
#VERSION="1."$(date "+%m.%d") # 1.02.21
#BUILD=$(date "+%m%d%H%M") # 02211506
cur_date_month=$(date "+%m")
cur_date_month=$((cur_date_month+12)) # 隔年了
cur_date_day=$(date "+%d")
cur_date_hour=$(date "+%H")
cur_date_minute=$(date "+%M")
#VERSION="1.${cur_date_month}.${cur_date_day}"   # 1.02.21
#BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506

if [ "${PackageTargetType}" == "dev" ] ; then
#    VERSION="1."$(date "+%m.%d") # 1.02.21
    VERSION="1.${cur_date_month}.${cur_date_day}" # 1.02.21
#    BUILD=$(date "+%m%d%H%M") # 02211506
    BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506 隔年了，修复Android的能否升级取决于build是否变大(iOS虽不用，但保持同步)
elif [ "${PackageTargetType}" == "inner" ] ; then
    VERSION="1.1.1" # 因为ios tf的上既放着审核包也放着内测包，所以为了避免审核包已经审核通过，所以内测包的版本要比审核包高，不然会在上传tf时候失败
    BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506
elif [ "${PackageTargetType}" == "formal" ] ; then
    if [ "${PlatformType}" == "iOS" ] ; then
        VERSION="1.2.4"
    elif [ "${PlatformType}" == "Android" ] ; then
        VERSION="1.2.4"
    else
        exit_script
    fi
    BUILD="${cur_date_month}${cur_date_day}${cur_date_hour}${cur_date_minute}" # 02211506
else
    exit_script
fi


BUILD=$(echo $BUILD | sed -r 's/0*([0-9])/\1/') # 去除字符串前所有的0
echo "BUILD=${BUILD}"


printf "${BLUE}正在执行命令(更新打包参数保存到 ${APPEVN_SAVE_TO_FILE} 文件中)《 ${YELLOW}sh ${bulidScriptCommon_dir_Absolute}/app_info_out_update.sh -appInfoF ${APPEVN_SAVE_TO_FILE} -p \"${PlatformType}\" -pt \"${PackageTargetType}\" -pn \"${PackageNetworkType}\" -v $VERSION -bd $BUILD ${BLUE}》${NC}\n"
if [ ! -f "${updateJsonEnv_scriptFile_Absolute}" ]; then
    printf "${RED}发生错误，用来更新项目【JSON信息环境】的文件不存在，请先检查 ${YELLOW}${updateJsonEnv_scriptFile_Absolute}${RED} ${NC}\n"
    exit_script
fi
sh ${updateJsonEnv_scriptFile_Absolute} -appInfoF ${APPEVN_SAVE_TO_FILE} -b "${BRANCH}" -p "${PlatformType}" -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
if [ $? != 0 ]; then
    sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${APPEVN_SAVE_TO_FILE} --log-robottype "error"
    exit_script
fi


# 更新app项目信息
if [ "${PlatformType}" == "iOS" ] ; then
    if [ ! -f "${updateIOSCodeEnv_scriptFile_Absolute}" ]; then
        printf "${RED}发生错误，用来更新【iOS项目代码环境】的文件不存在，请先检查 ${YELLOW}${updateIOSCodeEnv_scriptFile_Absolute}${RED} ${NC}\n"
        exit_script
    fi
    sh ${updateIOSCodeEnv_scriptFile_Absolute} -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
elif [ "${PlatformType}" == "Android" ] ; then
    if [ ! -f "${updateAndroidCodeEnv_scriptFile_Absolute}" ]; then
        printf "${RED}发生错误，用来更新【Android项目代码环境】的文件不存在，请先检查 ${YELLOW}${updateAndroidCodeEnv_scriptFile_Absolute}${RED} ${NC}\n"
        exit_script
    fi
    sh ${updateAndroidCodeEnv_scriptFile_Absolute} -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
else
    exit_script
fi
if [ $? != 0 ]; then
    printf "${RED}❌Error:环境切换错误，终止打包！${NC}\n"
    exit_script
fi










