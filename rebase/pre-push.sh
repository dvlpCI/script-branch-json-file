#!/bin/sh
###
 # @Author: dvlproad
 # @Date: 2023-04-14 14:09:09
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-21 12:57:03
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

# 读取文件内容
content=$(cat "${TOOL_PARAMS_FILE_PATH}")
# 获取branchGit和branchJsonFile的值
branch_git_home=$(echo "$content" | jq -r '.branchGit.BRANCH_JSON_FILE_GIT_HOME')
if [[ $branch_git_home =~ ^~.* ]]; then
  # 如果 $branch_git_home 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
  branch_git_home="${HOME}${branch_git_home:1}"
fi
# branch_json_dir_path=$(echo "$content" | jq -r '.branchJsonFile.BRANCH_JSON_FILE_DIR_PATH')
# echo "branch_git_home: $branch_git_home"
# echo "branchJsonFile: $branch_json_dir_path"

cd "$branch_git_home" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。



PATH=$PATH:/usr/local/bin:/usr/local/sbin
git fetch --prune origin
git fetch --prune origin "+refs/tags/*:refs/tags/*"
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_CAN_PUSH=$(git branch --contains origin/develop |grep -w $GIT_BRANCH)
#echo $?

if [[ $? = 0 ]]; then
  rebaseSuccessMessage="恭喜，您的分支已rebase develop最新代码"
  printf "${GREEN}%s${NC}\n" "${rebaseSuccessMessage}"
  exit 0
fi
  rebaseErrorMessage="你的分支未rebase develop最新代码，请先rebase======"
  printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
  exit 1

