#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
# @LastEditors: dvlproad
# @LastEditTime: 2026-04-14
# @FilePath: src/branch_function.sh
# @Description: 分支相关公共函数
###
# 使用方式: source src/branch_function.sh

# 获取分支类型配置文件路径
function getCategoryFile() {
    target_branch_type_file_abspath=$1
    # 读取文件内容
    content=$(cat "${target_branch_type_file_abspath}")
    relFilePathKey=".branch_belong_file_rel_this_file"
    rel_file_path_value=$(echo "$content" | jq -r "${relFilePathKey}")
    if [ -z "${rel_file_path_value}" ] || [ "${rel_file_path_value}" == "null" ]; then
        printf "%s" "${RED}请先在${BLUE} ${target_branch_type_file_abspath} ${RED}文件中设置${BLUE} ${relFilePathKey} ${NC}\n"
        return 1
    fi

    target_file_abspath=$(getAbsPathByFileRelativePath "${target_branch_type_file_abspath}" "$rel_file_path_value")
    if [ $? != 0 ]; then
        printf "%s" "${RED}拼接${BLUE} ${target_branch_type_file_abspath} ${RED}和${BLUE} ${rel_file_path_value} ${RED}组成的路径结果错误，错误结果为 ${target_file_abspath} ${NC}\n"
        return 1
    fi

    echo "${target_file_abspath}"
}

# 获取人员配置文件路径
function getPersonFile() {
    target_branch_type_file_abspath=$1
    # target_file_abspath=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    # 读取文件内容
    content=$(cat "${target_branch_type_file_abspath}")
    relFilePathKey=".personnel_file_path_rel_this_file"
    rel_file_path_value=$(echo "$content" | jq -r "${relFilePathKey}")
    if [ -z "${rel_file_path_value}" ] || [ "${rel_file_path_value}" == "null" ]; then
        printf "%s" "${RED}请先在${BLUE} ${target_branch_type_file_abspath} ${RED}文件中设置人员文件字段${BLUE} ${relFilePathKey} ${RED}（建议放在分支模块文件字段${BLUE} .branch_belong_file_rel_this_file ${RED}字段之前）${RED} \n"
        return 1
    fi

    target_file_abspath=$(getAbsPathByFileRelativePath "${target_branch_type_file_abspath}" "$rel_file_path_value")
    if [ $? != 0 ]; then
        printf "%s" "${RED}拼接${BLUE} ${target_branch_type_file_abspath} ${RED}和${BLUE} ${rel_file_path_value} ${RED}组成的路径结果错误，错误结果为 ${target_file_abspath} ${NC}\n"
        return 1
    fi

    echo "${target_file_abspath}"
}

# 获取并显示模块列表（供分支创建和提交时使用）
function show_and_get_framework_category() {
    local target_category_file_abspath=$1
    local target_person_file_abspath=$2
    now_time=$(date +"%m%d%H%M%S")
    TempDir_Absolute="$( cd "$( dirname "$0" )" && pwd )"
    temp_file_abspath="${TempDir_Absolute}/${now_time}.json"
    
    show_framework_category_forBranchCreate "${target_category_file_abspath}" "${target_person_file_abspath}" "${temp_file_abspath}" # 罗列模块列表
    if [ $? != 0 ]; then
        printf "${RED}获取模块列表失败${NC}\n"
        exit 1
    fi
    moduleOptionKeys=($(cat ${temp_file_abspath}))
    rm -rf ${temp_file_abspath} # 删除文件temp_file_abspath
}

# 1.2.2、选择分支所属模块，并完善分支名
function chooseAndCompleteBranchName() {
    local quitStrings=("q" "Q" "quit" "Quit" "n")
    # 无限循环，监听用户输入
    while true; do
        read -r -p "②请输入您选择的完整模块标识key值(自定义请填0,退出请输入Q|q) : " module_option_input

        if echo "${quitStrings[@]}" | grep -wq "${module_option_input}" &>/dev/null; then
            echo "您已退出创建"
            exit 1
        fi

        if [ "${module_option_input}" == "0" ]; then
            read -r -p "②请输入您自定义的分支所属模块(退出请输入Q|q) : " module_option_input
            if echo "${quitStrings[@]}" | grep -wq "${module_option_input}" &>/dev/null; then
                echo "您已退出创建"
                exit 1
            else
                break
            fi
        fi

        # 遍历 key 列表，判断输入是否匹配
        match=false
        for key in "${moduleOptionKeys[@]}"; do
            if [ "$module_option_input" == "$key" ]; then
                match=true
                break
            fi
        done

        # 如果没有匹配的 key，则遍历 JSON 数据中的最里层的所有 key 和 value 并将其打印出来
        if [ "$match" == false ]; then
            printf "${RED}输入的${module_option_input}不匹配${NC}\n"
        else
            break
        fi
    done
}