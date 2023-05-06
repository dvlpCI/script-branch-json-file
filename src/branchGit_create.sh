#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-06 15:38:09
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 分支JSON的创建-shell
###

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

# 1、确定分支名(分支类型选择+分支名输入)
# 1.1、分支类型选择
menu() {
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    branchBelongKey1="branch_belong1"
    branchBelongMaps1=$(echo "$content" | jq -r ".${branchBelongKey1}")
    if [ -z "${branchBelongMaps1}" ] || [ "${branchBelongMaps1}" == "null" ]; then
        rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 .${branchBelongKey1} "
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

menu
valid_option=false
while [ "$valid_option" = false ]; do
    read -r -p "①请选择您所要创建的分支类型的编号(若要退出请输入Q|q) : " option
    if [ ${option} == "q" ] || [ ${option} == "Q" ]; then
        exit 2
    elif [ ${option} -le ${branchBelongMapCount} ]; then
        tBranchBelongMap=$(echo "$content" | jq ".${branchBelongKey1}" | jq -r ".[$((option - 1))]") # 添加 jq -r 的-r以去掉双引号
        tBranchBelongName=$(echo "$tBranchBelongMap" | jq -r ".key")
        tBranchBelongDes=$(echo "$tBranchBelongMap" | jq -r ".des")
        chooseBranchType "${tBranchBelongName}"
        break
    else
        valid_option=false echo "无此选项，请重新输入。"
    fi
done
printf "①已选择您所要创建的分支类型${RED}%s${NC}\n\n" "$branchType"

# 1.2、分支名输入
read -r -p "②请输入您的分支名(若要退出请输入Q|q) : " branchName
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
    read -r -p "②请输入您的分支名(若要退出请输入Q|q) : " branchName
done
newbranch=$branchType/$branchName

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
content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
should_rebase_from_branch=$(echo "$content" | jq -r '.rebase.rebaseFrom')
# echo "should_rebase_from_branch=${should_rebase_from_branch}"
if [ -z "${should_rebase_from_branch}" ] || [ "${should_rebase_from_branch}" == "null" ]; then
    rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 .rebase.rebaseFrom "
    printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
    exit 1
fi
should_rebase_from_branch=${should_rebase_from_branch##*/} # 取最后的component

git checkout "${should_rebase_from_branch}" && git pull origin "${should_rebase_from_branch}"
if [ $? != 0 ]; then
    printf "${RED}分支${YELLOW}%s${RED}创建失败，请检查${NC}\n" "$newbranch"
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
