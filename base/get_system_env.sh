#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-06 17:42:37
 # @Description: 
### 


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# 获取相对于指定文件的相对目录的绝对路径
function getAbsPathByFileRelativePath() {
    file_path=$1
    rel_path=$2

    file_parent_dir_path="$(dirname $file_path)"
    
    joinFullPath "${file_parent_dir_path}" "${rel_path}"
}

# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)
joinFullPath() {
    dir_path_this=$1
    path_rel_this_dir=$2
    createIfNoExsit=$3
    # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
    # path_rel_this_dir="../../"
    temp_result_path="$dir_path_this/$path_rel_this_dir"

    check_command realpath # 要使用 realpath ，需要安装 brew install coreutiles
    result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中
    if [ ! -d "${result_path}" ] && [ ! -f "${result_path}" ]; then
        if [ "${createIfNoExsit}" == true ]; then
            mkdir "${result_path}"
        else 
            printf "${RED}❌Error:路径不存在:${result_path}${NC}\n"
            return 1
        fi
    fi
    echo $result_path
}

# 生效环境变量
effectiveEnvironmentVariables() {
    SHELL_TYPE=$(basename $SHELL)

    if [ "$SHELL_TYPE" = "bash" ]; then
        source ~/.bash_profile
    elif [ "$SHELL_TYPE" = "zsh" ]; then
        source ~/.zshrc
    else
        echo "Unknown shell type: $SHELL_TYPE"
        return 1
    fi
}

# Checks if the specified command is available
# If the command is not available, it will be installed
function check_command() {
    local cmd=$1
    if ! command -v $cmd &> /dev/null; then
        echo "$cmd command not found, installing..."
        if [ "$cmd" == "realpath" ]; then
            cmd=coreutiles
        fi
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "正在执行安装命令：《 brew install $cmd 》"
            brew install $cmd
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [[ -n $(command -v apt-get) ]]; then
                sudo apt-get update
                sudo apt-get install -y $cmd
            elif [[ -n $(command -v yum) ]]; then
                sudo yum install -y $cmd
            elif [[ -n $(command -v dnf) ]]; then
                sudo dnf install -y $cmd
            else
                echo "Unable to install $cmd, please install it manually."
                exit 1
            fi
        else
            echo "Unsupported operating system, please install $cmd manually."
            exit 1
        fi
    fi
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

get_sysenv_project_params_file() {
    if [ "${#QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        return 1
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

    echo "${project_tool_params_file_path}" # 此输出需要作为返回值,所以不能添加其他东西
}

# 获取所有的配置来自的文件
get_sysenv_project_dir() {
    project_tool_params_file_path=$(get_sysenv_project_params_file)
    if [ $? != 0 ]; then
        return 1
    fi

    project_path_map=$(cat ${project_tool_params_file_path} | jq -r ".project_path")
    home_path_rel_tool_dir=$(echo ${project_path_map} | jq -r ".home_path_rel_this_dir")
    project_dir=$(getAbsPathByFileRelativePath "$project_tool_params_file_path" $home_path_rel_tool_dir)
    if [ $? != 0 ]; then
        exit_script
    fi

    if [[ $project_dir =~ ^~.* ]]; then
        # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        project_dir="${HOME}${project_dir:1}"
    fi
    printf "${project_dir}" # 此输出需要作为返回值,所以不能添加其他东西
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
