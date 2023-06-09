#!/bin/sh
###
 # @Author: dvlproad
 # @Date: 2023-04-14 14:09:09
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:25
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

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi
pre_push_binary_script_file=${qtoolScriptDir_Absolute}/rebase/pre-push

source ${qtoolScriptDir_Absolute}/base/get_system_env.sh
project_dir=$(get_sysenv_project_dir)
# cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。



# if [ ! -d "$../.git/hooks/pre-push" ]; then


project_hook_dir_abspath=$(joinFullPath_noCheck "$project_dir/" ".git/hooks/pre-push")
if [ $? != 0 ]; then
    exit_script
fi

# printf "${BLUE}正在执行命令：《${YELLOW} cp \"${pre_push_binary_script_file}\" \"${project_hook_dir_abspath}\" ${BLUE}》${NC}\n"
cp "${pre_push_binary_script_file}" "${project_hook_dir_abspath}"
if [ $? != 0 ]; then 
    printf "${RED} pre-push 的 hook 拷贝操作失败${NC}\n"
    exit 1
fi
exit 0
# fi

