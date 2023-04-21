#!/bin/sh
###
 # @Author: dvlproad
 # @Date: 2023-04-14 14:09:09
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-21 10:47:07
 # @Description: 
### 

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
  #echo '已经合并develop最新代码'
  exit 0
fi
	echo '你的分支未rebase develop最新代码，请先rebase======'
exit 1

