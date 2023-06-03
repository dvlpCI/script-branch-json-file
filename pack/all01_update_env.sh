#!/bin/bash
:<<!
更新环境

bulidScriptProject_dir_Absolute="/Users/qian/Project/Bojue/mobile_flutter_wish/bulidScript"
bulidScriptCommon_dir_Absolute="/Users/qian/Project/Bojue/mobile_flutter_wish/buildScriptSource/bulidScriptCommon/"
PlatformType="Android"
PackageTargetType="生成最后只发布到蒲公英的包"
PackageNetworkType="测试"
APPEVN_SAVE_TO_FILE="/Users/qian/Project/Bojue/mobile_flutter_wish/bulidScript/app_info.json"
echo "正在执行《sh all01_update_env.sh -projectScriptAbsDir \"${bulidScriptProject_dir_Absolute}\" -commonScriptAbsDir \"${bulidScriptCommon_dir_Absolute}\" -pl ${PlatformType} -pt $PackageTargetType -pn $PackageNetworkType -saveToF \"${APPEVN_SAVE_TO_FILE}\" 》"
sh all01_update_env.sh -projectScriptAbsDir "${bulidScriptProject_dir_Absolute}" -commonScriptAbsDir "${bulidScriptCommon_dir_Absolute}" -pl ${PlatformType} -pt $PackageTargetType -pn $PackageNetworkType -saveToF "${APPEVN_SAVE_TO_FILE}"
exit
!


# shell 参数具名化
show_usage="args: [-commonScriptAbsDir, -projectScriptAbsDir, -pl , -pt , -pn, -saveToF]\
                                  [--commonScript_dir_Absolute=, --projectScript_dir_Absolute=, --platformType=, --package_target_type=, --package_network_type=, --save_to_file=]"

while [ -n "$1" ]
do
        case "$1" in
                -commonScriptAbsDir|--commonScript_dir_Absolute) bulidScriptCommon_dir_Absolute=$2; shift 2;;
                -projectScriptAbsDir|--projectScript_dir_Absolute) bulidScriptProject_dir_Absolute=$2; shift 2;;
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

echo "bulidScriptCommon_dir_Absolute=$bulidScriptCommon_dir_Absolute"
echo "bulidScriptProject_dir_Absolute=$bulidScriptProject_dir_Absolute"
echo "APPEVN_SAVE_TO_FILE=$APPEVN_SAVE_TO_FILE"
echo "PlatformType=$PlatformType"
echo "PackageTargetType=$PackageTargetType"
echo "PackageNetworkType=$PackageNetworkType"


if [ "${PackageNetworkType}" == "开发" ] ; then
    echo "这个是【开发】包"
    PackageNetworkType='develop1'
elif [ "${PackageNetworkType}" == "测试" ] ; then
    echo "这个是【测试】包"
    PackageNetworkType='test1'
elif [ "${PackageNetworkType}" == "预生产" ] ; then
    echo "这个是【预生产】包"
    PackageNetworkType='preproduct'
elif [ "${PackageNetworkType}" == "生产" ] ; then
    echo "这个是【生产】包"
    PackageNetworkType='product'
else
    echo "发布环境未正确配置，请检查自动化配置及其脚本"
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
    echo "发布平台未正确配置，请检查自动化配置及其脚本"
    exit_script
fi

echo "PlatformType=$PlatformType"
#echo "PackageFeatureType=$PackageFeatureType"
echo "PackageTargetType=$PackageTargetType"
echo "PackageNetworkType=$PackageNetworkType"

exit


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


echo "正在执行命令(更新打包参数保存到${APPEVN_SAVE_TO_FILE}文件中)《sh ${bulidScriptCommon_dir_Absolute}/app_info_out_update.sh -appInfoF ${APPEVN_SAVE_TO_FILE} -p \"${PlatformType}\" -pt \"${PackageTargetType}\" -pn \"${PackageNetworkType}\" -v $VERSION -bd $BUILD 》"
sh ${bulidScriptCommon_dir_Absolute}/app_info_out_update.sh -appInfoF ${APPEVN_SAVE_TO_FILE} -p "${PlatformType}" -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
if [ $? != 0 ]; then
    sh ${bulidScriptCommon_dir_Absolute}/noti_new_package.sh -appInfoF ${APPEVN_SAVE_TO_FILE} --log-robottype "error"
    exit_script
fi


# 更新app项目信息
if [ "${PlatformType}" == "iOS" ] ; then
    sh $WORKSPACE/bulidScript/update_app_info_ios.sh -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
elif [ "${PlatformType}" == "Android" ] ; then
    sh $WORKSPACE/bulidScript/update_app_info_android.sh -pt "${PackageTargetType}" -pn "${PackageNetworkType}" -v $VERSION -bd $BUILD
else
    exit_script
fi
if [ $? != 0 ]; then
    echo "❌Error:环境切换错误，终止打包"
    exit_script
fi










