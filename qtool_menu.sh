#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-01 10:37:09
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
branchJsonFileScriptDir_Absolute=$qtoolScriptDir_Absolute/src

rebaseScriptDir_Absolute=$qtoolScriptDir_Absolute/rebase

jenkinsScriptDir_Absolute=$qtoolScriptDir_Absolute/jenkins
temp_reslut_file_path=${qtoolScriptDir_Absolute}/src/temp_result.json
chmod u+wr "${temp_reslut_file_path}" # chmod 命令用于修改文件权限，u 表示修改文件所有者的权限，+wr 表示添加读取和写入权限。

# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"
# echo "jenkinsScriptDir_Absolute=${jenkinsScriptDir_Absolute}"

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出

# 环境变量检查--TOOL_PATH（才能保证可以正确创建分支）
checkEnvValue_TOOL_PARAMS_FILE_PATH() {
    if [ "${#QTOOL_DEAL_PROJECT_DIR_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【要处理的项目路径】的环境变量，请open ~/.bash_profile 或 open ~/.zshrc后,将${BLUE}export QTOOL_DEAL_PROJECT_DIR_PATH=your_project_dir ${RED}添加到环境变量中(其中${YELLOW}your_project_dir${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -d "${QTOOL_DEAL_PROJECT_DIR_PATH}" ]; then
        printf "${RED}您设置的环境变量 QTOOL_DEAL_PROJECT_DIR_PATH=${QTOOL_DEAL_PROJECT_DIR_PATH} 目录不存在，请检查%s${NC}\n"
        return 1
    fi

    if [ "${#QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        printf "${RED}您还未设置【要处理的项目的配置信息】的环境变量，请open ~/.bash_profile 或 open ~/.zshrc后,将${BLUE}export QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH=yourToolParamsFileAbsolutePath ${RED}添加到环境变量中(其中${YELLOW}yourToolParamsFileAbsolutePath${RED}需替换成自己的项目实际绝对路径)%s${NC}\n"
        return 1
    fi
    if [ ! -f "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" ]; then
        printf "${RED}您设置的环境变量 QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH} 目录不存在，请检查%s${NC}\n"
        return 1
    fi

}

checkEnvValue_TOOL_PARAMS_FILE_PATH
if [ $? != 0 ]; then
    exit
fi

project_dir=${QTOOL_DEAL_PROJECT_DIR_PATH}
if [[ $project_dir =~ ^~.* ]]; then
    # 如果 $project_dir 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
    project_dir="${HOME}${project_dir:1}"
fi
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
        iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".category_values")
        iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
        if [ $i = 0 ]; then
            iCatalogColor=${BLUE}
        elif [ $i = 1 ]; then
            iCatalogColor=${PURPLE}
        elif [ $i = 2 ]; then
            iCatalogColor=${GREEN}
        elif [ $i = 3 ]; then
            iCatalogColor=${CYAN}
        else
            iCatalogColor=${YELLOW}
        fi
        for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
            iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
            iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".name")
            iCatalogOutlineDes=$(echo "$iCatalogOutlineMap" | jq -r ".des")
            
            iBranchOption="$((i + 1)).$((j + 1))|${iCatalogOutlineName}"
            printf "${iCatalogColor}%-25s%s${NC}\n" "${iBranchOption}" "$iCatalogOutlineDes" # 要拼接两个字符串，并在拼接的结果中，如果第一个字符串不够 15 位则自动补充空格到 15 位
        done
    done
}




# 打开移动端文档主页
openDocHome() {
    openWebsitePage '.website.doc_home'
}

openDocVersionPlan() {
    openWebsitePage '.website.doc_version_plan'
}

openDocWorkPlan() {
    openWebsitePage '.website.doc_work_plan'
}

# 打开指定的网页地址
openWebsitePage() {
    websiteKey=$1
    # 读取文件内容
    content=$(cat "${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}")
    doc_home_website=$(echo "$content" | jq -r "${websiteKey}")
    if [ -z "${doc_home_website}" ] || [ "${doc_home_website}" == "null" ]; then
        rebaseErrorMessage="请先在${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}文件中设置 ${websiteKey} "
        printf "${RED}%s${NC}\n" "${rebaseErrorMessage}"
        exit 1
    fi

    open "${doc_home_website}"
    checkResultCode $?
}

_gitBranch() {
    sh ${branchJsonFileScriptDir_Absolute}/branchGit_create.sh
}

# 分支信息文件添加
createBranchJsonFile() {
    # echo "正在执行命令:《 python3 \"${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py\" 》"
    python3 "${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py"
    checkResultCode $?
}

# 分支信息文件修改
updateBranchJsonFile() {
    python3 ${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py
    checkResultCode $?
}

# 将当前分支合并到其他分支前的rebase检查
rebaseCheckBranch() {
    sh ${rebaseScriptDir_Absolute}/pre-push.sh
    checkResultCode $?
}

rebaseHook() {
    sh ${rebaseScriptDir_Absolute}/pre-push-hook-copy.sh
    checkResultCode $?
}

updateMonitorPageKey() {
    echo "-----------"
    sh $qtoolScriptDir_Absolute/monitor/update_monitor_key.sh
    checkResultCode $?
}


# 按规范提交当前所有代码
pushGitCommitMessage() {
    sh $qtoolScriptDir_Absolute/commit/commit_message.sh
    checkResultCode $?
}

# 三、打包
# 3.1、更改环境
pack_updateEnv_action() {
    # echo "正在执行命令(更改环境):《 python3 \"${qtoolScriptDir_Absolute}/pack/pack_input.py\" 》"
    python3 "${qtoolScriptDir_Absolute}/pack/pack_input.py"
    checkResultCode $?
}

# 二、执行Jenkins上的Job
buildJenkinsJob() {
    # echo "正在执行命令：《 sh ${jenkinsScriptDir_Absolute}/jenkins.sh \"${jenkinsScriptDir_Absolute}\" \"${temp_reslut_file_path}\" 》"
    sh ${jenkinsScriptDir_Absolute}/jenkins.sh "${jenkinsScriptDir_Absolute}" "${temp_reslut_file_path}"
    checkResultCode $?
}

gitBranchAndJsonFile() {
    _gitBranch
    if [ $? != 0 ]; then
        exit 1
    fi

    # 是否继续
    newbranch=""
    printf "分支${RED}%s${NC}创建成功，是否继续创建分支信息文件.[继续y/退出n] : " "$newbranch"
    read -r continueNewbranch
    if echo "${quitStrings[@]}" | grep -wq "${continueNewbranch}" &>/dev/null; then
        echo "恭喜Git分支创建成功！"
        exit 0
    fi

    createBranchJsonFile
}

lastBranchJsonFile_update() {
    python3 "${branchJsonFileScriptDir_Absolute}/lastBranchJsonFile_update.py"
    checkResultCode $?
}

goPPDir() {
    pp_dir_path="~/Library/MobileDevice/Provisioning Profiles"
    if [[ $pp_dir_path =~ ^~.* ]]; then
        # 如果 $pp_dir_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        pp_dir_path="${HOME}${pp_dir_path:1}"
    fi
    open "$pp_dir_path"
    checkResultCode $?
}

goGitRefsRemotesDir() {
    python3 ${branchJsonFileScriptDir_Absolute}/git_project_choose.py
    checkResultCode $?
}

checkResultCode() {
    tCatalogOutlineName=$(echo "$tCatalogOutlineMap" | jq -r ".name")
    tCatalogOutlineDes=$(echo "$tCatalogOutlineMap" | jq -r ".des")

    resultCode=$1
    if [ $resultCode = 0 ]; then
        printf "${GREEN}恭喜💐:您选择${YELLOW}%s${GREEN}操作已执行完成${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    elif [ $resultCode = 300 ]; then
        printf "${BLUE}温馨提示🤝:您选择${YELLOW}%s${RED}操作已退出${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    else
        printf "${RED}很遗憾😭:您选择${YELLOW}%s${RED}操作执行未执行/失败${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    fi
    valid_option=ture
}



evalActionByInput() {
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
            sh "${qtoolScriptDir_Absolute}/qtool_change.sh" "${qtoolScriptDir_Absolute}"
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
            iCatalogOutlineMaps=$(echo "$iCatalogMap" | jq -r ".category_values")
            iCatalogOutlineCount=$(echo "$iCatalogOutlineMaps" | jq '.|length')
            hasFound=false
            for ((j = 0; j < ${iCatalogOutlineCount}; j++)); do
                iCatalogOutlineMap=$(echo "$iCatalogOutlineMaps" | jq -r ".[${j}]") # 添加 jq -r 的-r以去掉双引号
                iCatalogOutlineName=$(echo "$iCatalogOutlineMap" | jq -r ".name")
                
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
            tCatalogOutlineAction=$(echo "$tCatalogOutlineMap" | jq -r ".action")
            # printf "正在执行命令：${BLUE}%s${NC}\n" "${tCatalogOutlineAction}"
            eval "$tCatalogOutlineAction"
        else
            echo "无此选项，请重新输入。"
        fi
    done
}

uploadDSYMAction() {
    sh ${qtoolScriptDir_Absolute}/dsym/bugly_upload.sh
    checkResultCode $?
}

checkUnuseImages() {
    python3 "${qtoolScriptDir_Absolute}/package-size/unuse_images.py"
    checkResultCode $?
}


# 显示工具选项
showMenu() {
    qtool_menu_using_json_file_path=$1
    tool_menu "${qtool_menu_using_json_file_path}"
    evalActionByInput "${qtool_menu_using_json_file_path}"
}

showMenu "${qtoolScriptDir_Absolute}/qtool_menu_public.json"    # 定义菜单选项


# 退出程序
exit 0
