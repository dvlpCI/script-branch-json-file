#!/bin/bash

project_dir=${QTOOL_DEAL_PROJECT_DIR_PATH}
if [[ $project_dir =~ ^~.* ]]; then
    # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    project_dir="${HOME}${project_dir:1}"
fi
cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。

flutter packages pub run build_runner build --delete-conflicting-outputs
if [ $? != 0 ]; then
    exit 1
fi