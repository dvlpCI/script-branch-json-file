#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-25 14:00:58
# @FilePath: qtool_menu.sh
# @Description: 检查安装环境
###

# 定义安装软件包的函数
install_package() {
    # 判断系统类型
    if [[ "$(uname -s)" == "Darwin" ]]; then
        # 判断 CPU 架构
        if [[ "$(uname -m)" == "arm64" ]]; then
            arch -arm64 brew install $1
        else
            # arch -x86_64 brew install $1
            brew install $1
        fi
    else
        # 输出错误信息
        echo "Unsupported platform: $(uname -s)"
        exit 1
    fi
}

checkPackageInstallState() {
    if ! command -v $1 &> /dev/null; then
        echo "$1 工具未安装，正在安装..."
        install_package "$1"
    fi

    # echo "$1 工具已安装"
}


checkPackageInstallState $1