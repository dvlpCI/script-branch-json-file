#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-24 18:19:28
# @FilePath: qtool_menu.sh
# @Description: 检查安装环境
###

checkRunEnvironment() {
    if ! command -v jq &> /dev/null; then
        echo "jq 工具未安装，正在安装..."
        if [[ "$(uname -s)" == "Darwin" ]]; then
            brew install jq # Mac系统
        elif [[ "$(uname -s)" == "Linux" ]]; then
            if [[ "$(uname -m)" == "x86_64" ]]; then
                wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
            else
                wget -O /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux32
            fi
            chmod +x /usr/local/bin/jq
        else
            echo "不支持的操作系统"
            exit 1
        fi
    fi

    echo "jq 工具已安装"
}


checkRunEnvironment