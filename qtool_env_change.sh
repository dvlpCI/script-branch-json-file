#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: qtool_env_change.sh
# @Usage: sh qtool_env_change.sh --any-env-anme <环境变量名> [options]
# @Example: sh qtool_env_change.sh --any-env-anme QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH --action-type change --env-descript "项目配置信息" --env-var-placeholder "xxx" --env-reference-json-file-example /path/to/example.json --output-filename-if-copy tool_input.json
# @Description: 交互式检查并更新 qbase 环境变量。先检查环境变量是否合法，不存在则引导设置；
#   指定 --action-type change 还会进入交互选择流程，从环境变量表中选择新值并更新。
### 

# --------------------- 的 ---------------------
# qian_log 函数
function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}

# 日志信息输出到终端（规范 2.2：日志输出用 >&2，保持返回值干净）
log_color_info() { printf "%b\n" "$1" >&2; }

show_usage() {
    printf "交互式检查并更新 qbase 环境变量。\n"
    printf "先检查环境变量是否合法，不存在则引导设置；指定 --action-type change 还会进入交互选择流程。\n"
    printf "Usage: sh %s --any-env-anme <环境变量名> [options]\n" "$0"
    printf "Example: sh %s --any-env-anme QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH --action-type change\n" "$0"
    printf "Params:\n"
    printf "  --any-env-anme             必填：要检查/更新的环境变量名\n"
    printf "  --action-type              可选：change 进入交互选择流程；不传则仅检查\n"
    printf "  --env-descript             必填：环境变量描述\n"
    printf "  --env-var-placeholder      必填：占位符\n"
    printf "  --env-reference-json-file-example  必填：参考 JSON 文件路径\n"
    printf "  --output-filename-if-copy  必填：复制时输出文件名\n"
    printf "  --qian                     可选：打印调试日志\n"
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    show_usage
    exit 0
fi

qbase_env_var_1get_by_manual_scriptPath=$(qbase -path env_var_get_by_manual)
qbase_env_var_2add_or_update_scriptPath=$(qbase -path env_var_add_or_update)
qbase_env_var_effective_or_open_scriptPath=$(qbase -path env_var_effective_or_open)

qbase_env_file_check_and_set_scriptPath=$(qbase -path env_file_check_and_set)


# ==================== 默认值设置 ====================
DEFINE_QIAN=false

# 解析具名参数
ANY_ENV_NAME=""                          # 任意 的环境变量
ACTION_TYPE=""                           # 操作类型 change:改变
ENV_DESCRIPT=""                          # 环境变量描述，传给 --env-descript
ENV_VAR_PLACEHOLDER=""                   # 传给 --env-var-placeholder
ENV_REF_JSON_EXAMPLE=""                  # 传给 --env-reference-json-file-example
OUTPUT_FILENAME_IF_COPY=""               # 传给 --output-filename-if-copy
while [ $# -gt 0 ]; do
    case "$1" in
        --any-env-anme)
            # 不能为空
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                log_color_info "错误: --any-env-anme 必须指定"
                exit 1
            fi
            ANY_ENV_NAME="$2"
            shift 2
            ;;
        --action-type)
            # 允许空值或者不传：检查下一个参数是否为空或者是选项（以 - 开头）
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                # 没有提供值，或者下一个参数是选项，则设置为空
                ACTION_TYPE=""
                shift 1  # 只消费当前参数
            else
                ACTION_TYPE="$2"
                shift 2
            fi
            ;;
        --env-descript)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                log_color_info "错误: --env-descript 必须指定"
                exit 1
            fi
            ENV_DESCRIPT="$2"
            shift 2
            ;;
        --env-var-placeholder)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                log_color_info "错误: --env-var-placeholder 必须指定"
                exit 1
            fi
            ENV_VAR_PLACEHOLDER="$2"
            shift 2
            ;;
        --env-reference-json-file-example)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                log_color_info "错误: --env-reference-json-file-example 必须指定"
                exit 1
            fi
            ENV_REF_JSON_EXAMPLE="$2"
            shift 2
            ;;
        --output-filename-if-copy)
            if [ -z "$2" ] || [[ "$2" =~ ^- ]]; then
                log_color_info "错误: --output-filename-if-copy 必须指定"
                exit 1
            fi
            OUTPUT_FILENAME_IF_COPY="$2"
            shift 2
            ;;
        --qian)
            DEFINE_QIAN=true
            shift 1
            ;;
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "${ANY_ENV_NAME}" ]; then
    log_color_info "错误: 缺少必要参数（--any-env-anme）"
    exit 1
fi
if [ -z "${ENV_DESCRIPT}" ]; then
    log_color_info "错误: 缺少必要参数（--env-descript）"
    exit 1
fi
if [ -z "${ENV_VAR_PLACEHOLDER}" ]; then
    log_color_info "错误: 缺少必要参数（--env-var-placeholder）"
    exit 1
fi
if [ -z "${ENV_REF_JSON_EXAMPLE}" ]; then
    log_color_info "错误: 缺少必要参数（--env-reference-json-file-example）"
    exit 1
fi
if [ -z "${OUTPUT_FILENAME_IF_COPY}" ]; then
    log_color_info "错误: 缺少必要参数（--output-filename-if-copy）"
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

function open_sysenv_file() {
    sh $qbase_env_var_effective_or_open_scriptPath open
}


# 检查 ${ANY_ENV_NAME} 这个环境变量key和value有没有在 ${QTOOL_DEAL_PROJECT_CHOICES_PATH} 这个环境变量表指向的json文件中
# 1、key 在不在 keys 中
#   - 不在：则进行添加（添加的时候需要用户输入该新值的含义）后，再进行下一步
#   - 有在：继续判断现在的环境变量值 value 在不在环境变量表该key的允许数组中
#           - 不在：则进行添加（添加的时候需要用户输入该新值的含义）后，再进行下一步
#           - 有在：直接继续下一步
function ensureEnvVarInChoicesFile() {
    local env_key="$1"
    local env_value="$2"
    local choices_file="$3"

    # 1、检查 key 是否已在 choices 的 keys 中（jq 返回的匹配条目数，合法的json格式算出的匹配个数最多值只能为1)
    local key_count
    key_count=$(jq --arg k "${env_key}" \
        '[.envs_choices[] | select(.env_key == $k)] | length' "${choices_file}")

    if [ "${key_count}" -eq 0 ]; then
        # key 不在 keys 中：创建新条目（包含 env_key + env_des + 首次的 env_choices）
        read -r -p "请输入 ${env_key} 的描述(env_des): " env_des
        jq --arg k "${env_key}" \
           --arg d "${env_des}" \
           --arg v "${env_value}" \
           '.envs_choices += [{"env_key": $k, "env_des": $d, "env_choices": [{"env_des": $d, "env_value": $v}]}]' \
           "${choices_file}" > "${choices_file}.tmp" \
        && mv "${choices_file}.tmp" "${choices_file}" \
        || { log_color_info "${RED}写入 choices 文件失败${NC}"; return 1; }
    else
        # 2、key 已在 keys 中：检查当前 value 是否在该 key 的 env_choices 数组中
        local value_count
        value_count=$(jq --arg k "${env_key}" --arg v "${env_value}" \
            '[.envs_choices[] | select(.env_key == $k) | .env_choices[] | select(.env_value == $v)] | length' \
            "${choices_file}")

        if [ "${value_count}" -eq 0 ]; then
            # value 不在数组中：追加到该 key 的 env_choices（需用户输入该值的描述）
            read -r -p "请为值 ${env_value} 输入描述(env_des): " value_des
            jq --arg k "${env_key}" \
               --arg d "${value_des}" \
               --arg v "${env_value}" \
               '(.envs_choices[] | select(.env_key == $k) | .env_choices) += [{"env_des": $d, "env_value": $v}]' \
               "${choices_file}" > "${choices_file}.tmp" \
            && mv "${choices_file}.tmp" "${choices_file}" \
            || { log_color_info "${RED}写入 choices 文件失败${NC}"; return 1; }
        else
            # value 已在数组中：无需操作
            log_color_info "${GREEN}环境变量 ${env_key} 及其值已在环境变量表中${NC}"
        fi
    fi
    return 0
}




log_color_info "${PURPLE}\n================== 1、检查环境变量文件中的【任意指定】环境变量情况。如果异常则进行配置更新 ==================${NC}"
any_env_value_origin=${!ANY_ENV_NAME}    # 记录下该环境变量的原始值，待等下与检查后的新值做对比，来判断是否发生了改变。
qian_log "${YELLOW}正在执行命令《${BLUE} sh ${qbase_env_file_check_and_set_scriptPath} --env-name \"${ANY_ENV_NAME}\" --env-descript \"${ENV_DESCRIPT}\" --env-var-placeholder \"${ENV_VAR_PLACEHOLDER}\" --env-reference-json-file-example ${ENV_REF_JSON_EXAMPLE} --output-filename-if-copy ${OUTPUT_FILENAME_IF_COPY} ${YELLOW}》。${NC} "
projectParamsCheckResult=$(sh ${qbase_env_file_check_and_set_scriptPath} \
    --env-name "${ANY_ENV_NAME}" \
    --env-descript "${ENV_DESCRIPT}" \
    --env-var-placeholder "${ENV_VAR_PLACEHOLDER}" \
    --env-reference-json-file-example "${ENV_REF_JSON_EXAMPLE}" \
    --output-filename-if-copy "${OUTPUT_FILENAME_IF_COPY}"
)
if [ $? -ne 0 ]; then
    echo "${projectParamsCheckResult}"
    exit 2
fi
any_env_value_new=${projectParamsCheckResult} # 注意：此处一定要获取更新后的值，不然一定是执行 env_file_check_and_set.sh 前的旧值
log_color_info "${GREEN}您的项目配置信息环境变量及其值 ${ANY_ENV_NAME} : \"${any_env_value_new}\" ${NC}"
# exit 1





log_color_info "${PURPLE}\n================== 2、检查环境变量文件中的【环境变量表 QTOOL_DEAL_PROJECT_CHOICES_PATH】这个环境变量的情况（为等下将之前的任意指定环境变量维护到环境变量表指向的文件中做准备）。如果异常则进行配置更新 ==================${NC}"
if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
    log_color_info "${RED}错误: 环境变量 QTOOL_DEAL_PROJECT_CHOICES_PATH 未设置，请先执行 ${BLUE}qtool init${NC}"
    exit 1
fi
CHOICES_FILE="${QTOOL_DEAL_PROJECT_CHOICES_PATH}"
if [ ! -f "${CHOICES_FILE}" ]; then
    log_color_info "${RED}错误: 文件不存在 ${CHOICES_FILE}，请先执行 ${BLUE}qtool init${NC}"
    exit 1
fi

log_color_info "${PURPLE}\n================== 3、检查 ${ANY_ENV_NAME} 这个环境变量key和value有没有在 ${QTOOL_DEAL_PROJECT_CHOICES_PATH} 这个环境变量表指向的json文件中 ==================${NC}"
ensureEnvVarInChoicesFile "${ANY_ENV_NAME}" "${any_env_value_new}" "${CHOICES_FILE}"



if [ "${any_env_value_origin}" != "${any_env_value_new}" ]; then
    # 检查到有发生变化，说明前面已经设置好了，没必要再多余进行接下来的change交互。（因为如果没变化，说明前面只是检查到他们两个是合法的，没做其他动作，才有必要接下来做想要做的其他交互[比如想要change]）
    log_color_info "any_env_value_origin(旧):   ${any_env_value_origin}"
    log_color_info "any_env_value_new(新):      ${any_env_value_new}"
    open_sysenv_file
    sh $qbase_env_var_effective_or_open_scriptPath effective
    exit 0
fi
# 检查到没变化，说明前面只是检查到他们两个是合法的，没做其他动作，才有必要接下来做想要做的其他交互[比如想要change]
log_color_info "${PURPLE}\n================== 4、如果不是 change 动作，则流程结束退出。如果是change则进行下一步 ==================${NC}"
if [ "${ACTION_TYPE}" != "change" ]; then
    open_sysenv_file
    sh $qbase_env_var_effective_or_open_scriptPath effective
    exit 0
fi


log_color_info "${PURPLE}\n============== 通过人工交互方式获取指定环境变量的值(方式 ①从文件中选择[如果有传文件的话]或者 ②从终端输入） ==================${NC}"
checkResult=$(sh $qbase_env_var_1get_by_manual_scriptPath --env-name "${ANY_ENV_NAME}" --env-keys-file "${CHOICES_FILE}")
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    exit 1
fi
jsonData=$(printf "%s" "${checkResult}" | jq -r '.')
log_color_info "${YELLOW}${jsonData}${NC}"

status_type=$(echo "${checkResult}" | jq -r '.status_type')
message=$(echo "${checkResult}" | jq -r '.message')
if [ "${status_type}" != "env_val_get_success" ]; then
    log_color_info "${message}"
    exit 0
fi
response=$(echo "${checkResult}" | jq -r '.response')
selected_env_key=$(echo "${response}" | jq -r '.env_key')
selected_env_value=$(echo "${response}" | jq -r '.env_value')
log_color_info "${PURPLE}\n============== 对为环境变量 key 选中的值，进行结构检查 ==================${NC}"
log_color_info "${GREEN}选中的环境变量及其值为${BLUE} ${selected_env_key}:${selected_env_value} ${GREEN}。${NC}"
    # --env-reference-type json-file \
    # --env-reference-json-file-example ${example_json_file_choices}



log_color_info "${PURPLE}\n============== 对为环境变量 key 选中的值，进行更新 ==================${NC}"
# log_color_info "正在执行命令《 sh $qbase_env_var_2add_or_update_scriptPath -envVariableKey \"${selected_env_key}\" -envVariableValue \"${selected_env_value}\" --environment-file-auto-open false 》"
sh $qbase_env_var_2add_or_update_scriptPath -envVariableKey "${selected_env_key}" -envVariableValue "${selected_env_value}" --environment-file-auto-open false
if [ $? != 0 ]; then
    open_sysenv_file
    exit 1
fi
log_color_info "已更新环境变量 ${selected_env_key} = ${YELLOW}${selected_env_value}${NC}"

open_sysenv_file
sh $qbase_env_var_effective_or_open_scriptPath effective

