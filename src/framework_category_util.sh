#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-07-03 19:53:44
# @FilePath: src/framework_category_util.sh
# @Description: 获取项目分类
###

# 显示分支模块列表_供分支创建时候使用
show_framework_category_forBranchCreate() {
    target_category_file_abspath=$1

    _show_framework_category "${target_category_file_abspath}" "forBranchCreate"
}

# 显示分支模块列表_供负责人查找时候使用
show_framework_category_md() {
    target_category_file_abspath=$1
    tempMdFilePath=$2

    _show_framework_category "${target_category_file_abspath}" "onlyMdFile"

    log_framework_category_md "${markdownString}" "${tempMdFilePath}"
}


_show_framework_category() {
    target_category_file_abspath=$1
    target_person_file_abspath=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    showType=$2
    
    # 读取文件内容
    content=$(cat "${target_category_file_abspath}")

    branchBelongKey2="branch_belong2"
    branchBelongMaps2=$(echo "$content" | jq -r ".${branchBelongKey2}")
    if [ -z "${branchBelongMaps2}" ] || [ "${branchBelongMaps2}" == "null" ]; then
        printf "${RED}请先在 ${target_category_file_abspath} 文件中设置 .${branchBelongKey2} ${NC}\n"
        exit 1
    fi

    # branchBelongMapCount2=$(echo "$content" | jq ".${branchBelongKey2}" | jq ".|length")
    # # echo "=============branchBelongMapCount2=${branchBelongMapCount2}"
    # if [ ${branchBelongMapCount2} -eq 0 ]; then
    #     echo "友情提醒💡💡💡：没有找到可选的分支模块类型"
    #     return 1
    # fi
    if [ "${showType}" == "forBranchCreate" ]; then
        echo "已知模块选项、已知基础选项："
    fi

    # 使用jq命令解析json数据
    categoryCount=$(echo "$content" | jq -r ".branch_belong2|length")
    # echo "===================${categoryCount}"
    if [ "${showType}" == "onlyMdFile" ]; then
        markdownString=""
        markdownString+="# 模块区分与负责人\n \n"
        markdownString+="## 一、模块区分与负责人\n"
        markdownString+="| $(printf '%-4s' "序号") | $(printf '%-8s' "标记") | $(printf '%-17s' "模块") | $(printf '%-4s' "功能") | $(printf '%-10s' "初始者") | $(printf '%-10s' "主开发") | $(printf '%-10s' "二开发") |\n"
        markdownString+="| ---- | -------- | ----------------- | ---- | ---------- | ---------- | ---------- |\n"

        printf "${NC}正在计算md内容，请耐心等待(预计需要5s)....${NC}\n"
    fi

    # 创建一个空数组
    moduleOptionKeys=()
    for ((categoryIndex = 0; categoryIndex < categoryCount; categoryIndex++)); do
        categoryMap_String=$(echo "$content" | jq -r ".branch_belong2[$categoryIndex]")
        # echo "$((categoryIndex+1)) categoryMap_String=${categoryMap_String}"

        categoryDes=$(echo "$categoryMap_String" | jq -r '.des')
        categoryValuesCount=$(echo "$categoryMap_String" | jq -r ".values|length")
        if [ "${showType}" == "forBranchCreate" ]; then
            printf "===================${categoryDes}(共${categoryValuesCount}个)===================\n"
        fi

        for ((categoryValueIndex = 0; categoryValueIndex < categoryValuesCount; categoryValueIndex++)); do

            categoryValueMap_String=$(echo "$categoryMap_String" | jq -r ".values[$categoryValueIndex]")
            # echo "$((categoryValueIndex+1)) categoryValueMap_String=${categoryValueMap_String}"

            option=$(echo "$categoryValueMap_String" | jq -r '.option')
            short_des=$(echo "$categoryValueMap_String" | jq -r '.short_des')
            detail_des=$(echo "$categoryValueMap_String" | jq -r '.detail_des')

            createrId=$(echo "$categoryValueMap_String" | jq -r '.creater')
            mainerId=$(echo "$categoryValueMap_String" | jq -r '.mainer')
            backuperId=$(echo "$categoryValueMap_String" | jq -r '.backuper')
            createrName=$(getPersonNameById "$target_person_file_abspath" "$createrId")
            mainerName=$(getPersonNameById "$target_person_file_abspath" "$mainerId")
            backuperName=$(getPersonNameById "$target_person_file_abspath" "$backuperId")

            if [ "${showType}" == "forBranchCreate" ]; then
                # printf "%10s: %-20s [%s %s %s] %s\n" "$option" "$short_des" "${createrName}" "${mainerName}" "${backuperName}" "${detail_des}"
                # 格式化字符串
                format_str="%10s: %-20s %s\n"
                consoleString=$(printf "$format_str" "$option" "$short_des" "${detail_des}")
                printf "${consoleString}\n"
            fi

            if [ "${showType}" == "onlyMdFile" ]; then
                # 构建Markdown表格
                # markdownString+="| %-8s    | %-8s | %-17s | %-4s | %-10s | %-10s |\n" "$categoryIndex.$categoryValueIndex" "$option" "$short_des" "$option" "$createrName" "$mainerName"
                multiline_detail_des=$(echo "$detail_des" | sed 's/;/<br>/g')
                markdownString+="| $(printf '%-4s' "$((categoryIndex+1)).$((categoryValueIndex+1))") | $(printf '%-8s' "$option") | $(printf '%-17s' "$short_des") | $(printf '%-4s' "$multiline_detail_des") | $(printf '%-10s' "$createrName") | $(printf '%-10s' "$mainerName") | $(printf '%-10s' "$backuperName") |\n"
                moduleOptionKeys+=("${option}")
            fi
        done
    done
}

# 根据 用户id 获取 用户名
getPersonNameById() {
    json_file="$1"
    person_id="$2"
    name=$(jq -r --arg person_id "$person_id" '.person[] | select(.id == ($person_id)) | .name' "$json_file") # 加 -r 是为了去掉引号
    echo "$name"
}

function log_framework_category_md() {
    markdown_string=$1
    tempMdFilePath="$2"

    # printf "${markdown_string}"
    # 检查Markdown文件是否存在
    if [[ $tempMdFilePath =~ ^~.* ]]; then
        # 如果 $tempMdFilePath 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        tempMdFilePath="${HOME}${tempMdFilePath:1}"
    fi
    printf "${NC}正在将内容输出到md文件 ${tempMdFilePath} 中....${NC}\n"

    echo "$markdown_string" >${tempMdFilePath} # 不使用追加，而是每次都重新覆盖
    # if [ -f "${tempMdFilePath}" ]; then
    #     # 如果文件存在，将Markdown表格追加到文件末尾
    #     echo "$markdown_string" >>${tempMdFilePath}
    # else
    #     # 如果文件不存在，将Markdown表格输出到新文件中
    #     echo "$markdown_string" >${tempMdFilePath}
    # fi

    printf "${GREEN}恭喜:功能/模块负责表生成完成，请前往 ${YELLOW}${tempMdFilePath} ${GREEN}中查看，已为你自动打开."
    open "${tempMdFilePath}"
}
