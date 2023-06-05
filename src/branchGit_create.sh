#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-05 10:42:10
# @FilePath: src/branchGit_create.sh
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
branch_type_menu() {
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    branchBelongKey1="branch_categorys"
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

chooseBranchTypeMap() {
    tBranchBelongMap=$1

    branchType=$(echo "$tBranchBelongMap" | jq -r ".key")
    branchTypeCodeEnable=$(echo "$tBranchBelongMap" | jq -r ".codeEnable")
    tBranchBelongDes=$(echo "$tBranchBelongMap" | jq -r ".des")

    valid_option=true
}

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

# 1.2、分支模块选择
# 1.2.1、分支模块列表
menu_module() {
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    branchBelongKey2="branch_belong2"
    branchBelongMaps2=$(echo "$content" | jq -r ".${branchBelongKey2}")
    if [ -z "${branchBelongMaps2}" ] || [ "${branchBelongMaps2}" == "null" ]; then
        rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 .${branchBelongKey2} "
        printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
        exit 1
    fi

    # branchBelongMapCount2=$(echo "$content" | jq ".${branchBelongKey2}" | jq ".|length")
    # # echo "=============branchBelongMapCount2=${branchBelongMapCount2}"
    # if [ ${branchBelongMapCount2} -eq 0 ]; then
    #     echo "友情提醒💡💡💡：没有找到可选的分支模块类型"
    #     return 1
    # fi
    echo "已知模块选项、已知基础选项："
    echo "$content" | jq -r '.branch_belong2.strong_business, .branch_belong2.service, .branch_belong2.package, .branch_belong2.other | to_entries[] | "\(.key): \(.value)"'
    # 从 JSON 数据中获取 key 列表
    moduleOptionKeys=($(echo "$content" | jq -r '.branch_belong2.strong_business, .branch_belong2.service, .branch_belong2.package, .branch_belong2.other | keys[]'))
}
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

if [ "${onlyInput}" == true ]; then
    perfectVersionBranchName   # 完善版本分支名
else
    menu_module # 罗列模块列表
    chooseAndCompleteBranchName # 选择分支所属模块
    perfectDevBranchName   # 完善开发分支名
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
