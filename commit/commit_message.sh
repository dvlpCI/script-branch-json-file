#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-05 13:39:39
# @FilePath: commit/commit_message.sh
# @Description: 分支JSON的创建-shell
###


# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 获取操作的项目路径（即为哪个项目提交git记录）
source ${qtoolScriptDir_Absolute}/base/get_system_env.sh
project_dir=$(get_sysenv_project_dir)


# 1、branchJsonName_input 分支json文件名的输入
quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出

# 1、确定分支名(分支类型选择+分支名输入)
# 1.1、分支类型选择
branch_type_menu() {
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    branchBelongKey1="commit_belong"
    branchBelongMaps1=$(echo "$content" | jq -r ".${branchBelongKey1}")
    if [ -z "${branchBelongMaps1}" ] || [ "${branchBelongMaps1}" == "null" ]; then
        rebaseErrorMessage="您正在为 ${project_dir} 项目操作分支，但未找到可选的操作类型，请先在 ${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH} 文件中设置 .${branchBelongKey1} "
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

chooseBranchType() {
    branchType=$1
    valid_option=true
}

branch_type_menu
valid_option=false
while [ "$valid_option" = false ]; do
    read -r -p "①请选择您改动的类型的编号(若要退出请输入Q|q) : " option
    if [ ${option} == "q" ] || [ ${option} == "Q" ]; then
        exit 2
    elif [[ "$option" =~ ^[0-9]+$ ]]; then
        # 输入的是数字
        if [ ${option} -gt 0 ] && [ ${option} -le ${branchBelongMapCount} ]; then
            tBranchBelongMap=$(echo "$content" | jq ".${branchBelongKey1}" | jq -r ".[$((option - 1))]") # 添加 jq -r 的-r以去掉双引号
            tBranchBelongName=$(echo "$tBranchBelongMap" | jq -r ".key")
            tBranchBelongDes=$(echo "$tBranchBelongMap" | jq -r ".des")
            chooseBranchType "${tBranchBelongName}"
            break
        else
            valid_option=false echo "无此选项，请重新输入。"
        fi
    else
        valid_option=false echo "无此选项，请重新输入。"
    fi
done
# 将第一个字母大写
first_letter=$(echo "${branchType:0:1}" | tr '[:lower:]' '[:upper:]')
rest_letters="${branchType:1}"
branchTypeUpperFirst="$first_letter$rest_letters"
printf "①已选择您改动的类型类型${RED}%s${NC}\n\n" "$branchTypeUpperFirst"




# 1.2、分支改动范围参考及输入
menu_module() {
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    branchBelongKey2="branch_belong2"
    branchBelongMaps2=$(echo "$content" | jq -r ".${branchBelongKey2}")
    if [ -z "${branchBelongMaps2}" ] || [ "${branchBelongMaps2}" == "null" ]; then
        rebaseErrorMessage="您正在为 ${project_dir} 项目操作分支，但未找到可选的分支模块类型，请先在 ${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH} 文件中设置 .${branchBelongKey2} （可以考虑接在 commit_belong 字段后）"
        printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
        exit 1
    fi

    # branchBelongMapCount2=$(echo "$content" | jq ".${branchBelongKey2}" | jq ".|length")
    # # echo "=============branchBelongMapCount2=${branchBelongMapCount2}"
    # if [ ${branchBelongMapCount2} -eq 0 ]; then
    #     echo "友情提醒💡💡💡：没有找到可选的分支模块类型"
    #     return 1
    # fi
    echo "参考的范围(见中文)："
    echo "$content" | jq -r '.branch_belong2.strong_business, .branch_belong2.service, .branch_belong2.package, .branch_belong2.other | to_entries[] | "\(.key): \(.value)"'
    # 从 JSON 数据中获取 key 列表
    moduleOptionKeys=($(echo "$content" | jq -r '.branch_belong2.strong_business, .branch_belong2.service, .branch_belong2.package, .branch_belong2.other | keys[]'))
}
menu_module



# 无限循环，监听用户输入
while true; do
    read -r -p "②请输入您改动的影响范围，以上中文是一些参考(若要退出请输入Q|q，若要跳过范围输入回车) : 【${branchTypeUpperFirst}】" scope_input

    if echo "${quitStrings[@]}" | grep -wq "${scope_input}" &>/dev/null; then
        echo "您已退出创建"
        exit 1
    fi

    break
done
if [ -n "$scope_input" ]; then
    printf "②已输入的改动范围${BLUE}%s${NC}\n" "$scope_input"
fi

# 1.3、分支名输入
if [ -n "$scope_input" ]; then
    read -r -p "③请完善您的改动信息(若要退出请输入Q|q) : 【${branchTypeUpperFirst}】（${scope_input}）" change_log_input
else
    read -r -p "③请完善您的改动信息(若要退出请输入Q|q) : 【${branchTypeUpperFirst}】" change_log_input
fi
while [ "$change_log_input" != 'quit' ]; do
    case $change_log_input in
    Q | q) exit 2 ;;
    *)
        # echo "您输入的改动信息为$change_log_input."
        # 使用正则表达式判断字符串不小于3位
        if echo "${change_log_input}" | grep -Eq '.{3,}$'; then
            break
        else
            printf "字符串${RED}%s${NC}不符合要求，请重新输入(要求不小于3位)\n\n" "${change_log_input}"
        fi
        ;;
    esac
    if [ -n "$scope_input" ]; then
        read -r -p "③请完善您的改动信息(若要退出请输入Q|q) : 【${branchTypeUpperFirst}】（${scope_input}）" change_log_input
    else
        read -r -p "③请完善您的改动信息(若要退出请输入Q|q) : 【${branchTypeUpperFirst}】" change_log_input
    fi
done
if [ -n "$scope_input" ]; then
    commitMsg="【${branchTypeUpperFirst}】（${scope_input}）${change_log_input}"
else
    commitMsg="【${branchTypeUpperFirst}】${change_log_input}"
fi

# 1.3、分支名确认
while true; do
    printf "是否以${YELLOW}%s${NC}提交commit.[继续y/退出q] : " "$commitMsg"
    read -r continueNewbranch
    if [[ "$continueNewbranch" == [qQ] ]]; then
        echo "您已退出提交"
        exit 1
    elif [[ "$continueNewbranch" == [yY] ]]; then
        break
    fi
done


echo "分支信息提交准备..."
# 1：需要切换到被拉取的分支，并且拉取项目，命令如下：
# 判断当前目录是否为 Git 仓库
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "当前目录不是 Git 仓库"
    exit 1
fi

# 获取当前分支名称
currentBranch=$(git rev-parse --abbrev-ref HEAD)
echo "当前分支为 $currentBranch"

git pull --rebase

git add -A . # git add -A表示添加所有内容， git add . 表示添加新文件和编辑过的文件不包括删除的文件; git add -u 表示添加编辑或者删除的文件，不包括新添加的文件

git commit -m "${commitMsg}"
printf "${GREEN}分支信息${BLUE}%s已提交到本地${NC}\n" "$commitMsg"

sh $qtoolScriptDir_Absolute/rebase/pre-push.sh
if [ $? != 0 ]; then
    exit 1
fi

while true; do
    printf "请继续选择将${BLUE}%s${NC}推动到远程的方式${YELLOW}(1默认push、2强推push、3手动push)${NC}提交commit.(若要退出请输入Q|q): " "$commitMsg"
    read -r pushOption
    if [[ "$pushOption" == [qQ] ]]; then
        echo "您已退出提交，可继续手动push"
        exit 1
    elif [[ "$pushOption" == [1] ]]; then
        git push #origin ${currentBranch} # 一般使用：git push origin master
        break
     elif [[ "$pushOption" == [2] ]]; then
        printf "${RED}强推是个很危险的操作，使用前请再三确认。请问你还继续强推吗${NC}.[继续强推y/其他任意字符将重新选择]: "
        read -r shouldForcePushOption
        if [[ "$shouldForcePushOption" == [yY] ]]; then
            echo "您将执意执行强制提交，请在命令结束后检查，避免出错"
            git push -f #origin ${currentBranch} # 一般使用：git push origin master
            break
        else
            echo "您将放弃执行强制提交，请重新选择"
            continue
        fi
    elif [[ "$pushOption" == [3] ]]; then
        echo "您已退出push，请继续手动push"
        exit 1
    else
        printf "${RED}输入不正确，请重新选择push方式${NC}\n"
    fi
done

# 
# # 读取文件内容
# content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
# should_rebase_from_branch=$(echo "$content" | jq -r '.rebase.rebaseFrom')
# # echo "should_rebase_from_branch=${should_rebase_from_branch}"
# if [ -z "${should_rebase_from_branch}" ] || [ "${should_rebase_from_branch}" == "null" ]; then
#     rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 .rebase.rebaseFrom "
#     printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
#     exit 1
# fi
# should_rebase_from_branch=${should_rebase_from_branch##*/} # 取最后的component

# git checkout "${should_rebase_from_branch}" && git pull origin "${should_rebase_from_branch}"
# if [ $? != 0 ]; then
#     printf "${RED}分支${YELLOW}%s${RED}创建失败，请检查${NC}\n" "$newbranch"
#     exit 1
# fi

# # 2：接着创建一个新分支，并且切换到新的分支：
# # 方法①一步到位，一步完成创建和切换
# # git checkout -b newbranch
# # 方法②也可以先创建，在切换：
# git branch "$newbranch"
# git checkout "$newbranch"
# if [ $? != 0 ]; then
#     printf "${RED}分支${YELLOW}%s${RED}创建失败，请检查${NC}\n" "$newbranch"
#     exit 1
# fi

# # 3：把本地分支push到远端：
# # $git push origin $newbranch
# # 4：拉取远端分支
# # $git pull

# # # 是否继续
# # printf "分支${RED}%s${NC}创建成功，是否继续创建分支信息文件.[继续y/退出n] : " "$newbranch"
# # read -r continueNewbranch
# # if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
# #     echo "退出"
# #     exit 200
# # fi
