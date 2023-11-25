#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-03 19:55:44
# @FilePath: src/branchGit_create.sh
# @Description: 分支JSON的创建-shell
###

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi
source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了引入 open_sysenv_file getAbsPathByFileRelativePath 方法
source ${qtoolScriptDir_Absolute}/src/framework_category_util.sh # 为了引入 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 1、branchJsonName_input 分支json文件名的输入
quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

function getCategoryFile() {
    # 读取文件内容
    tool_root_content=$(cat "${target_branch_type_file_abspath}")
    relFilePathKey=".branch_belong_file_rel_this_file"
    rel_file_path_value=$(echo "$tool_root_content" | jq -r "${relFilePathKey}")
    if [ -z "${rel_file_path_value}" ] || [ "${rel_file_path_value}" == "null" ]; then
        printf "%s" "${RED}请先在${BLUE} ${target_branch_type_file_abspath} ${RED}文件中设置${BLUE} ${relFilePathKey} ${NC}\n"
        exit_script
    fi

    target_file_abspath=$(getAbsPathByFileRelativePath "${target_branch_type_file_abspath}" $rel_file_path_value)
    if [ $? != 0 ]; then
        printf "%s" "${RED}拼接${BLUE} ${target_branch_type_file_abspath} ${RED}和${BLUE} ${rel_file_path_value} ${RED}组成的路径结果错误，错误结果为 ${target_file_abspath} ${NC}\n"
        exit_script
    fi

    echo "${target_file_abspath}"
}

target_branch_type_file_abspath=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
if [ ! -f "${target_branch_type_file_abspath}" ]; then
    echo "${RED}您的 target_branch_type_file_abspath = ${BLUE} ${target_branch_type_file_abspath} {RED}不存在，请检查${NC}"
    exit 1
fi
# echo "=======target_branch_type_file_abspath=${target_branch_type_file_abspath}"

target_category_file_abspath=$(getCategoryFile)
if [ $? != 0 ]; then
    echo "${target_category_file_abspath}" # 此时此值是错误信息
    exit 1
fi
# echo "=======target_category_file_abspath=${target_category_file_abspath}"

tempMdFilePath=$(goPath_rel_project_dir_byKey ".project_path.other_path_rel_home.framework_category_md")
# tempMdFilePath="~/Downloads/temp_framework_category.md"
show_framework_category_md "${target_category_file_abspath}" "${tempMdFilePath}" # 罗列模块列表
