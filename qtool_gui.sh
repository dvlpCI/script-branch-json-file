#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2026-06-25
 # @FilePath: qtool_gui.sh
 # @Description: 构建多源 GUI App
 ###


CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qtool_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtool_HomeDir_Absolute=${CurrentDIR_Script_Absolute}

GUI_BUILD_SCRIPT="${qtool_HomeDir_Absolute}/gui/build.sh"
if [ ! -f "$GUI_BUILD_SCRIPT" ]; then
    echo "❌ 找不到 ${GUI_BUILD_SCRIPT}"
    exit 1
fi

GUI_ARGS=()
if [ -f "$QBASE_CUSTOM_MENU" ]; then
    GUI_ARGS+=(-jsonFile "$QBASE_CUSTOM_MENU" -categoryType custom -name "qbase")
fi
GUI_ARGS+=(-jsonFile "${qtool_HomeDir_Absolute}/qtool_menu_public.json" -categoryType catalog -name "qtool")

# echo "构建多源 GUI App:《 sh ${GUI_BUILD_SCRIPT} ${GUI_ARGS[*]} 》"
sh "${GUI_BUILD_SCRIPT}" "${GUI_ARGS[@]}"
