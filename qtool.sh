#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 23:52:16
 # @Description: 
### 

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

qtoolQuickCmdStrings=("cz" "help") # qtool 支持的快捷命令
packageArg="qtool"

CurrentDIR_Script_Absolute="$(cd "$(dirname "$0")" && pwd)"
# 本地测试
function local_test() {
    qbaseScriptDir_Absolute=${CurrentDIR_Script_Absolute}
    echo "$qbaseScriptDir_Absolute"
}

# --------------------- 的 ---------------------
# qian_log 函数
qian_log() {
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2
    fi
}

# --------------------- 具名参数值的解析和获取函数 ---------------------
# 获取具名参数的值（不允许以 - 开头）
# 用法：get_named_arg_value "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空，3=参数以-开头
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_value() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 条件3：第2个参数以 - 开头（是选项）
    if [[ "$val" =~ ^- ]]; then
        printf "%s 的 %s 不能以 '-' 开头: %s" "$opt" "$arg_name" "$val"
        return 3
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 获取具名参数的值（允许以 - 开头）
# 用法：get_named_arg_dashValue "$1" "$2" "参数名"
# 返回值：0=成功，1=参数缺失，2=参数为空
# 输出：成功时输出参数值，失败时输出具体原因（不含 Error: 前缀）
get_named_arg_dashValue() {
    local opt="$1"
    local val="$2"
    local arg_name="${3:-参数值}"
    
    # 条件1：没有第2个参数
    if [ $# -lt 2 ]; then
        printf "%s 缺少 %s" "$opt" "$arg_name"
        return 1
    fi
    
    # 条件2：第2个参数为空字符串
    if [ -z "$val" ]; then
        printf "%s 的 %s 为空字符串" "$opt" "$arg_name"
        return 2
    fi
    
    # 正常情况：输出值，返回0
    printf "%s" "$val"
    return 0
}

# 定义错误处理函数
handle_named_arg_error() {
    local option="$1"
    echo "${RED}Error: 您为参数${YELLOW} ${option} ${RED}指定了值，但该值不符合要求或为空，请检查是否在 ${option} 后提供了正确的值${NC}"
    exit 1
}

# ==================== 默认值设置 ====================
QBASE_CMD="qbase"  # 默认值（当用户不传这个参数时使用）
DEFINE_QIAN=false
CONTAINS_VERBOSE=false
CONTAINS_HELP=false

# 解析命令行参数
allArgsOrigin="$@"
NEXT_SCRIPT_ARGS=() # 存储要传递给下个脚本的参数
while [ $# -gt 0 ]; do
    case "$1" in
        # 具名参数（需要值的参数）
        -qbase-local-path|--qbase-local-path)
            # 用户明确传递了此参数，必须提供有效值
            QBASE_CMD=$(get_named_arg_value "$1" "$2" "qbase路径") || handle_named_arg_error "$1"
            NEXT_SCRIPT_ARGS+=("$1" "$2")
            shift 2;;
        # 标志参数（不需要值的开关）
        --no-use-brew-path)
            isTestingScript=true    # qtool 里的其他脚本路径是否使用本地来拼接，而不是 brew 里的路径
            shift 1
            ;;
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            NEXT_SCRIPT_ARGS+=("$1")
            shift 1
            ;;
        --verbose|-v)
            CONTAINS_VERBOSE=true
            NEXT_SCRIPT_ARGS+=("$1")
            shift 1
            ;;
        --help|-h)
            CONTAINS_HELP=true
            NEXT_SCRIPT_ARGS+=("$1")
            shift 1
            ;;
        
        # 遇到 -- 停止解析
        --)
            NEXT_SCRIPT_ARGS+=("$1")
            shift
            break
            ;;
        # 未知参数或位置参数，停止解析
        *)
            NEXT_SCRIPT_ARGS+=("$@")    # 将剩余的所有参数都添加进去
            break
            ;;
    esac
done

# 剩余的位置参数
POSITIONAL_ARGS=("$@")


# 输出解析结果（调试用）
qian_log "========== 参数解析结果 =========="
qian_log "QBASE_CMD: $QBASE_CMD"
qian_log "DEFINE_QIAN: $DEFINE_QIAN"
qian_log "CONTAINS_VERBOSE: $CONTAINS_VERBOSE"
qian_log "CONTAINS_HELP: $CONTAINS_HELP"
qian_log "isTestingScript: $isTestingScript"
qian_log "位置参数（${#POSITIONAL_ARGS[@]}个）: ${POSITIONAL_ARGS[*]}"
qian_log "传递给下个脚本的参数（${#NEXT_SCRIPT_ARGS[@]}个）: ${NEXT_SCRIPT_ARGS[*]}"
qian_log "=================================="

# 详细模式输出
if [ "$CONTAINS_VERBOSE" = true ]; then
    echo "✅ 详细模式已开启"
fi

# 你的业务逻辑写在这里
# ...

qian_log "${YELLOW}⚠️⚠️⚠️:您现在执行的qtool.sh是 ${CurrentDIR_Script_Absolute} ⚠️⚠️⚠️\n${NC}"

# TODO: 此判断有问题，暂时不用，待修复,若还要启动测试模式，还是得在脚本模式加 test
# if [[ "${CurrentDIR_Script_Absolute}" == /Users/* ]]; then
#     isTestingScript=true
#     printf "${YELLOW}⚠️⚠️⚠️:您现在执行的qtool.sh是/Users下的脚本( ${CurrentDIR_Script_Absolute} )，所以固定为是测试该脚本⚠️⚠️⚠️\n${NC}" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
# fi


args=()
if [ "${CONTAINS_VERBOSE}" == true ]; then
    args+=("--verbose")
fi
if [ "${isTestingScript}" == true ]; then
    args+=("--test")
fi

# 如果是测试脚本中
if [ "${isTestingScript}" == true ]; then
    qtool_homedir_abspath=$(local_test) # 本地测试
else
    qtoolScriptDir_Absolute="$(cd "$(dirname "$0")" && pwd)"
    get_package_util_script_path=$(qbase -package qbase -packageCodeDirName bin -path "get_package_util")
    if [ $? != 0 ]; then
        echo "❌Error:执行命令(获取包的路径)《 qbase -package qbase -packageCodeDirName bin -path \"get_package_util\" 》发生错误，原因如下:"
        echo "${get_package_util_script_path}" # 此时此值是错误信息
        exit 1
    fi
    # echo "正在执行命令(获取脚本包的版本号):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"version\" \"${args[@]}\" 》"
    # echo "正在执行命令(获取脚本包的根路径):《 sh ${get_package_util_script_path} -package \"qtool\" -param \"homedir_abspath\" \"${args[@]}\" 》"
    qtool_latest_version=$(sh ${get_package_util_script_path} -package "qtool" -param "version" "${args[@]}")
    qtool_homedir_abspath=$(sh ${get_package_util_script_path} -package "qtool" -param "homedir_abspath" "${args[@]}")
    qtool_homedir_abspath="${qtool_homedir_abspath%/*}/lib" # 纠正路径(因为有些代码源码是放在bin，有些是放在lib)
    # echo "✅✅✅✅ qtool_latest_version=${qtool_latest_version}"
    # echo "✅✅✅✅ qtool_homedir_abspath=${qtool_homedir_abspath}"
    if [ $? != 0 ]; then
        exit 1
    fi
fi
if [ ! -d "${qtool_homedir_abspath}" ]; then
    echo "您的 ${packageArg} 库的根目录 ${qtool_homedir_abspath} 计算错误，请检查"
    exit 1
fi
# echo "${qtargetScript_curVersion_homedir_abspath}"

function _logQuickCmd() {
    qpackageJsonF="$qtool_homedir_abspath/qtool.json"
    cat "$qpackageJsonF" | jq '.quickCmd'
}


function _get_qbase_in_qtoolJson() {
    local json_file="$qpackageJsonF"
    if [ ! -f "$json_file" ]; then
        echo "qbase"  # 默认返回 qbase
        return 1
    fi
    
    # 从 JSON 中提取 dependences 数组中 key 为 "qbase" 的 local_path
    local qbase_cmd
    qbase_cmd=$(jq -r '.dependences // [] | .[] | select(.key == "qbase") | .local_path // "qbase"' "$json_file" 2>/dev/null)
    
    # 如果找到了且结果不为空
     if [ -n "$qbase_cmd" ] && [ "$qbase_cmd" != "null" ]; then
        qbase_cmd_origin=$qbase_cmd

        # 如果 $qbase_cmd 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        if [[ $qbase_cmd =~ ^~.* ]]; then
            qbase_cmd="${HOME}${qbase_cmd:1}"
            if [ ! -f "$qbase_cmd" ]; then
                echo "${RED}提示: 已进入当前测试模式。但尝试顺便测试本地依赖库(如 qbase 等)失败,${YELLOW} ${qbase_cmd_origin} ${RED}路径不存在。请打开${BLUE} ${json_file} ${RED}中修改:${BLUE} dependences 里 key 为${YELLOW} qbase ${BLUE}的 local_path 的值。${NC}" >&2
                printf "%s" "$qbase_cmd"
                return 11    # 设置了，但文件不存在，不支持
            fi
        fi

        echo "${GREEN}测试模式: 会顺便测试本地依赖库，即使用 qbase 命令 -> ${qbase_cmd}${NC}" >&2
        # 如果 qbase_cmd 是以 .sh 结尾的，因为还要额外再加 sh 来启动，才能兼容避免异常情况，\
        # 但如果把 sh 也加上去就变成了两个参数了，传递给 -qbase-local-path 的时候会有问题，所以这里改为不支持
        if [[ "$qbase_cmd" =~ \.sh$ ]]; then
            echo "${RED}提示: 已进入当前测试模式。但尝试顺便测试本地依赖库(如 qbase 等)失败,${YELLOW} ${qbase_cmd_origin} ${RED}不能以sh结尾，建议是无后缀已编译的文件路径。请打开${BLUE} ${json_file} ${RED}中修改:${BLUE} dependences 里 key 为${YELLOW} qbase ${BLUE}的 local_path 的值。${NC}" >&2
            printf "%s" "$qbase_cmd"
            return 12 # 设置了，但是路径是 .sh 结尾的，不支持
        fi

        printf "%s" "$qbase_cmd"
        return 0    # 设置了，且正确
     fi

    # 如果没找到或结果为空，返回默认值
    echo "${CYAN}提示: 当前测试模式。如需测试本地依赖库(如 qbase 等)，请在${BLUE} ${json_file} ${CYAN}中设置:${BLUE}{ \"dependences\": [{ \"key\": \"qbase\", \"local_path\": \"/path/to/your/qbase.sh\" }] }${NC}" >&2
    echo "qbase"
    return 1 # 未设置
}

# 如果是测试脚本中
qpackageJsonF="$qtool_homedir_abspath/qtool.json"
if [ "${isTestingScript}" == true ]; then
    QBASE_CMD=$(_get_qbase_in_qtoolJson)
    if [ $? != 0 ]; then
        exit 1
    fi
    # 本地测试时候，需要将qbase的路径传递给其他脚本，避免其他脚本还得根据参数重新算一遍
    shouldAddQbaseLoalPath_Before_allArgsExceptFirstArg=true
else
    QBASE_CMD="qbase"
    shouldAddQbaseLoalPath_Before_allArgsExceptFirstArg=false
fi
function insert_args_after_first() {
    local args_str="$1"
    local new_arg1="$2"
    local new_arg2="$3"
    
    # 使用 eval 正确解析
    local args_array=()
    eval "args_array=($args_str)"
    
    # 重新组装
    local result="${args_array[0]}"
    result="$result $new_arg1 $new_arg2"
    
    for ((i=1; i<${#args_array[@]}; i++)); do
        local arg="${args_array[i]}"
        if [[ "$arg" =~ [[:space:]] ]]; then
            result="$result \"$arg\""
        else
            result="$result $arg"
        fi
    done
    
    echo "$result"
}

# qbase_homedir_abspath="~/Project/CQCI/script-qbase"
qbase_homedir_abspath=$(${QBASE_CMD} -path home)
qbase_quickcmd_scriptPath=$qbase_homedir_abspath/qbase_quickcmd.sh
# qbase_quickcmd_scriptPath=qbase_quickcmd.sh

firstArg=$1 # 去除第一个参数之前，先保留下来
shift 1  # 去除前一个参数
allArgsExceptFirstArg="$@"  # 将去除前一个参数，剩余的参数赋值给新变量
qian_log "qtool的所有参数: allArgsOrigin = ${allArgsOrigin}"
qian_log "qtool的所有参数: firstArg = ${firstArg} , allArgsExceptFirstArg = ${allArgsExceptFirstArg}"

# 如果是获取版本号
versionCmdStrings=("--version" "-version" "-v" "version")
if echo "${versionCmdStrings[@]}" | grep -wq "${firstArg}" &>/dev/null; then
    echo "${qtool_latest_version}"
    exit 0
elif [ "${firstArg}" == "-path" ]; then
    qian_log "qtool正在通过qbase调用快捷命令...《 sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg 》"
    sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg getPath $allArgsExceptFirstArg
    exit 0
elif [ "${firstArg}" == "-quick" ]; then
    qbase_checkInputArgsValid_scriptPath=$(${QBASE_CMD} -path checkInputArgsValid)
    if [ ! -f "$qbase_checkInputArgsValid_scriptPath" ]; then
        echo "${RED}Error:${CYAN} $qbase_checkInputArgsValid_scriptPath ${RED}不是有效文件【详情为: 您调用qbase执行获取文件路径的命令${BLUE} ${QBASE_CMD} -path checkInputArgsValid ${RED}得到的结果${CYAN} $qbase_checkInputArgsValid_scriptPath ${RED}不是有效文件】${NC}" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
        exit 1
    fi
    inputArgsErrorMessage=$(sh $qbase_checkInputArgsValid_scriptPath $allArgsExceptFirstArg)
    if [ $? != 0 ]; then
        echo "🚗🚗🚗🚗🚗🚗 如若后续执行发生错误，可能原因为: ${inputArgsErrorMessage}" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
    fi

    if [ "${shouldAddQbaseLoalPath_Before_allArgsExceptFirstArg}" == true ]; then
        allArgsExceptFirstArg=$(insert_args_after_first "$allArgsExceptFirstArg" "-qbase-local-path" "$QBASE_CMD")
    fi
    qian_log "qtool正在通过qbase调用快捷命令...《 sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg 》"
    sh $qbase_quickcmd_scriptPath ${qtool_homedir_abspath} $packageArg execCmd $allArgsExceptFirstArg
    exit 0
else
    qian_log "qtool先输出版本号(然后再输出菜单让你选择): ${qtool_latest_version}"
    echo "${qtool_latest_version}"
fi

if [ "${CONTAINS_HELP}" == true ]; then
    sh ${qtoolScriptDir_Absolute}/qtool_help.sh
    exit 0
fi


qtoolScriptDir_Absolute="${qtool_homedir_abspath}"
# echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}"

# 检查运行环境
sh ${qtoolScriptDir_Absolute}/qtool_runenv.sh "${qtoolScriptDir_Absolute}"
if [ $? != 0 ]; then
    exit 1
fi




# 引入公共方法
source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了使用 project_tool_params_file_path 方法

project_tool_params_file_path=$(get_sysenv_project_params_file)
if [ $? != 0 ]; then
    # printf "${RED}project_tool_params_file_path=${project_tool_params_file_path}${NC}\n"
    sh "${qtoolScriptDir_Absolute}/qtool_change.sh" "${qtoolScriptDir_Absolute}"
    if [ $? != 0 ]; then
        exit 1
    else
        effectiveEnvironmentVariables # 避免环境变量没有生效
        project_tool_params_file_path=$(get_sysenv_project_params_file) # 设置完重新获取
    fi
fi
project_dir=$(get_sysenv_project_dir)
printf "${GREEN}温馨提示:您当前选择的操作参数使用  ${YELLOW}${project_tool_params_file_path} ${GREEN}。【其操作的项目为 ${YELLOW}${project_dir} ${GREEN}】。(如果需要变更，请输入${PURPLE}change${GREEN})${NC}\n"


# elif [ "$1" == "change" ]; then
#     sh ${qtoolScriptDir_Absolute}/qtool_change.sh "${qtoolScriptDir_Absolute}"
if echo "${qtoolQuickCmdStrings[@]}" | grep -wq "$firstArg" &>/dev/null; then
    if [ "$firstArg" == "help" ]; then
        sh ${qtoolScriptDir_Absolute}/qtool_help.sh
    elif [ "$firstArg" == "cz" ]; then
        sh ${qtoolScriptDir_Absolute}/commit/commit_message.sh
    else
        printf "${YELLOW}温馨提示:无法执行未知命令《 qtool \"$1\" 》，请检查"
    fi
else
    qian_log "qtool正在执行命令(输出菜单):《 sh ${qtoolScriptDir_Absolute}/qtool_menu.sh \"${qtoolScriptDir_Absolute}\" \"${NEXT_SCRIPT_ARGS[*]}\" 》"
    sh ${qtoolScriptDir_Absolute}/qtool_menu.sh "${qtoolScriptDir_Absolute}" "${NEXT_SCRIPT_ARGS[*]}"
fi
