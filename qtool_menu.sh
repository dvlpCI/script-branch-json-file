#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 21:05:13
# @FilePath: qtool_menu.sh
# @Description: 工具选项
###

qtoolScriptDir_Absolute=$1
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    echo "请传参 qtoolScriptDir_Absolute"
    exit 1
elif [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

shift 1  # 去除前一个参数
allArgsExceptFirstArg="$@"  # 将去除前一个参数，剩余的参数赋值给新变量

# 获取具名参数的值
get_named_arg_value() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    if [[ "$val" =~ ^- ]]; then
        printf "%s 的 %s 不能以 '-' 开头: %s" "$opt" "$arg_name" "$val"
        return 3
    fi
    printf "%s" "$val"
    return 0
}

# 定义错误处理函数
handle_named_arg_error() {
    local option="$1"
    echo "${RED}Error: 您为参数${YELLOW} ${option} ${RED}指定了值，但该值不符合要求或为空，请检查是否在 ${option} 后提供了正确的值${NC}"
    exit 1
}

allArgsOrigin="$@"
# 使用数组保存参数，避免空格问题
allArgsArray=("$@")

function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}

COMMON_FLAG_ARGS=() # 存储要传递给下个脚本的参数，只允许传递不影响脚本逻辑的公共参数，不然传了后发现有些脚本只接收指定的参数会造成反而无法正常运行

# 初始化标志
contains_help_in_allArgs=false
contains_verbose_in_allArgs=false
DEFINE_QIAN=false
# 遍历数组
for arg in "${allArgsArray[@]}"; do
    # echo "正在处理参数: $arg"  # 打印每个参数
    
    case "$arg" in
        -qbase-local-path|--qbase-local-path)
            # 用户明确传递了此参数，必须提供有效值
            QBASE_CMD=$(get_named_arg_value "$1" "$2" "qbase路径") || handle_named_arg_error "$1"
            COMMON_FLAG_ARGS+=("$1" "$2")
            shift 2;;
        # 标志参数（不需要值的开关）
        --no-use-brew-path)
            isTestingScript=true    # qtool 里的其他脚本路径是否使用本地来拼接，而不是 brew 里的路径
            COMMON_FLAG_ARGS+=("$1")
            shift 1
            ;;
        --help|-help|-h|help)
            contains_help_in_allArgs=true
            COMMON_FLAG_ARGS+=("$arg")
            ;;
        --verbose|-verbose|-v)
            contains_verbose_in_allArgs=true
            COMMON_FLAG_ARGS+=("$arg")
            ;;
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            COMMON_FLAG_ARGS+=("$arg")
            ;;
        *)
            # echo "  -> 未匹配的普通参数: $arg"
            ;;
    esac
done
# 输出解析结果（调试用）
qian_log "========== 参数解析结果（$0） =========="
qian_log "QBASE_CMD: $QBASE_CMD"
qian_log "DEFINE_QIAN: $DEFINE_QIAN"
qian_log "CONTAINS_VERBOSE: $CONTAINS_VERBOSE"
qian_log "CONTAINS_HELP: $CONTAINS_HELP"
qian_log "公共参数（${#COMMON_FLAG_ARGS[@]}个）: ${COMMON_FLAG_ARGS[*]}"
qian_log "=================================="

source ${qtoolScriptDir_Absolute}/base/get_system_env.sh

# 环境变量检查--TOOL_PATH（才能保证可以正确创建分支）
checkEnvValue_TOOL_PARAMS_FILE_PATH() {
    if [ "${#QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        sh "${qtoolScriptDir_Absolute}/qtool_change.sh"
        if [ $? != 0 ]; then
            return 1
        fi
    fi
}

checkEnvValue_TOOL_PARAMS_FILE_PATH
if [ $? != 0 ]; then
    exit 1
fi

project_dir=$(get_sysenv_project_dir)
cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。

gitHome() {
    git_output=$(git rev-parse --show-toplevel)
    gitHomeDir_Absolute=$(echo "$git_output" | tr -d '\n') # 删除输出中的换行符，以获取仓库根目录的绝对路径
    # echo "Git 仓库根目录的绝对路径：$gitHomeDir_Absolute"
    echo "gitHomeDir_Absolute=$gitHomeDir_Absolute"
}
# gitHome

# 工具选项
tool_menu() {
    qtool_menu_json_file_path=$1

    # 使用 jq 命令解析 JSON 数据并遍历
    catalogCount=$(cat "$qtool_menu_json_file_path" | jq '.catalog|length')
    # echo "catalogCount=${catalogCount}"
    for ((i = 0; i < ${catalogCount}; i++)); do
        iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".catalog" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".values")
        iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
        if [ $i = 0 ]; then
            iCatalogColor=${BLUE}
        elif [ $i = 1 ]; then
            iCatalogColor=${PURPLE}
        elif [ $i = 2 ]; then
            iCatalogColor=${GREEN}
        elif [ $i = 3 ]; then
            iCatalogColor=${CYAN}
        elif [ $i = 4 ]; then
            iCatalogColor=${YELLOW}
        else
            iCatalogColor=${YELLOW}
        fi
        for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
            iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
            iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".key")
            iCatalogOutlineDes=$(echo "$iCatalogOutlineMap" | jq -r ".des")
            
            iBranchOption="$((i + 1)).$((j + 1))|${iCatalogOutlineName}"
            printf "${iCatalogColor}%-25s%s${NC}\n" "${iBranchOption}" "$iCatalogOutlineDes" # 要拼接两个字符串，并在拼接的结果中，如果第一个字符串不够 15 位则自动补充空格到 15 位
        done
    done
}






evalActionByInput() {
    qian_log "${GREEN}正在等待你选择...${NC}"

    qtool_menu_json_file_path=$1
    # 读取用户输入的选项，并根据选项执行相应操作
    valid_option=false
    moreActionStrings=("qian" "chaoqian" "lichaoqian") # 输入哪些字符串算是想要退出
    while [ "$valid_option" = false ]; do
        read -r -p "请选择您想要执行的操作编号或id(若要退出请输入Q|q，变更项目输入change) : " option

        if [ "${option}" == q ] || [ "${option}" == "Q" ]; then
            exit 2
        fi

        if [ "${option}" == "change" ]; then
            sh "${qtoolScriptDir_Absolute}/qtool_change.sh"
            break
        fi


        if echo "${moreActionStrings[@]}" | grep -wq "${option}" &>/dev/null; then
            showMenu "${qtoolScriptDir_Absolute}/qtool_menu_private.json"
            break
        fi

        # 定义菜单选项
        catalogCount=$(cat "$qtool_menu_json_file_path" | jq '.catalog|length')
        tCatalogOutlineMap=""
        for ((i = 0; i < ${catalogCount}; i++)); do
            iCatalogMap=$(cat "$qtool_menu_json_file_path" | jq ".catalog" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
            iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".values")
            iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
            hasFound=false
            for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
                iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
                iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".key")
                
                iBranchOptionId="$((i + 1)).$((j + 1))"
                iBranchOptionName="${iCatalogOutlineName}"

                if [ "${option}" = ${iBranchOptionId} ] || [ "${option}" == ${iBranchOptionName} ]; then
                    tCatalogOutlineMap=$iCatalogOutlineMap
                    hasFound=true
                    break
                # else
                #     printf "${RED}%-4s%-25s${NC}不是想要找的%s\n" "${iBranchOptionId}" "$iBranchOptionName" "${option}"
                fi
            done
            if [ ${hasFound} == true ]; then
                break
            fi
        done

        if [ -n "${tCatalogOutlineMap}" ]; then
            # printf "====选中的操作项为======${RED}${tCatalogOutlineMap}${NC}\n"
            # tCatalogOutlineActionType=$(echo "$tCatalogOutlineMap" | jq -r ".action_type")
            
            tCatalogOutlineCommand=$(echo "$tCatalogOutlineMap" | jq -r ".command")
            qian_log "${GREEN}根据你选中的菜单${BLUE} ${option} ${GREEN}，调起指定的方法：【${BLUE} eval \"$tCatalogOutlineCommand\" ${GREEN}】${NC}"
            eval "$tCatalogOutlineCommand"
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

# 显示工具选项
showMenu() {
    qtool_menu_using_json_file_path=$1
    qian_log "${GREEN}qtool菜单构建中...${NC}"
    tool_menu "${qtool_menu_using_json_file_path}"
    qian_log "${GREEN}qtool菜单显示完毕${NC}"
    evalActionByInput "${qtool_menu_using_json_file_path}"
}

# showMenu "${qtoolScriptDir_Absolute}/qtool_menu_public.json"    # 定义菜单选项
# # 退出程序
# exit 0

source "${qtoolScriptDir_Absolute}/qtool_menu_source.sh"

# 直接执行时才显示菜单，source 时不执行 ( source 时候， "${BASH_SOURCE[0]}" 不等于 "${0}" ，"${BASH_SOURCE[0]}" 才是脚本路径)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    qbrew_menu_file_path=$(qbase -path qbrew_menu 2>/dev/null)
    if [ -z "${qbrew_menu_file_path}" ] || [ ! -f "${qbrew_menu_file_path}" ]; then
        echo "${RED}Error: 未找到 qbrew_menu.sh（请确认 qbase 已正确安装）${NC}" >&2
        exit 1
    fi
    sh "${qbrew_menu_file_path}" -file "${qtoolScriptDir_Absolute}/qtool_menu_public.json" -categoryType catalog -execChoosed true
    exit 0
fi
