#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-07-03 21:28:47
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-07-12 01:41:58
 # @Description: 
### 

# function get_this_HomeDir_abspath() {
#     # 当前【shell脚本】的工作目录
#     # $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
#     CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
#     #echo "CurrentDIR_Script_Absolute=${CurrentDIR_Script_Absolute}"
#     #bulidScriptCommon_dir_Absolute=${CurrentDIR_Script_Absolute}/..
#     bulidScriptApp_dir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
#     bulidScriptHome_dir_Absolute=${bulidScriptApp_dir_Absolute%/*}
# }

function getqbase_HomeDir_abspath_homebrew() {
    homebrew_Cellar_dir="$(echo $(which qbase) | sed 's/\/bin\/.*//')"
    if [ -z "${homebrew_Cellar_dir}" ]; then
        brew update # 执行下载
        if [ $? != 0 ]; then
            return 1
        fi
    fi
    
    qbase_homedir_abspath=$(qbase)
    echo "$qbase_homedir_abspath"
}

requstQScript=$1
if [ "${requstQScript}" == "qbase" ]; then
    getqbase_HomeDir_abspath_homebrew
fi