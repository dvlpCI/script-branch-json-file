#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
### 

qtoolScriptDir_Absolute=$1
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    echo "请传参 qtoolScriptDir_Absolute"
    exit 1
elif [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了引入 open_sysenv_file getAbsPathByFileRelativePath 方法

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

# 更新tool处理的项目
showProjectList() {
    tool_choice_file_path=$1

    #
    printf "支持的项目列表： (详见: ${YELLOW}${tool_choice_file_path}${NC})\n"
    choiceCount=$(cat "$tool_choice_file_path" | jq '.choice|length')
    for ((i = 0; i < ${choiceCount}; i++)); do
        iChoiceMap=$(cat "$tool_choice_file_path" | jq ".choice" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号

        iChoiceOptionId="$((i + 1))"
        iChoiceName=$(echo "$iChoiceMap" | jq -r ".name")

        
        iChoiceProjectToolFilePath=$(echo "$iChoiceMap" | jq -r ".project_tool_file_path")
        iChoiceProjectDirPath_rel_toolFile_dir=$(cat "${iChoiceProjectToolFilePath}" | jq -r ".project_path.home_path_rel_this_dir")
        iChoiceProjectDirPath=$(getAbsPathByFileRelativePath "${iChoiceProjectToolFilePath}" "${iChoiceProjectDirPath_rel_toolFile_dir}")
        
        # echo "正在执行命令:《echo \"$iChoiceMap\" | jq -r \".name\"》"

        printf "${GREEN}%-2s%-20s(路径为 ${YELLOW}%s)${NC}\n" "${iChoiceOptionId}" "${iChoiceName}" "${iChoiceProjectDirPath}"
    done
}

updateToolDealProject() {
    tool_choice_file_path=$1

    # 读取用户输入的选项，并根据选项执行相应操作
    valid_option=false
    while [ "$valid_option" = false ]; do
        if [ -z "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" ]; then
            read -r -p "您还未选择想要操作的项目，请先选择想要操作的项目的编号(若要退出请输入Q|q) : " option
        else
            read -r -p "请选择您想要更换成的项目的编号(若要退出请输入Q|q) : " option
        fi

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        # 定义菜单选项
        choiceCount=$(cat "$tool_choice_file_path" | jq '.choice|length')
        targetChoiceCountMap=""
        hasFound=false
        for ((i = 0; i < ${choiceCount}; i++)); do
            iChoiceMap=$(cat "$tool_choice_file_path" | jq ".choice" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号

            iChoiceName=$(echo "$iChoiceMap" | jq -r ".name")
            iChoiceOptionId="$((i + 1))"

            if [ "${option}" = ${iChoiceOptionId} ] || [ "${option}" == ${iChoiceName} ]; then
                targetChoiceCountMap=$iChoiceMap
                hasFound=true
                break
            # else
            #     printf "${RED}%-4s%-25s${NC}不是想要找的%s\n" "${iBranchOptionId}" "$iBranchOptionName" "${option}"
            fi
        done

        if [ ${hasFound} == true ] && [ -n "${targetChoiceCountMap}" ]; then
            update_env_vars
            if [ $? != 0 ]; then
                return 1
            fi
            break
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

update_env_vars() {
    project_tool_file_path=$(echo "$targetChoiceCountMap" | jq -r ".project_tool_file_path")
    if [ ! -f "${project_tool_file_path}" ]; then
        printf "${RED}选择项目失败：您从 ${QTOOL_DEAL_PROJECT_CHOICES_PATH} 中选择的 $targetChoiceCountMap 的 ${BLUE}project_tool_file_path ${RED}指向的文件 ${YELLOW}${project_tool_file_path}${RED} 文件不存在，无法完成选择，请先检查和修改后，重新执行选择。${NC}\n"
        return 1
    fi

    update_env_var "QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH" "${project_tool_file_path}"
    if [ $? != 0 ]; then
        return 1
    fi
}

update_env_var() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        return 1
    fi
    # echo "正在执行命令(更新环境变量):《 sh ${qtoolScriptDir_Absolute}/project_tool/add_or_update_env_var.sh -envVariableKey $1 -envVariableValue $2 》"
    sh ${qtoolScriptDir_Absolute}/project_tool/add_or_update_env_var.sh -envVariableKey "$1" -envVariableValue "$2"
}

# 添加环境的占位符
addEnvPlaceHolderForKey() {
    envKey=$1
    if [ -z "$1" ]; then
        printf "${RED} envKey 参数的值不能为空 ，请检查。${NC}"
        return 1
    fi
    printf "${RED}您还未添加qtool可操作的项目的环境变量 ${envKey} ，请先补充。${NC}"

    envPlaceHolder=$2
    printf "${RED}补充方法如下：请将 ${BLUE}export ${envKey}=${envPlaceHolder}${RED} 中的 ${YELLOW}your_project_choices_json_file ${RED}替换成自己实际的json文件的绝对路径)${NC}\n"
    printf "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量\n${NC}"

    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        printf "${NC}已为你自动打开 open ~/.bash_profile ${NC}\n"
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        printf "${NC}已为你自动打开 open ~/.zshrc ${NC}\n"
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    update_env_var "${envKey}" "${envPlaceHolder}"
    if [ $? != 0 ]; then
        return 1
    fi

    # envKeyFromSys=$(eval echo \$$envKey)
    envKeyFromSys=$(get_sysenvValueByKey "$envKey")
    if [ -z "${envKeyFromSys}" ]; then
        printf "${BLUE}补充结束后，请手动在终端执行 source 命令来生效所修改的环境变量${NC}"
    fi
}

# 定义一个函数，用来获取指定名称的环境变量的值
function get_sysenvValueByKey() {
    local varname="$1"

    # 检查是否传入了环境变量名
    if [ -z "$varname" ]; then
        echo "Usage: getenv varname"
        return 1
    fi

    # 根据当前使用的 SHELL_TYPE 类型，选择正确的语法或命令来获取环境变量的值
    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        echo "${!varname}"
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        eval echo \$$varname
    elif [ "$SHELL_TYPE" = "fish" ]; then
        eval "echo \$$varname"
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    return 0
}

checkFile() {
    if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ] || [ "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" == "your_project_choices_json_file" ]; then
        addEnvPlaceHolderForKey "QTOOL_DEAL_PROJECT_CHOICES_PATH" "your_project_choices_json_file"
        open_sysenv_file
        exit 1
    fi
    if [ ! -f "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
        printf "${RED}您用来配置所有可操作项目的环境变量 ${YELLOW}QTOOL_DEAL_PROJECT_CHOICES_PATH ${RED}的值 ${YELLOW}${QTOOL_DEAL_PROJECT_CHOICES_PATH} ${RED}文件不存在，请先检查并修改 ${NC}\n"
        printf "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量\n${NC}"
        open_sysenv_file
        exit 1
    fi
    tool_choice_file_path=${QTOOL_DEAL_PROJECT_CHOICES_PATH}

    # 显示项目列表
    showProjectList "${tool_choice_file_path}"
    if [ $? != 0 ]; then
        exit 1
    fi

    # 弹出输入，并且根据输入的内容，更新操作的项目
    updateToolDealProject "${tool_choice_file_path}"
    if [ $? != 0 ]; then
        exit 1
    fi
    effectiveEnvironmentVariables

    project_dir=$(get_sysenv_project_dir)
    printf "${GREEN}恭喜：您tool操作的项目已变更为 ${project_dir} ${NC}\n"
}

checkFile

# if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
#     addEnvPlaceHolder
#     if [ $? != 0 ]; then
#         exit 1
#     fi
#     printf "${RED}请先按以上提示，完成添加修改，再继续!${NC}"
#     exit 1
# else
#     checkFile
# fi
