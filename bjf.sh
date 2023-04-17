#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-04-18 03:37:02
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 工具选项
###

bjfVersion=0.0.5

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出


# export BRANCH_JSON_FILE_GIT_HOME=~/Project/Bojue/mobile_flutter_wish/                     # 要操作的git
# export BRANCH_JSON_FILE_DIR_PATH=${BRANCH_JSON_FILE_GIT_HOME}/bulidScript/featureBrances  # jsonFile存放的位置

# 环境变量检查--BRANCH_JSON_FILE_GIT_HOME（才能保证可以正确创建分支）
checkEnvValue_BRANCH_JSON_FILE_GIT_HOME() {
    if [ "${#BRANCH_JSON_FILE_GIT_HOME}" -eq 0 ]; then
        printf "${RED}您还未设置【git项目路径】的环境变量，请open ~/.bash_profile 或 open ~/.zhsrc后,将${BLUE}export BRANCH_JSON_FILE_GIT_HOME=yourProjectAbsolutePath ${RED}添加到环境变量中(其中${YELLOW}yourProjectAbsolutePath${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -d "${BRANCH_JSON_FILE_GIT_HOME}" ]; then
        printf "${RED}您设置的环境变量BRANCH_JSON_FILE_GIT_HOME=${BRANCH_JSON_FILE_GIT_HOME}目录不存在，请检查%s${NC}\n"
        return 1
    fi
}

checkEnvValue_BRANCH_JSON_FILE_GIT_HOME
if [ $? != 0 ]; then
    exit
fi

# 环境变量检查--BRANCH_JSON_FILE_DIR_PATH（才能保证可以分支信息存放的位置）
checkEnvValue_BRANCH_JSON_FILE_DIR_PATH() {
    if [ "${#BRANCH_JSON_FILE_DIR_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【git项目里json文件路径】的环境变量，请open ~/.bash_profile 或 open ~/.zhsrc后,将${BLUE}export BRANCH_JSON_FILE_DIR_PATH=yourProjectBranchJsonFileAbsoluteDir ${RED}添加到环境变量中(其中${YELLOW}yourProjectBranchJsonFileAbsoluteDir${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -d "${BRANCH_JSON_FILE_GIT_HOME}" ]; then
        printf "${RED}您设置的环境变量BRANCH_JSON_FILE_GIT_HOME=${BRANCH_JSON_FILE_GIT_HOME}目录不存在，请检查%s${NC}\n"
        return 1
    fi
}

checkEnvValue_BRANCH_JSON_FILE_DIR_PATH
if [ $? != 0 ]; then
    exit
fi


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
branchJsonFileScriptDir_Absolute=${CurrentDIR_Script_Absolute}/src
# branchJsonFileScriptDir_Absolute="/usr/local/Cellar/bjf/${bjfVersion}/lib/src"
# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"



cd "$BRANCH_JSON_FILE_GIT_HOME" # 切换到工作目录后，才能争取创建git分支

gitHome() {
    git_output=$(git rev-parse --show-toplevel)
    gitHomeDir_Absolute=$(echo "$git_output" | tr -d '\n') # 删除输出中的换行符，以获取仓库根目录的绝对路径
    # echo "Git 仓库根目录的绝对路径：$gitHomeDir_Absolute"
    echo "gitHomeDir_Absolute=$gitHomeDir_Absolute"
}
# gitHome



# 工具选项
tool_menu() {
    # 定义菜单选项
    options=(
        "1|gitBranch        创建分支(且创建完可选择继续2操作)"
        "2|createJsonFile   创建当前所处分支的信息文件"
        "3|updateJsonFile   更新当前所处分支的信息文件(人员、提测时间、提测时间、测试通过时间)"
        "4|jenkins          Jenkins打包"
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


_gitBranch() {
    sh ${branchJsonFileScriptDir_Absolute}/branchGit_create.sh
}


# 分支信息文件添加
createBranchJsonFile() {
    # echo "正在执行命令:《 python3 \"${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py\" 》"
    python3 "${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py"

}

# 分支信息文件修改
updateBranchJsonFile() {
    python3 ${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py
}

# 二、执行Jenkins上的Job
buildJenkinsJob() {
    echo "正在执行命令：《 sh ${branchJsonFileScriptDir_Absolute}/jenkins.sh \"${branchJsonFileScriptDir_Absolute}\" 》"
    sh ${branchJsonFileScriptDir_Absolute}/jenkins.sh "${branchJsonFileScriptDir_Absolute}"
}

gitBranchAndJsonFile() {
    _gitBranch
    if [ $? != 0 ]; then
        exit 1
    fi

    # 是否继续
    newbranch=""
    printf "分支${RED}%s${NC}创建成功，是否继续创建分支信息文件.[继续y/退出n] : " "$newbranch"
    read -r continueNewbranch
    if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
        echo "恭喜Git分支创建成功！"
        exit 0
    fi

    createBranchJsonFile
}

# 读取用户输入的选项，并根据选项执行相应操作
read -r -p "请选择您想要执行的操作(若要退出请输入Q|q) : " option
while [ "$option" != 'Q' ] && [ "$option" != 'q' ]; do
    case $option in
        1|gitBranch) gitBranchAndJsonFile ;;
        2|createJsonFile) createBranchJsonFile ;;
        3|updateJsonFile) updateBranchJsonFile ;;
        4|jenkins) buildJenkinsJob ;;
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