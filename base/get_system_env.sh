#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2023-06-04 02:57:46
 # @Description: 
### 

# project_dir=${QTOOL_DEAL_PROJECT_DIR_PATH}
# if [[ $project_dir =~ ^~.* ]]; then
#     # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
#     project_dir="${HOME}${project_dir:1}"
# fi
# cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

joinFullPath() {
    dir_path_this=$1
    path_rel_this_dir=$2
    createIfNoExsit=$3
    # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
    # path_rel_this_dir="../../"
    temp_result_path="$dir_path_this/$path_rel_this_dir"
    result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中
    if [ ! -d "${result_path}" ] && [ ! -f "${result_path}" ]; then
        if [ "${createIfNoExsit}" == true ]; then
            mkdir "${result_path}"
        else 
            printf "${RED}❌Error:路径不存在:%s${NC}\n" "${result_path}"
            return 1
        fi
    fi
    echo $result_path
}

open_sysenv_file() {
    SHELL_TYPE=$(basename $SHELL)
    if [ "$SHELL_TYPE" = "bash" ]; then
        envFile=$HOME/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        envFile=$HOME/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi

    open "${envFile}"
}

check_sysenv_project_params_file() {
    if [ "${#QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        sh "${qtoolScriptDir_Absolute}/qtool_change.sh" "${qtoolScriptDir_Absolute}"
        if [ $? != 0 ]; then
            return 1
        fi
    fi

    project_tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    if [[ $project_tool_params_file_path =~ ^~.* ]]; then
        # 如果 $project_tool_params_file_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        project_tool_params_file_path="${HOME}${project_tool_params_file_path:1}"
    fi
    if [ ! -f "${project_tool_params_file_path}" ]; then
        printf "${RED}您设置的环境变量 QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH=${project_tool_params_file_path} ===文件不存在，请检查%s${NC}\n"
        open_sysenv_file
        return 1
    fi
}

get_sysenv_project_dir() {
    check_sysenv_project_params_file
    if [ $? != 0 ]; then
        return 1
    fi

    project_tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    # printf "${YELLOW}你所有的配置来自文件:%s${NC}\n" "${project_tool_params_file_path}"
    project_path_map=$(cat ${project_tool_params_file_path} | jq -r ".project_path")
    home_path_rel_tool_dir=$(echo ${project_path_map} | jq -r ".home_path_rel_this_dir")
    # home_abspath=$(cd "$(dirname "$project_tool_params_file_path")/$home_path_rel_this_dir"; pwd)
    home_abspath=$(joinFullPath "$(dirname $project_tool_params_file_path)" $home_path_rel_tool_dir)
    if [ $? != 0 ]; then
        exit_script
    fi
    printf "${BLUE}你要操作的项目的路径为：%s${NC}\n" "${home_abspath}"
}


goCodeHome() {
    code_dir_rel_home_dir=$(echo ${project_path_map} | jq -r ".other_path_rel_home.code_home")
    code_dir_abspath=$(joinFullPath "$home_abspath" $code_dir_rel_home_dir)
    if [ $? != 0 ]; then
        exit_script
    fi
    printf "${BLUE}app的代码根目录为：%s${NC}\n" "${code_dir_abspath}"
    cd "$code_dir_abspath" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。
}
