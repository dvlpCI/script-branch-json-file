#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-06 12:47:52
 # @Description: 
### 

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

joinFullPath_checkExsit() {
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

get_project_dir() {
    project_tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    # printf "${YELLOW}你所有的配置来自文件:%s${NC}\n" "${project_tool_params_file_path}"
    project_path_map=$(cat ${project_tool_params_file_path} | jq -r ".project_path")
    home_path_rel_tool_dir=$(echo ${project_path_map} | jq -r ".home_path_rel_this_dir")
    # home_abspath=$(cd "$(dirname "$project_tool_params_file_path")/$home_path_rel_this_dir"; pwd)
    home_abspath=$(joinFullPath_checkExsit "$(dirname $project_tool_params_file_path)" $home_path_rel_tool_dir)
    if [ $? != 0 ]; then
        exit_script
    fi
    printf "${BLUE}你要操作的项目的路径为：%s${NC}\n" "${home_abspath}"


    if [[ $project_dir =~ ^~.* ]]; then
        # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        project_dir="${HOME}${project_dir:1}"
    fi
    cd "$project_dir" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。


    project_dir=$home_abspath
}
get_project_dir


goCodeHome() {
    code_dir_rel_home_dir=$(echo ${project_path_map} | jq -r ".other_path_rel_home.code_home")
    code_dir_abspath=$(joinFullPath_checkExsit "$home_abspath" $code_dir_rel_home_dir)
    if [ $? != 0 ]; then
        exit_script
    fi
    printf "${BLUE}app的代码根目录为：%s${NC}\n" "${code_dir_abspath}"
    cd "$code_dir_abspath" || exit # 切换到工作目录后，才能争取创建git分支。"exit" 命令用于确保如果更改目录时出现错误，则脚本将退出。
}
goCodeHome

# 在代码根目录下执行
flutter packages pub run build_runner build --delete-conflicting-outputs
if [ $? != 0 ]; then
    exit 1
fi