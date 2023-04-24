#!/bin/bash

# 本地测试
local_test() {
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute}
}


# 实际项目
bjfVersion=0.1.9
qtoolScriptDir_Absolute="/usr/local/Cellar/qtool/${bjfVersion}/lib"
# local_test # 本地测试
# echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}"



# 检查运行环境
sh ${qtoolScriptDir_Absolute}/qtool_runenv.sh
if [ $? != 0 ]; then
    exit 1
fi



versionCmdStrings=("--version" "-version" "-v")
if [ -z "$1" ]; then
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}"
elif echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    echo "${bjfVersion}"
else
    sh ${qtoolScriptDir_Absolute}/qtool_help.sh
fi

