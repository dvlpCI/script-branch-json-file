#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-18 17:31:08
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 工具选项
###


# 本地测试
# CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
# branchJsonFileScriptDir_Absolute=${CurrentDIR_Script_Absolute}/src

# 实际项目
bjfVersion=0.0.5
branchJsonFileScriptDir_Absolute="/usr/local/Cellar/bjf/${bjfVersion}/lib/src"

# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"



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
    if [ "${#TOOL_PARAMS_FILE_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【git项目路径】的环境变量，请open ~/.bash_profile 或 open ~/.zhsrc后,将${BLUE}export TOOL_PARAMS_FILE_PATH=yourToolParamsFileAbsolutePath ${RED}添加到环境变量中(其中${YELLOW}yourToolParamsFileAbsolutePath${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -f "${TOOL_PARAMS_FILE_PATH}" ]; then
        printf "${RED}您设置的环境变量TOOL_PARAMS_FILE_PATH=${TOOL_PARAMS_FILE_PATH}目录不存在，请检查%s${NC}\n"
        return 1
    fi
}

checkEnvValue_TOOL_PARAMS_FILE_PATH
if [ $? != 0 ]; then
    exit
fi





# 读取文件内容
content=$(cat TOOL_PARAMS_FILE_PATH)

# 获取branchGit和branchJsonFile的值
branch_git_home=$(echo "$content" | jq -r '.branchGit.BRANCH_JSON_FILE_GIT_HOME')
# branch_json_dir_path=$(echo "$content" | jq -r '.branchJsonFile.BRANCH_JSON_FILE_DIR_PATH')
# echo "branchGit: $branch_git_home"
# echo "branchJsonFile: $branch_json_dir_path"

cd "$branch_git_home" # 切换到工作目录后，才能争取创建git分支

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
        "4|lastBranchJsons_removeJsonByName   从上次打包的分支信息里根据指定分支名删除json"
        "5|jenkins          Jenkins打包"
    )


    # 遍历数组并输出带颜色的文本
    for i in "${!options[@]}"
    do
        if [ "$i" -eq 0 ]; then
        printf "${BLUE}%s\033[0m\n" "${options[$i]}"
        elif [ "$i" -gt 3 ]; then
        printf "${GREEN}%s\033[0m\n" "${options[$i]}"
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

lastBranchJsonFile_update() {
    python3 ${branchJsonFileScriptDir_Absolute}/lastBranchJsonFile_update.py
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
read -r -p "请选择您想要执行的操作编号或id(若要退出请输入Q|q) : " option
while [ "$option" != 'Q' ] && [ "$option" != 'q' ]; do
    case $option in
        1|gitBranch) gitBranchAndJsonFile ;;
        2|createJsonFile) createBranchJsonFile ;;
        3|updateJsonFile) updateBranchJsonFile ;;
        4|lastBranchJsons_removeJsonByName) lastBranchJsonFile_update;;
        5|jenkins) buildJenkinsJob ;;
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