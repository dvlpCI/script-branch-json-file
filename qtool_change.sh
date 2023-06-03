#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-06-04 02:55:08
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

source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了引入 open_sysenv_file 方法


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
    printf "支持的项目列表：\n"
    choiceCount=$(cat "$tool_choice_file_path" | jq '.choice|length')
    for ((i = 0; i < ${choiceCount}; i++)); do
        iChoiceMap=$(cat "$tool_choice_file_path" | jq ".choice" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        
        iChoiceOptionId="$((i + 1))"
        iChoiceName=$(echo "$iChoiceMap" | jq -r ".name")
        iChoiceProjectDirPath=$(echo "$iChoiceMap" | jq -r ".project_dir_path")

        # echo "正在执行命令:《echo \"$iChoiceMap\" | jq -r \".name\"》"

        printf "${GREEN}%-2s%-20s(路径为${YELLOW}%s)${NC}\n" "${iChoiceOptionId}" "${iChoiceName}" "${iChoiceProjectDirPath}"
    done
}

updateToolDealProject() {
    tool_choice_file_path=$1


    # 读取用户输入的选项，并根据选项执行相应操作
    valid_option=false
    while [ "$valid_option" = false ]; do
        if [ -z "" ]; then
            read -r -p "请先选择您想要操作的项目的编号(若要退出请输入Q|q) : " option
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
    project_dir_path=$(echo "$targetChoiceCountMap" | jq -r ".project_dir_path")
    if [ ! -d "${project_dir_path}" ]; then
        printf "${RED}选择项目失败：您从 ${QTOOL_DEAL_PROJECT_CHOICES_PATH} 中选择的 $targetChoiceCountMap 的 ${BLUE}project_dir_path ${RED}指向的文件 ${YELLOW}${project_dir_path}${RED} 目录不存在，无法完成选择，请先检查和修改后，重新执行选择。${NC}\n"
        return 1
    fi

    update_env_var "QTOOL_DEAL_PROJECT_DIR_PATH" "${project_dir_path}"
    if [ $? != 0 ]; then
        return 1
    fi
    
    update_env_var "QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH" "${project_tool_file_path}"
    if [ $? != 0 ]; then
        return 1
    fi
}

update_env_var() {
    # echo "正在执行命令(更新环境变量):《 sh ${qtoolScriptDir_Absolute}/project_tool/add_or_update_env_var.sh -envVariableKey $1 -envVariableValue $2 》"
    sh ${qtoolScriptDir_Absolute}/project_tool/add_or_update_env_var.sh -envVariableKey $1 -envVariableValue $2
}

# 添加环境的占位符
addEnvPlaceHolder() {
    printf "${RED}您还未添加qtool可操作的项目的环境变量 QTOOL_DEAL_PROJECT_CHOICES_PATH ，请先补充。${NC}"
    
    envPlaceHolder="your_project_choices_json_file"
    printf "${RED}补充方法如下：请将 ${BLUE}export QTOOL_DEAL_PROJECT_CHOICES_PATH=%s${RED} 中的${YELLOW}your_project_choices_json_file${RED}替换成自己实际的json文件的绝对路径)%s${NC}\n" "${envPlaceHolder}"
    
    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        printf "${NC}已为你自动打开 open ~/.bash_profile ${NC}\n"
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        printf "${NC}已为你自动打开 open ~/.zshrc ${NC}\n"
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    update_env_var "QTOOL_DEAL_PROJECT_CHOICES_PATH" "${envPlaceHolder}"
    if [ $? != 0 ]; then
        return 1
    fi
}


if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
    addEnvPlaceHolder
    if [ $? != 0 ]; then
        exit 1
    fi
else
    tool_choice_file_path=${QTOOL_DEAL_PROJECT_CHOICES_PATH}
    if [ ! -f "${tool_choice_file_path}" ]; then
        printf "${RED}您用来配置所有可操作项目的环境变量 ${YELLOW}QTOOL_DEAL_PROJECT_CHOICES_PATH ${RED}的值 ${YELLOW}${QTOOL_DEAL_PROJECT_CHOICES_PATH} ${RED}文件不存在，请先检查并修改 ${NC}\n"
        open_sysenv_file
        exit 1
    fi
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

    printf "${GREEN}恭喜：您tool操作的项目已变更为%s${NC}\n" "${QTOOL_DEAL_PROJECT_CHOICES_PATH}"
fi



