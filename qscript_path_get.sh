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

# Checks if the specified command is available
# If the command is not available, it will be installed
function check_command_onlybrewupdate() {
    local cmd=$1
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd command not found, installing..."
        echo "正在执行安装命令：《 brew tap dvlpCI/qbase & brew install qbase 》"
        brew update
        brew tap dvlpCI/qbase
        brew install qbase
    fi
}

# 生效环境变量
effectiveEnvironmentVariables() {
    SHELL_TYPE=$(basename $SHELL)

    if [ "$SHELL_TYPE" = "bash" ]; then
        source ~/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        source ~/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi
}


requstQScriptPackage=$1
requstQScriptPath=$2
if [ "${requstQScriptPackage}" == "qbase" ]; then
    check_command_onlybrewupdate "qbase"
    effectiveEnvironmentVariables
    echo $(qbase -path "${requstQScriptPath}")
fi
