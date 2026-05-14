#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: qtool_change.sh
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

# 解析具名参数
CHOICES_ENV_VAR=""
TARGET_ENV_VAR=""
PLACEHOLDER=""
ACTION=""
DESC_NOT_SET=""
DESC_FILE_NOT_FOUND=""
shift 1
while [ $# -gt 0 ]; do
    case "$1" in
        --choices-env)
            CHOICES_ENV_VAR="$2"
            shift 2
            ;;
        --target-env)
            TARGET_ENV_VAR="$2"
            shift 2
            ;;
        --placeholder)
            PLACEHOLDER="$2"
            shift 2
            ;;
        --action)
            ACTION="$2"
            shift 2
            ;;
        --desc-not-set)
            DESC_NOT_SET="$2"
            shift 2
            ;;
        --desc-file-not-found)
            DESC_FILE_NOT_FOUND="$2"
            shift 2
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done
if [ -z "${CHOICES_ENV_VAR}" ] || [ -z "${TARGET_ENV_VAR}" ] || [ -z "${PLACEHOLDER}" ] || [ -z "${ACTION}" ] || [ -z "${DESC_NOT_SET}" ] || [ -z "${DESC_FILE_NOT_FOUND}" ]; then
    echo "错误: 缺少必要参数（--choices-env --target-env --placeholder --action --desc-not-set --desc-file-not-found）" >&2
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
        target_value="${!TARGET_ENV_VAR}"
        if [ -z "${target_value}" ]; then
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
        printf "${RED}选择项目失败：您从 ${CHOICES_ENV_VAR} 中选择的 $targetChoiceCountMap 的 ${BLUE}project_tool_file_path ${RED}指向的文件 ${YELLOW}${project_tool_file_path}${RED} 文件不存在，无法完成选择，请先检查和修改后，重新执行选择。${NC}\n"
        return 1
    fi

    update_env_var "${TARGET_ENV_VAR}" "${project_tool_file_path}"
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
    printf "${RED}${DESC_NOT_SET} ${envKey} ，请先补充。${NC}"

    envPlaceHolder=$2
    printf "${RED}补充方法如下：请将 ${BLUE}export ${envKey}=${envPlaceHolder}${RED} 中的 ${YELLOW}${envPlaceHolder} ${RED}替换成自己实际的路径)${NC}\n"
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

validate_choices_json() {
    local file_path="$1"

    jq '.' "$file_path" > /dev/null 2>&1
    if [ $? != 0 ]; then
        printf "${RED}${file_path} 不是有效的 JSON 格式，请检查。${NC}\n"
        exit 1
    fi

    local has_choice
    has_choice=$(jq 'if (.choice? | type) == "array" then true else false end' "$file_path")
    if [ "${has_choice}" != "true" ]; then
        printf "${RED}${file_path} 中缺少 .choice 字段或不是数组格式，请检查。${NC}\n"
        exit 1
    fi

    local choice_count
    choice_count=$(jq '.choice | length' "$file_path")
    if [ "${choice_count}" -eq 0 ]; then
        printf "${RED}${file_path} 中的 .choice 数组为空，请添加项目后再试。${NC}\n"
        exit 1
    fi

    for ((i = 0; i < choice_count; i++)); do
        local item_name
        item_name=$(jq -r ".choice[${i}].name" "$file_path")
        if [ -z "${item_name}" ] || [ "${item_name}" == "null" ]; then
            printf "${RED}${file_path} 格式错误：第 $((i+1)) 条缺少 name${NC}\n"
            exit 1
        fi
        local item_path
        item_path=$(jq -r ".choice[${i}].project_tool_file_path" "$file_path")
        if [ -z "${item_path}" ] || [ "${item_path}" == "null" ]; then
            printf "${RED}${file_path} 格式错误：第 $((i+1)) 条(${item_name}) 缺少 project_tool_file_path${NC}\n"
            exit 1
        fi
    done
}

checkEnv() {
    choices_value="${!CHOICES_ENV_VAR}"
    if [ -z "${choices_value}" ] || [ "${choices_value}" == "${PLACEHOLDER}" ]; then
        addEnvPlaceHolderForKey "${CHOICES_ENV_VAR}" "${PLACEHOLDER}"
        open_sysenv_file
        exit 1
    fi
    if [ ! -f "${choices_value}" ]; then
        printf "${RED}${DESC_FILE_NOT_FOUND} ${YELLOW}${CHOICES_ENV_VAR} ${RED}的值 ${YELLOW}${choices_value} ${RED}文件不存在，请先检查并修改 ${NC}\n"
        printf "${BLUE}温馨提示：如果已修改却未生效，请手动在终端执行 source 命令来生效所修改的环境变量\n${NC}"
        open_sysenv_file
        exit 1
    fi
    if [ "${ACTION}" == "check" ]; then
        exit 0
    fi
}

checkEnv

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
