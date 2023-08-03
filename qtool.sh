#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-08-03 20:55:49
 # @Description: 
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

qtoolQuickCmdStrings=("cz" "help") # qtool 支持的快捷命令



# 本地测试
function local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qbaseScriptDir_Absolute=${CurrentDIR_Script_Absolute}
    echo "$qbaseScriptDir_Absolute"
}



# 计算倒数第一个参数的位置
argCount=$#
if [ $argCount -ge 1 ]; then
    last_index=$((argCount))
    last_arg=${!last_index} # 获取倒数第一个参数
    if [ $argCount -ge 2 ]; then
        second_last_index=$((argCount - 1))
        second_last_arg=${!second_last_index} # 获取倒数第二个参数
    fi
fi
# echo "========second_last_arg=${second_last_arg}"
# echo "========       last_arg=${last_arg}"

verboseStrings=("--verbose" "-verbose") # 输入哪些字符串算是想要日志
# 判断最后一个参数是否是 verbose
if echo "${verboseStrings[@]}" | grep -wq -- "$last_arg"; then
    verbose=true
    verboseParam=$last_arg
    if [ "$second_last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
else # 最后一个元素不是 verbose
    verbose=false
    if [ "$last_arg" == "test" ]; then
        isTestingScript=true
    else
        isTestingScript=false
    fi
fi


args=()
if [ "${verbose}" == true ]; then
    args+=("-verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("test")
fi

# 如果是测试脚本中
if [ "${isTestingScript}" == true ]; then
    qtool_homedir_abspath=$(local_test) # 本地测试
else
    qtoolScriptDir_Absolute="$(cd "$(dirname "$0")" && pwd)"
    get_package_util_script_path=$(qbase -path "get_package_util")
    # echo "✅✅✅✅ get_package_util_script_path = ${get_package_util_script_path}"
    # echo "正在执行命令(获取脚本包的版本号):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"version\" \"${args[@]}\" 》"
    # echo "正在执行命令(获取脚本包的根路径):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"homedir_abspath\" \"${args[@]}\" 》"
    qtool_latest_version=$(sh ${get_package_util_script_path} -package "qtool" -param "version" "${args[@]}")
    qtool_homedir_abspath=$(sh ${get_package_util_script_path} -package "qtool" -param "homedir_abspath" "${args[@]}")
    qtool_homedir_abspath="${qtool_homedir_abspath%/*}/lib" # 纠正路径(因为有些代码源码是放在bin，有些是放在lib)
    # echo "✅✅✅✅ qtool_latest_version=${qtool_latest_version}"
    # echo "✅✅✅✅ qbase_homedir_abspath=${qtool_homedir_abspath}"
    if [ $? != 0 ]; then
        exit 1
    fi
fi
# echo "${qtargetScript_curVersion_homedir_abspath}"

function get_path() {
    if [ "$1" == "home" ]; then
        echo "$qtool_homedir_abspath"
    else
        echo "$qtool_homedir_abspath"
    fi
}


# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
if echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${qtool_latest_version}"
elif [ "$1" == "-path" ]; then
    get_path "$2"
else
    echo "${qtool_latest_version}"
fi









qtoolScriptDir_Absolute="${qtool_homedir_abspath}"
# echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}"

# 检查运行环境
sh ${qtoolScriptDir_Absolute}/qtool_runenv.sh "${qtoolScriptDir_Absolute}"
if [ $? != 0 ]; then
    exit 1
fi




# 引入公共方法
source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了使用 project_tool_params_file_path 方法

project_tool_params_file_path=$(get_sysenv_project_params_file)
if [ $? != 0 ]; then
    # printf "${RED}project_tool_params_file_path=${project_tool_params_file_path}${NC}\n"
    sh "${qtoolScriptDir_Absolute}/qtool_change.sh" "${qtoolScriptDir_Absolute}"
    if [ $? != 0 ]; then
        exit 1
    else
        effectiveEnvironmentVariables # 避免环境变量没有生效
        project_tool_params_file_path=$(get_sysenv_project_params_file) # 设置完重新获取
    fi
fi
project_dir=$(get_sysenv_project_dir)
printf "${GREEN}温馨提示:您当前选择的操作参数使用  ${YELLOW}${project_tool_params_file_path} ${GREEN}。【其操作的项目为 ${YELLOW}${project_dir} ${GREEN}】。(如果需要变更，请输入${PURPLE}change${GREEN})${NC}\n"


# elif [ "$1" == "change" ]; then
#     sh ${qtoolScriptDir_Absolute}/qtool_change.sh "${qtoolScriptDir_Absolute}"
if echo "${qtoolQuickCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    if [ "$1" == "help" ]; then
        sh ${qtoolScriptDir_Absolute}/qtool_help.sh
    elif [ "$1" == "cz" ]; then
        sh ${qtoolScriptDir_Absolute}/commit/commit_message.sh
    else
        printf "${YELLOW}温馨提示:无法执行未知命令《 qtool \"$1\" 》，请检查"
    fi
else
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}" "${verboseParam}"
fi
