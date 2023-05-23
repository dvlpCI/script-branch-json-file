#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-23 17:22:36
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
        read -r -p "请选择您想要更换成的项目的编号(若要退出请输入Q|q) : " option

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
            break
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

update_env_vars() {
    project_tool_file_path=$(echo "$targetChoiceCountMap" | jq -r ".project_tool_file_path")
    project_dir_path=$(echo "$targetChoiceCountMap" | jq -r ".project_dir_path")

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


if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
    printf "${RED}您还未添加tool可操作的项目的环境变量 QTOOL_DEAL_PROJECT_CHOICES_PATH ，请补充${NC}\n"
else
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

    printf "${GREEN}恭喜：您tool操作的项目已变更为%s${NC}\n" "${QTOOL_DEAL_PROJECT_CHOICES_PATH}"
fi



