#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-20 10:37:23
# @FilePath: common/install_package.sh
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


# Checks if the specified command is available
# If the command is not available, it will be installed
function check_command() {
    local cmd=$1
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd command not found, installing..."
        if [ "$cmd" == "realpath" ]; then
            cmd=coreutiles
        fi
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "正在执行安装命令：《 brew install $cmd 》"
            brew install $cmd
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [[ -n $(command -v apt-get) ]]; then
                sudo apt-get update
                sudo apt-get install -y $cmd
            elif [[ -n $(command -v yum) ]]; then
                sudo yum install -y $cmd
            elif [[ -n $(command -v dnf) ]]; then
                sudo dnf install -y $cmd
            else
                echo "Unable to install $cmd, please install it manually."
                exit 1
            fi
        else
            echo "Unsupported operating system, please install $cmd manually."
            exit 1
        fi
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