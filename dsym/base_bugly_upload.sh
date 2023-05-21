#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2022-02-23 17:13:13
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-22 02:52:55
 # @Description: 
### 
# 有可能需要修改的变量
# 

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# shell 参数具名化
show_usage="args: [-appBuglyConfigF, -appVersionInfoF, -appDSYMF]\
                                  [-app-bugly-config-file=, --app-version-info-file=, --app-dsym-file=]"

while [ -n "$1" ]
do
        case "$1" in
                -appBuglyConfigF|--app-bugly-config-file) bugly_config_file_path=$2; shift 2;;
                -appBuglyScriptF|--app-bugly-script-file) buglyqq_upload_symbol=$2; shift 2;;
                -appVersionInfoF|--app-version-info-file) app_info_abspath=$2; shift 2;;
                -appDSYMF|--app-dsym-file) DWARF_DSYM_FOLDER_PATH=$2; shift 2;;
                --) break ;;
                *) echo ""; break ;;
        esac
done


if [ ! -f "${bugly_config_file_path}" ]; then
    printf "${RED}您项目的bugly配置信息文件[%s]不存在，请检查${NC}\n" "${bugly_config_file_path}"
    exit_script
fi
printf "${BLUE}您项目的bugly配置信息的将取自：%s${NC}\n" "${bugly_config_file_path}"

if [ ! -f "${buglyqq_upload_symbol}" ]; then
    printf "${RED}您项目的bugly符号表上传脚本文件[%s]不存在，请检查${NC}\n" "${buglyqq_upload_symbol}"
    exit_script
fi



if [ ! -f "${app_info_abspath}" ]; then
    printf "${RED}您项目的app版本信息文件[%s]不存在，请检查${NC}\n" "${app_info_abspath}"
    exit_script
fi
printf "${BLUE}app的打包信息文件路径为：%s${NC}\n" "${app_info_abspath}"


if [ ! -d "${DWARF_DSYM_FOLDER_PATH}" ]; then # 注意:这是个目录
    printf "${RED}您项目的dsym文件[%s]不存在，请检查${NC}\n" "${DWARF_DSYM_FOLDER_PATH}"
    exit_script
fi
printf "${BLUE}项目的dsym文件路径为：%s${NC}\n" "${DWARF_DSYM_FOLDER_PATH}"




# 获取对dSYM处理的bugly参数
get_bugly_config() {
    target_network_type=$1
    target_platom_type=$2

    APP_BUNDLE_IDENTIFIER=$(cat ${bugly_config_file_path} | jq -r ".app_bundle_id")
    
    
    
    target_network_bugly_config_map=$(cat ${bugly_config_file_path} | jq -r ".app_bugly_config[] | select(.network==\"${target_network_type}\")")
    if [ -z "${target_network_bugly_config_map}" ]; then
        echo "❌Error:获取分支的详细信息失败：《 cat ${bugly_config_file_path} | jq -r \".app_bugly_config[] | select(.network==\"${target_network_type}\")\"》，请检查补充"
        return 1
    fi

    
    
    target_platom_network_bugly_config_map=$(echo ${target_network_bugly_config_map} | jq -r ".${target_platom_type}")
    if [ -z "${target_platom_network_bugly_config_map}" ] || [ "${target_platom_network_bugly_config_map}" == "null" ]; then
        echo "❌Error:获取分支的详细信息失败：《 echo ${target_network_bugly_config_map} | jq -r \".${target_platom_type}\"》，请检查补充"
        return 1
    fi

    target_platom_network_bugly_appDes=$(echo "${target_platom_network_bugly_config_map}" | jq -r ".buglyAppDes")
    BUGLY_APP_ID=$(echo "${target_platom_network_bugly_config_map}" | jq -r ".buglyAppId")
    if [ -z "${BUGLY_APP_ID}" ] || [ "${BUGLY_APP_ID}" == "null" ]; then
        echo "❌Error:获取bugly的appid信息失败：《 echo \"${target_platom_network_bugly_config_map}\" | jq -r \".buglyAppId\"》，请检查补充"
        return 1
    fi
    BUGLY_APP_KEY=$(echo "${target_platom_network_bugly_config_map}" | jq -r ".buglyAppKey")

    APPTARGET_NAME=$(echo "${target_platom_network_bugly_config_map}" | jq -r ".app_TARGET_name")
    
    printf "${BLUE}%s(%s):\napp_target_name:%s\nbugly_appid:%-15s\nbugly_appkey:%-15s ${NC}\n" "${target_platom_network_bugly_appDes}" "${APP_BUNDLE_IDENTIFIER}" "${APPTARGET_NAME}" "${BUGLY_APP_ID}" "${BUGLY_APP_KEY}" # 要拼接两个字符串，并在拼接的结果中，如果第一个字符串不够 15 位则自动补充空格到 15 位
}


getAppInfo() {
    app_pack_params_map=$(cat ${app_info_abspath} | jq -r ".")
    APPENVIRONMENT=$(echo ${app_pack_params_map} | jq -r ".package_default_env")
    platform_type=$(echo ${app_pack_params_map} | jq -r ".platform_type")
    get_bugly_config "${APPENVIRONMENT}" "${platform_type}"
    if [ $? != 0 ]; then
        exit_script
    fi

    # PackageTargetType=$(echo ${app_pack_params_map} | jq .package_default_target | sed 's/\"//g')
    # PackageNetworkType=$(echo ${app_pack_params_map} | jq} .package_default_env | sed 's/\"//g')
    App_Version=$(echo ${app_pack_params_map} | jq -r ".version")
    App_BuildNumber=$(echo ${app_pack_params_map} | jq -r ".buildNumber")
    if [ "${platform_type}" == "iOS" ]; then
        App_Platform="IOS" # bugly脚本中的参数 -platform 平台类型包含三个选项 Android、IOS两个选项，注意大小写要正确
    else
        App_Platform=$platform_type
    fi
}
getAppInfo


echo ""
echo ""
echo "------------------- 准备开始进行dsym符号表上传到'bugly'上 -------------------"
# dSYM上传方法一(只用buglySymboliOS.jar和dSYMUpload.sh，生成zip和上传为一体)：


# BUGLY_APP_VERSION="${App_Version}(${App_BundleID})_${APPENVIRONMENT}"    # 生成形如 1.1.0(100)_Product 的bugly app 版本号


# # 检查执行命令时候需要的jar文件是否再bin中有存在
# BIN_buglySymboliOS_JAR_FILE_PATH_rel_home_dir=$(echo ${project_path_map} | jq -r ".dsym_path_rel_home.BIN_buglySymboliOS_JAR_FILE_PATH")
# # echo "-------1-----${BIN_buglySymboliOS_JAR_FILE_PATH_rel_home_dir}"
# BIN_buglySymboliOS_JAR_FILE_PATH=$(joinFullPath "$home_abspath" $BIN_buglySymboliOS_JAR_FILE_PATH_rel_home_dir)
# if [ $? != 0 ]; then
#     echo "-------2-----${BIN_buglySymboliOS_JAR_FILE_PATH}"
#     exit_script
# fi
# if [ ! -e ${BIN_buglySymboliOS_JAR_FILE_PATH} ];then
#     echo "Failure：bin下的buglySymboliOS.jar文件不存在，请检查。如果又没请手动添加复制一份过去即可。查找的~/bin/buglySymboliOS.jar路径为：${BIN_buglySymboliOS_JAR_FILE_PATH}"
#     exit_script
# fi



# SYMBOL_OUTPUT_rel_home_dir=$(echo ${project_path_map}  | jq -r ".dsym_path_rel_home" | jq -r ".SYMBOL_OUTPUT_rel_this_dir")
# if [ -z "${SYMBOL_OUTPUT_rel_home_dir}" ] || [ "${SYMBOL_OUTPUT_rel_home_dir}" == "null" ]; then
#     echo "执行命令获取 SYMBOL_OUTPUT_rel_home_dir 属性失败：《 echo ${project_path_map} | jq -r \".dsym_path_rel_home\" | jq -r \".SYMBOL_OUTPUT_rel_this_dir\" 》，请检查"
#     exit_script
# fi
# 
# createIfNoExsit=true
# joinFullPath "$home_abspath" $SYMBOL_OUTPUT_rel_home_dir "${createIfNoExsit}"
# SYMBOL_OUTPUT_dir_abspath=$(joinFullPath "$home_abspath" $SYMBOL_OUTPUT_rel_home_dir "${createIfNoExsit}")
# if [ $? != 0 ]; then
#     echo "-------3.1-----${SYMBOL_OUTPUT_dir_abspath}"
#     exit_script
# fi
# printf "${BLUE}备注：dsym的输出路径将为：%s${NC}\n" "${SYMBOL_OUTPUT_dir_abspath}"

# UPLOAD_DSYM_ONLY=ture

# DSYMUPLOAD_sh_FILE_PATH_rel_home_dir=$(echo ${project_path_map} | jq -r ".dsym_path_rel_home.dSYMUpload_script_file_path")
# DSYMUPLOAD_sh_FILE_PATH=$(joinFullPath "$home_abspath" $DSYMUPLOAD_sh_FILE_PATH_rel_home_dir)
# if [ $? != 0 ]; then
#     exit_script
# fi



# echo "开始执行以下dSYM命令为：《sh ${DSYMUPLOAD_sh_FILE_PATH} ${BUGLY_APP_ID} ${BUGLY_APP_KEY} ${APP_BUNDLE_IDENTIFIER} ${BUGLY_APP_VERSION} ${DWARF_DSYM_FOLDER_PATH} ${SYMBOL_OUTPUT_dir_abspath} ${UPLOAD_DSYM_ONLY}》"
# sh ${DSYMUPLOAD_sh_FILE_PATH} ${BUGLY_APP_ID} ${BUGLY_APP_KEY} ${APP_BUNDLE_IDENTIFIER} ${BUGLY_APP_VERSION} ${DWARF_DSYM_FOLDER_PATH} ${SYMBOL_OUTPUT_dir_abspath} ${UPLOAD_DSYM_ONLY}
echo "开始执行以下dSYM命令为：《java -jar ${buglyqq_upload_symbol} -appid ${BUGLY_APP_ID} -appkey ${BUGLY_APP_KEY} -bundleid ${APP_BUNDLE_IDENTIFIER} -version ${App_Version} -platform ${App_Platform} -inputSymbol ${DWARF_DSYM_FOLDER_PATH} 》"
java -jar ${buglyqq_upload_symbol} -appid ${BUGLY_APP_ID} \
                                    -appkey ${BUGLY_APP_KEY} \
                                    -bundleid ${APP_BUNDLE_IDENTIFIER} \
                                    -version ${App_Version} \
                                    -platform ${App_Platform} \
                                    -inputSymbol ${DWARF_DSYM_FOLDER_PATH}
                                    # -inputMapping <mapping file>
if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
then
    echo "-------- 上传dsym上传到bugly成功 --------"
else
    echo "-------- Failure：上传dsym上传到bugly --------"
fi


# # dSYM上传方法二(要先生成zip，再自己讲zip上传)：
# BUGLY_BUILD_FILE_PATH=$ROOT_DIR/buglySymboliOS/buglySymboliOS.jar
# DSYM_FILE_PATH=${DWARF_DSYM_FOLDER_PATH}
# echo "BUGLY_BUILD_FILE_PATH:      ${BUGLY_BUILD_FILE_PATH}"
# echo "DSYM_FILE_PATH:             ${DSYM_FILE_PATH}"
# if [ ! -e ${DSYM_FILE_PATH} ];then
#     echo "Failure：dsym文件不存在，请检查是不是没有生成，请检查xcodebuild -workspace命令中的-configuration参数是否正确"
#     exit_script
# fi

# java -jar ${BUGLY_BUILD_FILE_PATH} -i ${DSYM_FILE_PATH}
# echo "上述符号表生成命令为：《java -jar ${BUGLY_BUILD_FILE_PATH} -i ${DSYM_FILE_PATH}》"
# if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
# then
#     echo "-------- dSYM的符号表生成成功，开始进行dSYM的符号表上传 --------"
#     # 1.1、修改新增的Run Scrpit中的 <YOUR_APP_ID> 为您的App ID，<YOUR_APP_KEY>为您的App Key，<YOUR_BUNDLE_ID> 为App的Bundle Id
#     # 脚本默认在Debug模式及模拟器编译情况下不会上传符号表，在需要上传的时候，请修改下列选项
#     # 2.1、Debug模式编译是否上传，1＝上传 0＝不上传，默认不上传    UPLOAD_DEBUG_SYMBOLS=0
#     # 2.2、模拟器编译是否上传，1＝上传 0＝不上传，默认不上传        UPLOAD_SIMULATOR_SYMBOLS=0
#     # 至此，自动上传符号表脚本配置完毕，Bugly 会在每次 Xcode 工程编译后自动完成符号表配置工作。
#     # #
    
#     # ①bugly的dsym上传地址
#     BUGLY_SYMBOL_JAR_PATH="dsymtool/buglySymboliOS.jar"
#     DSYM_UPLOAD_URL="https://${BUGLY_DSYM_UPLOAD_DOMAIN}/openapi/file/upload/symbol?app_id=${BUGLY_APP_ID}&app_key=${BUGLY_APP_KEY}"
#     echo "dSYM upload url: ${DSYM_UPLOAD_URL}"

#     echo "-----------------------------"    # 以下用 \ 做连接符
#     STATUS=$(/usr/bin/curl -k "${DSYM_UPLOAD_URL}" --form "api_version=1" \
#     --form "app_id=${BUGLY_APP_ID}" --form "app_key=${BUGLY_APP_KEY}" --form "symbolType=2" \
#     --form "bundleId=${APP_BUNDLE_IDENTIFIER}" --form "productVersion=${BUGLY_APP_VERSION}" \
#     --form "fileName=${P_BSYMBOL_ZIP_FILE_NAME}" --form "file=@${P_BSYMBOL_ZIP_FILE}" --verbose)
#     echo "-----------------------------"

#     UPLOAD_RESULT="FAILTURE"
#     echo "Bugly server response: ${STATUS}"
#     if [ ! "${STATUS}" ]; then
#         echo "Error: Failed to upload the zip archive file."
#     elif [[ "${STATUS}" == *"{\"reponseCode\":\"0\"}"* ]]; then
#         echo "Success to upload the dSYM for the app [${APP_BUNDLE_IDENTIFIER} ${BUGLY_APP_VERSION}]"
#         UPLOAD_RESULT="SUCCESS"
#     else
#         echo "Error: Failed to upload the zip archive file to Bugly."
#     fi

#     # "${altoolPath}" --upload-app -f ${IPA_FILE_FULLPATH} -u ${AppleID} -p ${AppleIDPWD} -t ios --output-format xml
#     # if [ $? = 0 ]   # 上个命令的退出状态，或函数的返回值。
#     # then
#     #     echo "-------- 上传dsym到Bugly成功 --------"
#     # else
#     #     echo "-------- 上传dsym到Bugly成功 --------"
#     # fi
# else
#     echo "-------- dSYM的符号表生成失败 --------"
# fi

# echo ""
# echo "所有脚本执行结束！"
# echo ""

