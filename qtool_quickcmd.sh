#!/bin/bash
###
# @Author: dvlproad
# @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 22:16:09
# @Description:
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

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
else # 最后一个元素不是 verbose
    verbose=false
fi

function _verbose_log() {
    if [ "$verbose" == true ]; then
        echo "$1"
    fi
}


qbase_homedir_abspath="$(cd "$(dirname "$0")" && pwd)" # 本地测试

packageArg="qtool"
qpackageJsonF="$qbase_homedir_abspath/${packageArg}.json"
if [ ! -f "${qpackageJsonF}" ]; then
    echo "${RED}❌Error:您的第二个参数 ${packageArg} 中缺少 json 文件，请检查。如果本脚本是被qtool调用的，请检查您在qtool脚本中传入的 -package 和 -packageCodeDirName 的参数值。${NC}"
    exit 1
fi
function _logQuickCmd() {
    cat "$qpackageJsonF" | jq '.quickCmd'
}

function get_path_quickCmd() {
    specified_value=$1
    
    qbase_package_path_and_cmd_menu_scriptPath=$(qbase -path package_path_and_cmd_menu)
    relpath=$(sh $qbase_package_path_and_cmd_menu_scriptPath -file "${qpackageJsonF}" -keyType "cmd" -key "${specified_value}")
    if [ $? != 0 ]; then
        echo "$relpath" # 此时此值是错误信息
        return 1
    fi
    
    relpath="${relpath//.\//}"  # 去掉开头的 "./"
    echo "$qbase_homedir_abspath/$relpath"
}


function quickCmdExec() {
    # allArgsForQuickCmd="$@"
    # _verbose_log "✅快捷命令及其所有参数分别为 ${BLUE}${allArgsForQuickCmd}${BLUE} ${NC}"
    if [ -z "$1" ]; then
         printf "${YELLOW}提示：您未设置要执行的快捷命令。附:所有支持的快捷命令如下：${NC}\n"
        _logQuickCmd
        return
    fi

    quickCmdString=$1
    allArgArray=($@)
    # _verbose_log "😄😄😄哈哈哈 ${allArgArray[*]}"
    allArgCount=${#allArgArray[@]}
    for ((i=0;i<allArgCount;i+=1))
    {
        if [ $i -eq 0 ]; then
            continue
        fi
        currentArg=${allArgArray[i]}
        quickCmdArgs[${#quickCmdArgs[@]}]=${currentArg}
    }
    _verbose_log "✅快捷命令及其所有参数分别为${BLUE} ${quickCmdString}${BLUE}${NC}:${CYAN}${quickCmdArgs[*]} ${CYAN}。${NC}"

    quickCmd_script_path=$(get_path_quickCmd "${quickCmdString}")
    if [ $? == 0 ] && [ -f "$quickCmd_script_path" ]; then
        # _verbose_log "${YELLOW}正在执行命令(根据rebase,获取分支名):《${BLUE} sh ${quickCmd_script_path} ${quickCmdArgs[*]} ${BLUE}》${NC}"
        sh ${quickCmd_script_path} ${quickCmdArgs[*]}
    else 
        printf "${RED}抱歉：暂不支持${BLUE} ${quickCmdString} ${RED} 快捷命令，请检查${NC}\n"
        exit 1
    fi
}




# 输出sh的所有参数
# echo "传递给脚本的参数列表："
# echo "$@"

quickCmdExec "$@"
