#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-21 13:07:50
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
    # echo "请选择您所要创建的分支类型(若要退出请输入Q|q):"
    #     cat <<EOF
    #     1|hotfix    hotfix(线上修复)
    #     2|feature   feature(产品需求)
    #     3|optimize  optimize(技术优化)
    #     4|other     other(其他)
    # EOF

    # 定义菜单选项
    options=(
        "1|hotfix    hotfix(线上修复)"
        "2|feature   feature(产品需求)"
        "3|optimize  optimize(技术优化)"
        "4|other     other(其他)"
    )

    # 遍历数组并输出带颜色的文本
    for i in "${!options[@]}"; do
        if [ "$i" -eq 0 ]; then
            printf "${BLUE}%s${NC}\n" "${options[$i]}"
        else
            printf "${BLUE}%s${NC}\n" "${options[$i]}"
        fi
    done
}

chooseBranchType() {
    branchType=$1
    valid_option=true
}

menu
valid_option=false
while [ "$valid_option" = false ]; do
    read -r -p "①请选择您所要创建的分支类型(若要退出请输入Q|q) : " option
    case $option in
    1 | hotfix) chooseBranchType "hotfix" break ;;
    2 | feature) chooseBranchType "feature" break ;;
    3 | optimize) chooseBranchType "optimize" break ;;
    4 | other) chooseBranchType "other" break ;;
    Q | q) exit 2 ;;
    *) valid_option=false echo "无此选项，请重新输入。" ;;
    esac
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

# 2、创建分支
# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
branchJsonFileScriptDir_Absolute=${CurrentDIR_Script_Absolute}
echo "branchJsonFileScriptDir_Absolute222=${branchJsonFileScriptDir_Absolute}"


# echo "分支创建准备..."
# 1：需要切换到被拉取的分支，并且拉取项目，命令如下：
# 读取文件内容
content=$(cat "${TOOL_PARAMS_FILE_PATH}")
should_rebase_from_branch=$(echo "$content" | jq -r '.rebase.rebaseFrom')
# echo "should_rebase_from_branch=${should_rebase_from_branch}"
if [ -z "${should_rebase_from_branch}" ] || [ "${should_rebase_from_branch}" == "null" ]; then
  rebaseErrorMessage="请先在${TOOL_PARAMS_FILE_PATH}文件中设置 .rebase.rebaseFrom "
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
