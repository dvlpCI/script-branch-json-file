#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-12 15:11:53
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
local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute}
}



# 本地测试
function local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qbaseScriptDir_Absolute=${CurrentDIR_Script_Absolute}
    echo "$qbaseScriptDir_Absolute"
}

function getMaxVersionNumber_byDir() {
    # 指定目录
    dir_path="$1"

    # 获取目录下所有文件的列表
    files=("$dir_path"/*)

    # 从文件列表中筛选出版本号
    versions=()
    for file in "${files[@]}"; do
        version=$(basename "$file" | cut -d "-" -f 2)
        versions+=("$version")
    done

    # 选择最新的版本号
    latest_version=$(echo "${versions[@]}" | tr ' ' '\n' | sort -r | head -n 1)
    echo "${latest_version}"
}

function getHomeDir_abspath_byVersion() {
    # 指定目录
    dir_path="$1"
    latest_version="$2"

    # 输出最新版本的路径
    curretnVersionDir_abspath="$dir_path/$latest_version/lib" # 放在lib目录下
    if [[ $curretnVersionDir_abspath =~ ^~.* ]]; then
        # 如果 $curretnVersionDir_abspath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        curretnVersionDir_abspath="${HOME}${curretnVersionDir_abspath:1}"
    fi
    echo "$curretnVersionDir_abspath"

    if [ ! -d "${curretnVersionDir_abspath}" ]; then
        return 1
    fi
}

# 粗略计算，容易出现arm64芯片上的路径不对等问题
# qbaseScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"

# 精确计算
# which_qbase_bin_dir_path=$(which qtool)
# which_qbase_source_dir_path="$(echo "$which_qbase_bin_dir_path" | sed 's/bin/Cellar/')"
# echo "which_qbase_bin_dir_path: $which_qbase_bin_dir_path"
# echo "which_qbase_source_dir_path: $which_qbase_source_dir_path"

function getqscript_allVersionHomeDir_abspath() {
    requstQScript=$1
    homebrew_Cellar_dir="$(echo $(which $requstQScript) | sed 's/\/bin\/.*//')"
    if [ -z "${homebrew_Cellar_dir}" ]; then
        return 1
    fi

    if [[ "${homebrew_Cellar_dir}" == */ ]]; then
        homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
    fi
    homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

    qscript_allVersion_homedir="${homebrew_Cellar_dir}/$requstQScript"
    echo "${qscript_allVersion_homedir}"
}

qtargetScript_allVersion_homedir=$(getqscript_allVersionHomeDir_abspath "qtool")
qtargetScript_latest_version=$(getMaxVersionNumber_byDir "${qtargetScript_allVersion_homedir}")

versionCmdStrings=("--version" "-version" "-v" "version")

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

# 如果是获取版本号
if echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${qtargetScript_latest_version}"
    exit
fi

# 如果是测试脚本中
if [ "${isTestingScript}" == true ]; then
    qtargetScript_curVersion_homedir_abspath=$(local_test) # 本地测试
else
    qtargetScript_curVersion_homedir_abspath=$(getHomeDir_abspath_byVersion "${qtargetScript_allVersion_homedir}" "${qtargetScript_latest_version}")
    if [ $? != 0 ]; then
        exit 1
    fi
fi
echo "${qtargetScript_curVersion_homedir_abspath}"





qtoolScriptDir_Absolute="${qtargetScript_curVersion_homedir_abspath}"
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
