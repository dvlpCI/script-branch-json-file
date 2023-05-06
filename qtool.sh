#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-06 19:04:34
 # @Description: 
### 

# 本地测试
local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute}
}

# 实际项目
bjfVersion=0.3.0

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

versionCmdStrings=("--version" "-version" "-v")
if [ -z "$1" ] || [ "$1" == "test" ]; then
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}"
elif echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${bjfVersion}"
else
    sh ${qtoolScriptDir_Absolute}/qtool_help.sh
fi
