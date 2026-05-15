#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: qtool_change.sh
### 

# 日志信息输出到终端（规范 2.2：日志输出用 >&2，保持返回值干净）
log_color_info() { printf "%b\n" "$1" >&2; }

qtoolScriptDir_Absolute=$1
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    echo "请传参 qtoolScriptDir_Absolute"
    exit 1
elif [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

source ${qtoolScriptDir_Absolute}/base/get_system_env.sh # 为了引入 open_sysenv_file getAbsPathByFileRelativePath 方法

qbase_env_var_1get_by_manual_scriptPath=$(qbase -path env_var_get_by_manual)
qbase_env_var_2add_or_update_scriptPath=$(qbase -path env_var_add_or_update)
qbase_env_var_effective_or_open_scriptPath=$(qbase -path env_var_effective_or_open)

qbase_env_file_check_and_set_scriptPath=$(qbase -path env_file_check_and_set)

# 解析具名参数
CHOICES_ENV_VAR=""
TARGET_ENV_VAR=""
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
        *)
            echo "未知参数: $1" >&2
            exit 1
            ;;
    esac
done

if [ -z "${CHOICES_ENV_VAR}" ] || [ -z "${TARGET_ENV_VAR}" ]; then
    echo "错误: 缺少必要参数（--choices-env --target-env --placeholder）" >&2
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

example_json_file_choices=${qtoolScriptDir_Absolute}/test/tool_choice.json
# qian_log "${YELLOW}正在执行命令《${BLUE} sh ${qbase_env_file_check_and_set_scriptPath} --env-name \"${CHOICES_ENV_VAR}\" --env-descript qtool可操作的项目列表 --env-var-placeholder \"your_project_choices_json_file\" --env-reference-json-file-example ${example_json_file_choices} --output-filename-if-copy tool_choice.json ${YELLOW}》。${NC} "
checkResult=$(sh ${qbase_env_file_check_and_set_scriptPath} \
    --env-name "${CHOICES_ENV_VAR}" \
    --env-descript qtool可操作的项目列表 \
    --env-var-placeholder "your_project_choices_json_file" \
    --env-reference-json-file-example ${example_json_file_choices} \
    --output-filename-if-copy tool_choice.json
)
if [ $? -ne 0 ]; then
    echo "${checkResult}"
    exit 2
fi
CHOICES_ENV_VAR_VALUE=${checkResult} # 注意：此处一定要获取更新后的值，不然一定是执行 env_file_check_and_set.sh 前的旧值
log_color_info "${GREEN}您的可操作项目列表环境变量及其值 ${CHOICES_ENV_VAR} : \"${CHOICES_ENV_VAR_VALUE}\" ${NC}"
# exit 1



log_color_info "${PURPLE}\n============== 通过人工交互方式获取指定环境变量的值(方式 ①从文件中选择[如果有传文件的话]或者 ②从终端输入） =================="
checkResult=$(sh $qbase_env_var_1get_by_manual_scriptPath --env-name "${TARGET_ENV_VAR}" --env-keys-file "${CHOICES_ENV_VAR_VALUE}")
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
