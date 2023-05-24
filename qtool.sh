#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-24 19:33:23
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

# 本地测试
local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute}
}


# 实际项目
bjfVersion=0.4.3

# 粗略计算，容易出现arm64芯片上的路径不对等问题
# qtoolScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"

# 精确计算
# which_qtool_bin_dir_path=$(which qtool)
# which_qtool_source_dir_path="$(echo "$which_qtool_bin_dir_path" | sed 's/bin/Cellar/')"
# echo "which_qtool_bin_dir_path: $which_qtool_bin_dir_path"
# echo "which_qtool_source_dir_path: $which_qtool_source_dir_path"
homebrew_Cellar_dir="$(echo $(which qtool) | sed 's/\/bin\/.*//')"
if [[ "${homebrew_Cellar_dir}" == */ ]]; then
    homebrew_Cellar_dir="${homebrew_Cellar_dir::-1}"
fi
homebrew_Cellar_dir=${homebrew_Cellar_dir}/Cellar

qtool_version_relpath="/qtool/${bjfVersion}/lib"
if [[ "${qtool_version_relpath}" == /?* ]]; then
    qtool_version_relpath="${qtool_version_relpath:1}"
fi
qtoolScriptDir_Absolute="${homebrew_Cellar_dir}/${qtool_version_relpath}"
# echo "qtoolScriptDir_Absolute: $qtoolScriptDir_Absolute"

if [ -n "$1" ] && [ "$1" == "test" ] ; then
    local_test # 本地测试
fi
# echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}"

# 检查运行环境
sh ${qtoolScriptDir_Absolute}/qtool_runenv.sh "${qtoolScriptDir_Absolute}"
if [ $? != 0 ]; then
    exit 1
fi

printf "${GREEN}温馨提示:您当前操作的项目为${YELLOW}%s${GREEN}\n(如果需要变更，请输入${YELLOW}change${GREEN})${NC}\n" "$QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH"

versionCmdStrings=("--version" "-version" "-v" "version")
if [ -z "$1" ] || [ "$1" == "test" ]; then
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}"
# elif [ "$1" == "change" ]; then
#     sh ${qtoolScriptDir_Absolute}/qtool_change.sh "${qtoolScriptDir_Absolute}"
elif echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${bjfVersion}"
else
    sh ${qtoolScriptDir_Absolute}/qtool_help.sh
fi
