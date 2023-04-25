#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
# @LastEditors: dvlproad
# @LastEditTime: 2023-04-24 21:13:53
# @FilePath: qtool_menu.sh
# @Description: 工具选项
###

qtoolScriptDir_Absolute=$1
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    echo "请传参"
    exit 1
elif [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi
branchJsonFileScriptDir_Absolute=$qtoolScriptDir_Absolute/src

rebaseScriptDir_Absolute=$qtoolScriptDir_Absolute/rebase

jenkinsScriptDir_Absolute=$qtoolScriptDir_Absolute/jenkins
temp_reslut_file_path=${qtoolScriptDir_Absolute}/src/temp_result.json
chmod u+wr "${temp_reslut_file_path}" # chmod 命令用于修改文件权限，u 表示修改文件所有者的权限，+wr 表示添加读取和写入权限。

# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"
# echo "jenkinsScriptDir_Absolute=${jenkinsScriptDir_Absolute}"

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出

# 环境变量检查--TOOL_PARAMS_FILE_PATH（才能保证可以正确创建分支）
checkEnvValue_TOOL_PARAMS_FILE_PATH() {
    if [ "${#TOOL_DEAL_PROJECT_DIR_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【git项目路径】的环境变量，请open ~/.bash_profile 或 open ~/.zshrc后,将${BLUE}export TOOL_DEAL_PROJECT_DIR_PATH=your_project_dir ${RED}添加到环境变量中(其中${YELLOW}your_project_dir${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -f "${TOOL_DEAL_PROJECT_DIR_PATH}" ]; then
        printf "${RED}您设置的环境变量 TOOL_DEAL_PROJECT_DIR_PATH=${TOOL_DEAL_PROJECT_DIR_PATH} 目录不存在，请检查%s${NC}\n"
        return 1
    fi


    if [ "${#TOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【git项目路径】的环境变量，请open ~/.bash_profile 或 open ~/.zshrc后,将${BLUE}export TOOL_DEAL_PROJECT_PARAMS_FILE_PATH=yourToolParamsFileAbsolutePath ${RED}添加到环境变量中(其中${YELLOW}yourToolParamsFileAbsolutePath${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -f "${TOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" ]; then
        printf "${RED}您设置的环境变量 TOOL_DEAL_PROJECT_PARAMS_FILE_PATH=${TOOL_DEAL_PROJECT_PARAMS_FILE_PATH} 目录不存在，请检查%s${NC}\n"
        return 1
    fi

    
}

checkEnvValue_TOOL_PARAMS_FILE_PATH
if [ $? != 0 ]; then
    exit
fi

project_dir=$(cat "${TOOL_DEAL_PROJECT_DIR_PATH}")
if [[ $project_dir =~ ^~.* ]]; then
    # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    project_dir="${HOME}${project_dir:1}"
fi
cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。

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
        "4|rebaseCheck      将当前分支合并到其他分支前的rebase检查"
        "5|jenkins          Jenkins打包"
        # "6|onlyTest         我只是测试项..."
    )

    # 遍历数组并输出带颜色的文本
    for i in "${!options[@]}"; do
        if [ "$i" -eq 0 ]; then
            printf "${BLUE}%s\033[0m\n" "${options[$i]}"
        elif [ "$i" -gt 2 ] && [ "$i" -le 3 ]; then
            printf "${GREEN}%s\033[0m\n" "${options[$i]}"
        elif [ "$i" -gt 3 ] && [ "$i" -le 4 ]; then
            printf "${PURPLE}%s\033[0m\n" "${options[$i]}"
        else
            printf "${YELLOW}%s\033[0m\n" "${options[$i]}"
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
    checkResultCode $?
}

# 分支信息文件修改
updateBranchJsonFile() {
    python3 ${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py
    checkResultCode $?
}

# 将当前分支合并到其他分支前的rebase检查
rebaseCheckBranch() {
    sh ${rebaseScriptDir_Absolute}/pre-push.sh
    checkResultCode $?
}

# 二、执行Jenkins上的Job
buildJenkinsJob() {
    # echo "正在执行命令：《 sh ${jenkinsScriptDir_Absolute}/jenkins.sh \"${jenkinsScriptDir_Absolute}\" \"${temp_reslut_file_path}\" 》"
    sh ${jenkinsScriptDir_Absolute}/jenkins.sh "${jenkinsScriptDir_Absolute}" "${temp_reslut_file_path}"
    checkResultCode $?
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

checkResultCode() {
    resultCode=$1
    if [ $resultCode = 0 ]; then
        printf "恭喜💐:您选择%s操作已执行完成\n" "${options[$option - 1]}"
    else
        printf "很遗憾😭:您选择%s操作执行失败\n" "${options[$option - 1]}"
    fi
    valid_option=ture
}

# 读取用户输入的选项，并根据选项执行相应操作
valid_option=false
while [ "$valid_option" = false ]; do
    read -r -p "请选择您想要执行的操作编号或id(若要退出请输入Q|q) : " option
    case $option in
    1 | gitBranch) gitBranchAndJsonFile break ;;
    2 | createJsonFile) createBranchJsonFile break ;;
    3 | updateJsonFile) updateBranchJsonFile break ;;
    4 | rebaseCheck) rebaseCheckBranch break ;;
    5 | jenkins) buildJenkinsJob break ;;
    # 6 | onlyTest) valid_option=ture break ;;
    Q | q) exit 2 ;;
    *) valid_option=false echo "无此选项，请重新输入。" ;;
    esac
done

# 退出程序
exit 0
