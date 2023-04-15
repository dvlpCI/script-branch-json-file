#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-14 14:23:04
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 分支JSON文件的创建-shell
###

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
            printf "\033[34m%s\033[0m\n" "${options[$i]}"
        else
            printf "\033[34m%s\033[0m\n" "${options[$i]}"
        fi
    done
}

menu
read -r -p "①请选择您所要创建的分支类型(若要退出请输入Q|q) : " option
while [ "$option" != 'quit' ]; do
    case $option in
    1 | hotfix) branchType="hotfix" break ;;
    2 | feature) branchType="feature" break ;;
    3 | optimize) branchType="optimize" break ;;
    4 | other) branchType="other" break ;;
    Q | q) exit 2 ;;
    *) echo "无此选项..." ;;
    esac
    read -r -p "①请选择您所要创建的分支类型(若要退出请输入Q|q) : " option
done
printf "①已选择您所要创建的分支类型\033[31m%s\033[0m\n\n" "$branchType"

# 1.2、分支名输入
read -r -p "②请输入您的分支名(若要退出请输入Q|q) : " branchName
while [ "$branchName" != 'quit' ]; do
    case $option in
    Q | q) exit 2 ;;
    *)
        # echo "您输入的分支名为$branchName."
        # 使用正则表达式判断字符串以字母开头且不小于4位，同时内容只能为字母和_和其他数字
        if echo "$branchName" | grep -Eq '^[a-zA-Z][a-zA-Z0-9_]{3,}$'; then
            break
        else
            printf "字符串\033[31m%s\033[0m不符合要求，请重新输入(要求以字母开头，且不小于4位)\n\n" "$branchName"
        fi
        ;;
    esac
    read -r -p "②请输入您的分支名(若要退出请输入Q|q) : " branchName
done
newbranch=$branchType/$branchName

# 1.3、分支名确认
# read -p "是否确定创建 $newbranch. [继续y/退出n] : " continueNewbranch
printf "是否确定创建\033[31m%s\033[0m.[继续y/退出n] : " "$newbranch"
read -r continueNewbranch
if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
    echo "退出"
    exit 1
fi

# 2、创建分支
# 当前【shell脚本】的工作目录
# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
#echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#gitHomeDir_Absolute=${CurrentDIR_Script_Absolute}/..
# temp_Absolute2=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
# gitHomeDir_Absolute=${temp_Absolute2%/*}
gitHomeDir_Absolute=$(git rev-parse --show-toplevel) # 这个命令将输出Git项目的根目录的绝对路径。如果你当前在项目的子目录中，这个命令也会返回项目的根目录。前提本路径只属于主项目的git
echo "gitHomeDir_Absolute=${gitHomeDir_Absolute}"

echo "分支创建准备..."
# 1：需要切换到被拉取的分支，并且拉取项目，命令如下：
git checkout develop && git pull origin develop

# 2：接着创建一个新分支，并且切换到新的分支：
# 方法①一步到位，一步完成创建和切换
# git checkout -b newbranch
# 方法②也可以先创建，在切换：
git branch "$newbranch"
git checkout "$newbranch"

# 3：把本地分支push到远端：
# $git push origin $newbranch
# 4：拉取远端分支
# $git pull

# 4、添加分支信息
# echo "正在执行命令:《 python3 \"${CurrentDIR_Script_Absolute}/branchJsonFile_create.py\" 》"
python3 "${CurrentDIR_Script_Absolute}/branchJsonFile_create.py"
