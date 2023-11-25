#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-29 10:54:08
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

    target_file_abspath=$(getAbsPathByFileRelativePath "${target_branch_type_file_abspath}" "$rel_file_path_value")
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




# 1、确定分支名(分支类型选择+分支名输入)
# 1.1、分支类型选择
branch_type_menu() {
    content=$(cat "${target_branch_type_file_abspath}")

    branchBelongKey1="branch_categorys"
    branchBelongMaps1=$(echo "$content" | jq -r ".${branchBelongKey1}")
    if [ -z "${branchBelongMaps1}" ] || [ "${branchBelongMaps1}" == "null" ]; then
        rebaseErrorMessage="请先在 ${target_branch_type_file_abspath} 文件中设置 .${branchBelongKey1} "
        printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
        exit 1
    fi

    branchBelongMapCount=$(echo "$content" | jq ".${branchBelongKey1}" | jq ".|length")
    # echo "=============branchBelongMapCount=${branchBelongMapCount}"
    if [ ${branchBelongMapCount} -eq 0 ]; then
        echo "友情提醒💡💡💡：没有找到可选的分支类型"
        return 1
    fi

    happenError=false
    for ((i = 0; i < ${branchBelongMapCount}; i++)); do
        iBranchBelongMap=$(echo "$content" | jq ".${branchBelongKey1}" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        iBranchBelongName=$(echo "$iBranchBelongMap" | jq -r ".key")
        iBranchBelongDes=$(echo "$iBranchBelongMap" | jq -r ".des")
        if [ $? != 0 ]; then
            happenError=true
        fi
        iBranchOption="$((i + 1))|${iBranchBelongName}"
        printf "${BLUE}%-15s%s${NC}\n" "${iBranchOption}" "$iBranchBelongName(${iBranchBelongDes})" # 要拼接两个字符串，并在拼接的结果中，如果第一个字符串不够 15 位则自动补充空格到 15 位
    done
}

chooseBranchTypeMap() {
    tBranchBelongMap=$1

    branchType=$(echo "$tBranchBelongMap" | jq -r ".key")
    branchTypeCodeEnable=$(echo "$tBranchBelongMap" | jq -r ".codeEnable")
    tBranchBelongDes=$(echo "$tBranchBelongMap" | jq -r ".des")

    valid_option=true
}

function chooseBranchType() {
    branch_type_menu

    valid_option=false
    while [ "$valid_option" = false ]; do
        read -r -p "①请选择您所要创建的分支类型的编号(若要退出请输入Q|q) : " option
        if [ ${option} == "q" ] || [ ${option} == "Q" ]; then
            exit 2
        elif [ ${option} -le ${branchBelongMapCount} ]; then
            tBranchBelongMap=$(echo "$content" | jq ".${branchBelongKey1}" | jq -r ".[$((option - 1))]") # 添加 jq -r 的-r以去掉双引号
            chooseBranchTypeMap "${tBranchBelongMap}"
            break
        else
            valid_option=false echo "无此选项，请重新输入。"
        fi
    done
    printf "①已选择您所要创建的分支类型${RED}%s${NC}\n\n" "$branchType"
}
chooseBranchType


# 1.2.2、选择分支所属模块，并完善分支名
chooseAndCompleteBranchName() {
    # 无限循环，监听用户输入
    while true; do
        read -r -p "②请输入您的模块/基础选项(自定义请填0,退出请输入Q|q) : " module_option_input

        if echo "${quitStrings[@]}" | grep -wq "${module_option_input}" &>/dev/null; then
            echo "您已退出创建"
            exit 1
        fi

        if [ "${module_option_input}" == "0" ]; then
            read -r -p "②请输入您自定义的分支所属模块(退出请输入Q|q) : " module_option_input
            if echo "${quitStrings[@]}" | grep -wq "${module_option_input}" &>/dev/null; then
                echo "您已退出创建"
                exit 1
            else
                break
            fi
        fi

        # 遍历 key 列表，判断输入是否匹配
        match=false
        for key in "${moduleOptionKeys[@]}"; do
            if [ "$module_option_input" == "$key" ]; then
                match=true
                break
            fi
        done

        # 如果没有匹配的 key，则遍历 JSON 数据中的最里层的所有 key 和 value 并将其打印出来
        if [ "$match" == false ]; then
            printf "${RED}输入的${module_option_input}不匹配${NC}\n"
        else
            break
        fi
    done
}

# 1.2.3、分支名输入
perfectDevBranchName() {
    read -r -p "③请完善您的分支名(若要退出请输入Q|q) : ${module_option_input}_" branchName
    while [ "$branchName" != 'quit' ]; do
        case $branchName in
        Q | q) exit 2 ;;
        *)
            # echo "您输入的分支名为$branchName."
            # 使用正则表达式判断字符串以字母开头且不小于4位，同时内容只能为字母和_和其他数字
            if echo "$branchName" | grep -Eq '^[a-zA-Z][a-zA-Z0-9_.]{3,}$'; then
                break
            else
                printf "字符串${RED}%s${NC}不符合要求，请重新输入(要求以字母开头，且不小于4位，支持字数、数字、下划线、小数点)\n\n" "$branchName"
            fi
            ;;
        esac
        read -r -p "③请完善您的分支名(若要退出请输入Q|q) : ${module_option_input}_" branchName
    done
    newbranch=$branchType/${module_option_input}_$branchName
}
perfectVersionBranchName() {
    read -r -p "③请完善您的【版本分支名，参考 v1.2.4_0527 、 version_next 、 version_far 】(若要退出请输入Q|q) :" branchName
    while [ "$branchName" != 'quit' ]; do
        case $branchName in
        Q | q) exit 2 ;;
        *)
            # echo "您输入的分支名为$branchName."
            # 使用正则表达式判断字符串以字母开头且不小于4位，同时内容只能为字母和_和其他数字
            if echo "$branchName" | grep -Eq '^[a-zA-Z][a-zA-Z0-9_.]{3,}$'; then
                break
            else
                printf "字符串${RED}%s${NC}不符合要求，请重新输入(要求以字母开头，且不小于4位，支持字数、数字、下划线、小数点)\n\n" "$branchName"
            fi
            ;;
        esac
        read -r -p "③请完善您的【版本分支名，参考 v1.2.4_0527 、 version_next 、 version_far 】(若要退出请输入Q|q) :" branchName
    done
    newbranch=$branchType/$branchName
}

onlyInput=false #是否直接输入用户名，而没有选择操作了
if [ -n "${branchTypeCodeEnable}" ] && [ "${branchTypeCodeEnable}" == "false" ]; then
    onlyInput=true
fi

function show_and_get_framework_category_forBranchCreate() {
    now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    temp_file_abspath="${TempDir_Absolute}/${now_time}.json"
    
    show_framework_category_forBranchCreate "${target_category_file_abspath}" "${temp_file_abspath}" # 罗列模块列表
    moduleOptionKeys=($(cat ${temp_file_abspath}))
    rm -rf ${temp_file_abspath} # 删除文件temp_file_abspath
}

if [ "${onlyInput}" == true ]; then
    perfectVersionBranchName # 完善版本分支名
else
    # 1.2、分支模块选择
    # 1.2.1、分支模块列表
    show_and_get_framework_category_forBranchCreate

    chooseAndCompleteBranchName # 选择分支所属模块
    perfectDevBranchName        # 完善开发分支名
fi

# 1.3、分支名确认
# read -p "是否确定创建 $newbranch. [继续y/退出n] : " continueNewbranch
printf "是否确定创建${RED}%s${NC}.[继续y/退出n] : " "$newbranch"
read -r continueNewbranch
if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
    echo "您已退出创建"
    exit 1
fi

# echo "分支创建准备..."
# 1：需要切换到被拉取的分支，并且拉取项目，命令如下：
# 读取文件内容
content=$(cat "${target_branch_type_file_abspath}")
should_rebase_from_branch=$(echo "$content" | jq -r '.rebase.rebaseFrom')
# echo "should_rebase_from_branch=${should_rebase_from_branch}"
if [ -z "${should_rebase_from_branch}" ] || [ "${should_rebase_from_branch}" == "null" ]; then
    rebaseErrorMessage="请先在 ${target_branch_type_file_abspath} 文件中设置 .rebase.rebaseFrom "
    printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
    exit 1
fi
should_rebase_from_branch=${should_rebase_from_branch##*/} # 取最后的component

git checkout "${should_rebase_from_branch}" && git pull origin "${should_rebase_from_branch}"
if [ $? != 0 ]; then
    printf "%s" "${RED}分支${YELLOW}${newbranch}${RED}创建失败，请检查您是否是rebase自${BLUE} ${should_rebase_from_branch} ${RED}。如果不是请修改${BLUE} ${target_branch_type_file_abspath} ${RED}中的${BLUE} .rebase.rebaseFrom ${RED}字段的值。${NC}\n"
    exit 1
fi

# 2：接着创建一个新分支，并且切换到新的分支：
# 方法①一步到位，一步完成创建和切换
# git checkout -b newbranch
# 方法②也可以先创建，在切换：
git branch "$newbranch"
git checkout "$newbranch"
if [ $? != 0 ]; then
    printf "${RED}分支${YELLOW}%s${RED}创建失败，请检查${NC}\n" "$newbranch"
    exit 1
fi

# 3：把本地分支push到远端：
# $git push origin $newbranch
# 4：拉取远端分支
# $git pull

# # 是否继续
# printf "分支${RED}%s${NC}创建成功，是否继续创建分支信息文件.[继续y/退出n] : " "$newbranch"
# read -r continueNewbranch
# if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
#     echo "退出"
#     exit 200
# fi
