#!/bin/sh
###
 # @Author: dvlproad
 # @Date: 2023-04-14 14:09:09
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-06 12:50:10
 # @Description: 
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

git gc --prune=now # 启动 Git 的垃圾回收机制，清理不可达的松散对象。--prune=now 参数告诉 Git 立即清理这些对象。

# 判断当前目录是否为 Git 仓库
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "当前目录不是 Git 仓库"
    exit 1
fi

# 获取当前分支名称
currentBranch=$(git rev-parse --abbrev-ref HEAD)
# echo "当前分支为 $currentBranch"


# $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
CommonFun_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtoolScriptDir_Absolute=${CommonFun_HomeDir_Absolute}
if [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "==========qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi


source ${qtoolScriptDir_Absolute}/base/get_system_env.sh
project_dir=$(get_sysenv_project_dir)
cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。


# 读取文件内容
content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
should_rebase_from_branch=$(echo "$content" | jq -r '.rebase.rebaseFrom')
# echo "should_rebase_from_branch=${should_rebase_from_branch}"
if [ -z "${should_rebase_from_branch}" ] || [ "${should_rebase_from_branch}" == "null" ]; then
  rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 .rebase.rebaseFrom "
  printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
  exit 1
fi

PATH=$PATH:/usr/local/bin:/usr/local/sbin
git fetch --prune origin
git fetch --prune origin "+refs/tags/*:refs/tags/*"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# GIT_CAN_PUSH=$(git branch --contains origin/develop |grep -w $GIT_BRANCH)
GIT_CAN_PUSH=$(git branch --contains ${should_rebase_from_branch} |grep -w $GIT_BRANCH)
#echo $?

if [[ $? = 0 ]]; then
  rebaseSuccessMessage="恭喜，您的${currentBranch}分支已rebase ${should_rebase_from_branch} 最新代码"
  printf "${GREEN}%s${NC}\n" "${rebaseSuccessMessage}"
  exit 0
fi
  rebaseErrorMessage="抱歉，您的${currentBranch}分支未rebase ${should_rebase_from_branch} 最新代码，请先rebase======"
  printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
  exit 1

