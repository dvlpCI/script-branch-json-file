#!/bin/bash
# wrapper: strip interactive menu, source functions, run specific action, wait for user to close

qtoolScriptDir_Absolute=$1
actionName=$2

if [ -z "$qtoolScriptDir_Absolute" ] || [ -z "$actionName" ]; then
    echo "用法: qtool_run_action.sh <脚本目录> <action名>"
    exit 1
fi

source "${qtoolScriptDir_Absolute}/qtool_menu_source.sh"

if ! declare -f "$actionName" > /dev/null 2>&1; then
    echo "❌ action '$actionName' 不存在"
    echo "" && read -p "按回车关闭此窗口..."
    exit 1
fi

# 执行选中的 action
eval "$actionName"
result=$?

echo ""
if [ $result -eq 0 ]; then
    echo "✅ 执行完成"
else
    echo "⚠️ 执行结束（退出码: $result）"
fi
echo "此窗口可关闭（Cmd+W）"
exit 0
