#!/bin/bash

# 本地测试
# CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
# qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute}

# 实际项目
bjfVersion=0.1.3
qtoolScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"

# echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}"

versionCmdStrings=("--version" "-version" "-v")

if [ -z "$1" ]; then
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}"
elif echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${bjfVersion}"
else
    sh ${qtoolScriptDir_Absolute}/qtool_help.sh
fi

