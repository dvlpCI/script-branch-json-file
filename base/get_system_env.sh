#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-03 19:45:37
 # @Description: 含路径相关和获取环境变量中的相对路径（因为需要引用路径，所以路径不抽离出去）
### 


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}


# 路径相关


# 获取相对于指定文件的相对目录的绝对路径
function getAbsPathByFileRelativePath() {
    file_path=$1
    rel_path=$2

    file_parent_dir_path="$(dirname $file_path)"
    
    joinFullPath_checkExsit "${file_parent_dir_path}" "${rel_path}"
}

joinFullPath_noCheck() {
    dir_path_this=$1
    path_rel_this_dir=$2
    # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
    # path_rel_this_dir="../../"
    temp_result_path="$dir_path_this/$path_rel_this_dir"
    result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中，TODO 如果 $temp_result_path 指向的路径不存在，那么 $result_path 变量将会是空字符串。
    
    echo "$result_path"
}

# 路径拼接(①支持尾部及头部斜杠的处理;②支持尾部拼接../)
joinFullPath_checkExsit() {
    createIfNoExsit=$3
    
    dir_path_this=$1
    path_rel_this_dir=$2
    # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
    # path_rel_this_dir="../../"
    temp_result_path="$dir_path_this/$path_rel_this_dir"

    check_command realpath # 要使用 realpath ，需要安装 brew install coreutiles
    result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中，TODO 如果 $temp_result_path 指向的路径不存在，那么 $result_path 变量将会是空字符串。
    if [ $? != 0 ]; then
        echo $temp_result_path
        return 1
    fi
    
    if [ ! -d "${result_path}" ] && [ ! -f "${result_path}" ]; then
        if [ "${createIfNoExsit}" == true ]; then
            mkdir "${result_path}"
            echo $result_path
            return 0
        else
            echo $result_path # 不对输出的内容进行加工，放在自身里面，通过返回值告知结果
            return 1
        fi
    else
        echo $result_path
        return 0
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
        if [ "$cmd" == "coscmd" ]; then
            pip install coscmd
            return
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


goPath_rel_project_dir_byKey() {
    requestKey="$1" # .project_path.other_path_rel_home.code_home

    project_tool_params_file_path=$(get_sysenv_project_params_file)
    if [ $? != 0 ]; then
        return 1
    fi

    project_dir=$(get_sysenv_project_dir)
    result_relpath_rel_project_dir=$(cat ${project_tool_params_file_path} | jq -r "${requestKey}")
    
    result_abspath_rel_project_dir=$(joinFullPath_noCheck "$project_dir" $result_relpath_rel_project_dir)
    if [ $? != 0 ]; then
        exit_script
    fi

    # printf "${YELLOW}温馨提示：获取到相对 ${BLUE}${project_dir}${YELLOW} 的 ${BLUE}${result_relpath_rel_project_dir} ${YELLOW}目录为： ${BLUE}${result_abspath_rel_project_dir}${NC}\n"
    echo "$result_abspath_rel_project_dir"
}

# result_file_absPath=$(goPath_rel_project_dir_byKey ".project_path.other_path_rel_home.framework_category_md")
# echo "${result_file_absPath}"