#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-23 15:34:49
# @FilePath: /Git-Commit-Standardization/Users/lichaoqian/Project/Bojue/branch_create.sh
# @Description: 工具选项
###

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出
versionCmdStrings=("--version" "-version" "-v" "version")

# cd "$BJProject_WISHHOME"

# gitHome() {
#     git_output=$(git rev-parse --show-toplevel)
#     gitHomeDir_Absolute=$(echo "$git_output" | tr -d '\n') # 删除输出中的换行符，以获取仓库根目录的绝对路径
#     # echo "Git 仓库根目录的绝对路径：$gitHomeDir_Absolute"
#     echo "gitHomeDir_Absolute=$gitHomeDir_Absolute"
# }

# # 当前【shell脚本】的工作目录
# # $PWD代表获取当前路径，当cd后，$PWD也会跟着更新到新的cd路径。这个和在终端操作是一样的道理的
# CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# #WORKSPACE_DIR_PATH=$CurrentDIR_Script_Absolute/..
# # WORKSPACE_DIR_PATH="${CurrentDIR_Script_Absolute%/*}" # 使用此方法可以避免路径上有..
# gitHome
# branchJsonFileScriptDir_Absolute=${gitHomeDir_Absolute}/bulidScript/branchJsonFileScript
# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"

# 工具选项
tool_menu() {
    # 定义菜单选项
    options=(
        "1|init     初始化"
        "2|update   更新"
        "3|more     更多操作"
    )

    # 遍历数组并输出带颜色的文本
    for i in "${!options[@]}"; do
        if [ "$i" -eq 0 ]; then
            printf "\033[34m%s\033[0m\n" "${options[$i]}"
        else
            printf "\033[33m%s\033[0m\n" "${options[$i]}"
        fi
    done
}

checkDirPath() {
    dirPath=$1
    # read -p "是否确定创建 $newbranch. [继续y/退出n] : " continueNewbranch
    printf "您当前的路径是\033[31m%s\033[0m，请确认是否正确.[继续y/退出n] : " "$dirPath"
    read -r continueDirPath
    if echo "${quitStrings[@]}" | grep -wq "${continueDirPath}" &>/dev/null; then
        return 1
    fi
}

# 添加环境变量
addEnvPathByProjectDir() {
    project_dir=$1
    addedEnvPath="${project_dir}/bulidScript/tool_input.json"

    SHELL_TYPE=$(basename $SHELL)

    if [ "$SHELL_TYPE" = "bash" ]; then
        # echo "Adding TOOL_PATH to .bash_profile"
        echo "# 添加工具" >>~/.bash_profile
        echo "export QTOOL_DEAL_PROJECT_DIR_PATH=${project_dir}" >>~/.bash_profile
        echo "export QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH=${addedEnvPath}" >>~/.bash_profile
        echo "export PATH=\${PATH}:\${QTOOL_DEAL_PROJECT_DIR_PATH}/bin" >>~/.bash_profile # 此行是为了使用tool，且${PATH} 前添加斜杠来转义，避免去取值了
        source ~/.bash_profile
        # open ~/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        # echo "Adding TOOL_PATH to .zshrc"
        echo "# 添加工具" >>~/.zshrc
        echo "export QTOOL_DEAL_PROJECT_DIR_PATH=${project_dir}" >>~/.zshrc
        echo "export QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH=${addedEnvPath}" >>~/.zshrc
        echo "export PATH=\${PATH}:\${QTOOL_DEAL_PROJECT_DIR_PATH}/bin" >>~/.zshrc # 此行是为了使用tool，且${PATH} 前添加斜杠来转义，避免去取值了
        source ~/.zshrc
        # open ~/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
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

# 调用安装软件包的函数，并传入要安装的软件包名称作为参数
# install_package "$1"

initTool() {
    project_dir="$(pwd)"
    printf "请先cd到项目目录:\n"
    checkDirPath "$project_dir"
    if [ $? != 0 ]; then
        exit 1
    fi

    addEnvPathByProjectDir "${project_dir}"
    if [ $? != 0 ]; then
        echo "❌Error:初始化失败，请检查"
        exit 1
    fi

    brew tap dvlpCI/tools
    if [ $? != 0 ]; then
        echo "❌Error:初始化终端，请重新执行"
        exit 1
    fi

    # brew install qtool
    install_package "qtool"
    if [ $? != 0 ]; then
        echo "❌Error:分支信息文件工具初始化失败，请重新执行"
        exit 1
    fi

    echo "✅恭喜:初始化成功"
}


updateTool() {
    brew update
    if [ $? != 0 ]; then
        echo "❌Error:更新终端，请重新执行"
        exit 1
    fi

    brew upgrade qtool
    if [ $? != 0 ]; then
        echo "❌Error:分支信息文件工具初始化失败，请重新执行"
        exit 1
    fi
}

chooseMenuOption() {
    # 显示工具选项
    tool_menu

    # 读取用户输入的选项，并根据选项执行相应操作
    read -r -p "请选择您想要执行的操作(若要退出请输入Q|q) : " option
    while [ "$option" != 'Q' ] && [ "$option" != 'q' ]; do
        case $option in
        1 | init) initTool break ;;
        2 | update) updateTool break ;;
        3 | more) qtool break ;;
        *) echo "无此选项..." ;;
        esac

        if [ $? = 0 ]; then
            printf "恭喜💐:您选择%s操作已执行完成\n" "${options[$option - 1]}"
        else
            printf "很遗憾😭:您选择%s操作执行失败\n" "${options[$option - 1]}"
        fi
        break
    done
}

checkRunEnv() {
    # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    if ! command -v brew &>/dev/null; then
        echo "Homebrew 未安装，正在安装...《 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" 》"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [ $? != 0 ]; then
            echo "Homebrew 安装失败，请检查！"
            return 1
        fi
    fi
}

effectiveEnvironmentVariables

# 检查运行环境
checkRunEnv
if [ $? != 0 ]; then
    echo "运行环境未完善，请检查后重新执行"
    exit 1
fi

if [ -z "$1" ]; then
    qtool
elif [ "$1" == "test" ]; then
    # 本地测试
    CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
    qtoolScriptDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
    sh ${qtoolScriptDir_Absolute}/qtool.sh test
elif [ "$1" == "init" ]; then
    initTool
elif [ "$1" == "update" ]; then
    updateTool
elif echo "${versionCmdStrings[@]}" | grep -wq "$1" &>/dev/null; then
    qtool --version
else
    chooseMenuOption
fi

# 退出程序
exit 0
