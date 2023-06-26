#!/bin/bash
# 有可能需要修改的变量
# 

last_arg="${!#}"    # 获取最后一个参数
verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
else
    verbose=false
fi

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi
source ${qtoolScriptDir_Absolute}/base/get_system_env.sh

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

project_tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
# printf "${YELLOW}你所有的配置来自文件:%s${NC}\n" "${project_tool_params_file_path}"
project_path_map=$(cat ${project_tool_params_file_path} | jq -r ".project_path")



home_path_rel_tool_dir=$(echo ${project_path_map} | jq -r ".home_path_rel_this_dir")
# home_abspath=$(cd "$(dirname "$project_tool_params_file_path")/$home_path_rel_this_dir"; pwd)
home_abspath=$(joinFullPath_checkExsit "$(dirname $project_tool_params_file_path)" $home_path_rel_tool_dir)
if [ $? != 0 ]; then
    printf "${RED}home_abspath路径不存在，请检查 ${home_abspath}${NC}\n"
    exit_script
fi
printf "${BLUE}你要操作的项目的路径为：%s${NC}\n" "${home_abspath}"

bugly_config_file_path_rel_home_dir=$(echo ${project_path_map} | jq -r ".dsym_path_rel_home.app_bugly_config_file")
bugly_config_file_path=$(joinFullPath_checkExsit "$home_abspath" $bugly_config_file_path_rel_home_dir)
if [ $? != 0 ]; then
    printf "${RED}${bugly_config_file_path}${NC}\n"
    exit_script
fi

app_info_file_rel_home_dir=$(echo ${project_path_map} | jq -r ".other_path_rel_home.app_info_file")
app_info_abspath=$(joinFullPath_checkExsit "$home_abspath" $app_info_file_rel_home_dir)
if [ $? != 0 ]; then
    printf "${RED}app_info_abspath路径不存在，请检查 ${app_info_abspath}${NC}\n"
    exit_script
fi


# 获取dSYM文件
get_xcarchive_output_dir() {
    app_pack_params_map=$(cat ${app_info_abspath} | jq -r ".")
    dSYM_file_path_rel_home_dir=$(echo ${app_pack_params_map} | jq -r ".package_url_result.package_local_dSYM_file_path")
    dSYM_file_path=$(joinFullPath_checkExsit "$home_abspath" $dSYM_file_path_rel_home_dir)
    if [ $? != 0 ]; then
        printf "${RED}dSYM_file_path路径不存在，请检查 ${dSYM_file_path}${NC}\n"
        exit_script
    fi
    if [ -z "${dSYM_file_path}" ] || [ "${dSYM_file_path}" == "null" ]; then
        echo "❌Error:获取打包输出目录参数失败：《 echo ${app_pack_params_map} | jq -r \".package_url_result.package_local_dSYM_file_path\"》，请检查补充"
        return 1
    fi

    

    if [ ! -e ${dSYM_file_path} ];then
        echo "Failure：dsym文件不存在(路径见文尾)，请检查是不是没有生成，请检查xcodebuild -workspace命令中的-configuration参数是否正确。查找的dsym路径为：${dSYM_file_path}"
        return 1
    fi

    DWARF_DSYM_FOLDER_PATH=$dSYM_file_path
    printf "${BLUE}符号表dSYM文件为:%s${NC}\n" "${DWARF_DSYM_FOLDER_PATH}"
}



checkShouldContinue() {
    shouldContinue=false
    while [ "$shouldContinue" = false ]; do
        read -r -p "请确认所要上传的符号表dSYM文件是否正确(正确并进行上传请输入y，若要退出请输入Q|q) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            printf "${BLUE}放弃上传${NC}"
            return 1
        elif [[ "$option" == [yY] ]]; then
            shouldContinue=true
            break
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

get_xcarchive_output_dir

checkShouldContinue
if [ $? != 0 ]; then
    exit 1
fi





buglyqq_upload_symbol_rel_home_dir=$(echo ${project_path_map} | jq -r ".dsym_path_rel_home.buglyqq_upload_symbol")
buglyqq_upload_symbol=$(joinFullPath_checkExsit "$home_abspath" $buglyqq_upload_symbol_rel_home_dir)
if [ $? != 0 ]; then
    printf "${RED}buglyqq_upload_symbol路径不存在，请检查 ${buglyqq_upload_symbol}${NC}\n"
    exit_script
fi

if [ "$verbose" = true ]; then
  printf "正在执行命令(获取bugly配置，并进行上传):《 sh ${CurrentDIR_Script_Absolute}/base_bugly_upload.sh -appBuglyConfigF \"${bugly_config_file_path}\" appBuglyScriptF \"${buglyqq_upload_symbol}\" -appVersionInfoF \"${app_info_abspath}\" -appDSYMF \"${DWARF_DSYM_FOLDER_PATH}\" \n》"
fi
sh ${CurrentDIR_Script_Absolute}/base_bugly_upload.sh -appBuglyConfigF "${bugly_config_file_path}" -appBuglyScriptF "${buglyqq_upload_symbol}" -appVersionInfoF "${app_info_abspath}" -appDSYMF "${DWARF_DSYM_FOLDER_PATH}"