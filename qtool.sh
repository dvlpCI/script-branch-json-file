#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-11-15 18:12:59
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
packageArg="qtool"

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
    get_package_util_script_path=$(qbase -package qbase -packageCodeDirName bin -path "get_package_util")
    if [ $? != 0 ]; then
        echo "❌Error:执行命令(获取包的路径)《 qbase -package qbase -packageCodeDirName bin -path \"get_package_util\" 》发生错误，原因如下:"
        echo "${get_package_util_script_path}" # 此时此值是错误信息
        exit 1
    fi
    # echo "正在执行命令(获取脚本包的版本号):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"version\" \"${args[@]}\" 》"
    # echo "正在执行命令(获取脚本包的根路径):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"homedir_abspath\" \"${args[@]}\" 》"
    qtool_latest_version=$(sh ${get_package_util_script_path} -package "qtool" -param "version" "${args[@]}")
    qtool_homedir_abspath=$(sh ${get_package_util_script_path} -package "qtool" -param "homedir_abspath" "${args[@]}")
    qtool_homedir_abspath="${qtool_homedir_abspath%/*}/lib" # 纠正路径(因为有些代码源码是放在bin，有些是放在lib)
    # echo "✅✅✅✅ qtool_latest_version=${qtool_latest_version}"
    # echo "✅✅✅✅ qtool_homedir_abspath=${qtool_homedir_abspath}"
    if [ $? != 0 ]; then
        exit 1
    fi
fi
if [ ! -d "${qtool_homedir_abspath}" ]; then
    echo "您的 ${packageArg} 库的根目录 ${qtool_homedir_abspath} 计算错误，请检查"
    exit 1
fi
# echo "${qtargetScript_curVersion_homedir_abspath}"

function _logQuickCmd() {
    qpackageJsonF="$qtool_homedir_abspath/qtool.json"
    cat "$qpackageJsonF" | jq '.quickCmd'
}

# qbase_homedir_abspath="~/Project/CQCI/script-qbase"
qbase_homedir_abspath=$(qbase -path home)
qbase_quickcmd_scriptPath=$qbase_homedir_abspath/qbase_quickcmd.sh
# qbase_quickcmd_scriptPath=qbase_quickcmd.sh

firstArg=$1 # 去除第一个参数之前，先保留下来
shift 1  # 去除前一个参数
allArgsExceptFirstArg="$@"  # 将去除前一个参数，剩余的参数赋值给新变量


# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
if echo "${versionCmdStrings[@]}" | grep -wq "${firstArg}" &>/dev/null; then
    echo "${qtool_latest_version}"
    exit 0
elif [ "${firstArg}" == "-path" ]; then
    # echo "qtool正在通过qbase调用快捷命令...《 sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg 》"
    sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg
    exit 0
elif [ "${firstArg}" == "-quick" ]; then
    qbase_checkInputArgsValid_scriptPath=$(qbase -path checkInputArgsValid)
    inputArgsErrorMessage=$(sh $qbase_checkInputArgsValid_scriptPath $allArgsExceptFirstArg)
    if [ $? != 0 ]; then
        echo "${inputArgsErrorMessage}"
        exit 1
    fi
    # echo "qtool正在通过qbase调用快捷命令...《 sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg 》"
    sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg
    exit 0
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
