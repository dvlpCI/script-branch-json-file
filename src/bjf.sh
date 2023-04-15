#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-14 13:54:15
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 工具选项
###

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

cd "$BJProject_WISHHOME"

gitHome() {
    git_output=$(git rev-parse --show-toplevel)
    gitHomeDir_Absolute=$(echo "$git_output" | tr -d '\n') # 删除输出中的换行符，以获取仓库根目录的绝对路径
    # echo "Git 仓库根目录的绝对路径：$gitHomeDir_Absolute"
    echo "gitHomeDir_Absolute=$gitHomeDir_Absolute"
}

# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#WORKSPACE_DIR_PATH=$CurrentDIR_Script_Absolute/..
# WORKSPACE_DIR_PATH="${CurrentDIR_Script_Absolute%/*}" # 使用此方法可以避免路径上有..
gitHome
branchJsonFileScriptDir_Absolute=${gitHomeDir_Absolute}/bulidScript/branchJsonFileScript
# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"


# 工具选项
tool_menu() {
    # 定义菜单选项
    options=(
        "1|create    创建分支(含初始分支信息)"
        "2|update    更新分支信息(人员、提测时间、测试通过时间)"
    )


    # 遍历数组并输出带颜色的文本
    for i in "${!options[@]}"
    do
        if [ "$i" -eq 0 ]; then
        printf "\033[34m%s\033[0m\n" "${options[$i]}"
        else
        printf "\033[33m%s\033[0m\n" "${options[$i]}"
        fi
    done
}

# 显示工具选项
tool_menu

# 读取用户输入的选项，并根据选项执行相应操作
read -r -p "请选择您想要执行的操作(若要退出请输入Q|q) : " option
while [ "$option" != 'Q' ] && [ "$option" != 'q' ]; do
    case $option in
        1|create) sh ${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.sh ;;
        2|update) python3 ${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py ;;
        *) echo "无此选项..." ;;
    esac

    if [ $? = 0 ]; then
        printf "恭喜💐:您选择%s操作已执行完成\n" "${options[$option-1]}"
    else
        printf "很遗憾😭:您选择%s操作执行失败\n" "${options[$option-1]}"
    fi
    break
done

# 退出程序
exit 0