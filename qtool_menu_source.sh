#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 21:05:13
# @FilePath: qtool_menu_source.sh
# @Description: qtool 菜单的函数库（由 qtool_menu.sh source 使用）
###
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    qtoolScriptDir_Absolute="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

COMMON_FLAG_ARGS=${COMMON_FLAG_ARGS:-""}   # 来自 getopts 解析，dealScriptByCustomChoose() 需要
allArgsOrigin=${allArgsOrigin:-""}         # 来自原始入参，uploadDSYMAction() 需要

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

quitStrings=("q" "Q" "quit" "Quit" "n") # 输入哪些字符串算是想要退出

function qian_log() {
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2
    fi
}

branchJsonFileScriptDir_Absolute=$qtoolScriptDir_Absolute/src

rebaseScriptDir_Absolute=$qtoolScriptDir_Absolute/rebase

jenkinsScriptDir_Absolute=$qtoolScriptDir_Absolute/jenkins
temp_reslut_file_path=${qtoolScriptDir_Absolute}/src/temp_result.json
chmod u+wr "${temp_reslut_file_path}" # chmod 命令用于修改文件权限，u 表示修改文件所有者的权限，+wr 表示添加读取和写入权限。

# echo "branchJsonFileScriptDir_Absolute=${branchJsonFileScriptDir_Absolute}"
# echo "jenkinsScriptDir_Absolute=${jenkinsScriptDir_Absolute}"

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

openDocTodoBug() {
    openWebsitePage '.website.doc_todo_bug'
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

    printf "${BLUE}正在为你打开网址:${YELLOW}${doc_home_website} ${BLUE}，(如打开失败，请确认是否该地址失效)${NC}\n"
    open "${doc_home_website}"
    checkResultCode $?
}


openWebsiteByCustomChoose_fromProjectCustom() {
    python3 "${qtoolScriptDir_Absolute}/src/openWebsiteByCustomChoose.py" "custom"
    checkResultCode $?
}

openWebsiteByCustomChoose_fromSystemRecommend() {
    python3 "${qtoolScriptDir_Absolute}/src/openWebsiteByCustomChoose.py" "recommend"
    checkResultCode $?
}



_resolve_tool_params_file_path() {
    tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    if [[ $tool_params_file_path =~ ^~.* ]]; then
    # 如果 $tool_params_file_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        tool_params_file_path="${HOME}${tool_params_file_path:1}"
    fi
    echo "${tool_params_file_path}"
}


_gitBranch() {
    sh ${branchJsonFileScriptDir_Absolute}/branchGit_create.sh
}

# 分支信息文件的创建
createBranchJsonFile() {
    tool_params_file_path=$(_resolve_tool_params_file_path)
    # echo "${YELLOW}正在执行命令(分支信息文件的创建):《${BLUE} python3 \"${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py\" -tool_params_file_path \"${tool_params_file_path}\" ${YELLOW}》${NC}"
    python3 "${branchJsonFileScriptDir_Absolute}/branchJsonFile_create.py" -tool_params_file_path "${tool_params_file_path}"
    checkResultCode $?
}

# 分支信息文件的修改
updateBranchJsonFile() {
    tool_params_file_path=$(_resolve_tool_params_file_path)
    # echo "${YELLOW}正在执行命令(分支信息文件的修改):《${BLUE} python3 \"${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py\" -tool_params_file_path \"${tool_params_file_path}\" ${YELLOW}》${NC}"
    python3 ${branchJsonFileScriptDir_Absolute}/branchJsonFile_update.py -tool_params_file_path "${tool_params_file_path}"
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
# 3.1、执行自定义的脚本
dealScriptByCustomChoose() {
    # 注意，不要将 allArgsExceptFirstArg 的所有参数传递给 dealScriptByCustomChoose.py 因为该脚本里只接收几个参数而已

    qian_log "${GREEN}成功调起 $FUNCNAME 方法，正在执行其要求的命令(打印自定义脚本目录，供你来选择后执行):《${BLUE} python3 \"${qtoolScriptDir_Absolute}/src/dealScriptByCustomChoose.py\" ${COMMON_FLAG_ARGS[*]} ${GREEN}》${NC}"
    python3 "${qtoolScriptDir_Absolute}/src/dealScriptByCustomChoose.py" ${COMMON_FLAG_ARGS[*]} # 注意：${COMMON_FLAG_ARGS[*]} 不能加双引号，否则会被当成一个参数值，而不是多个参数
    checkResultCode $?
}


# 二、执行Jenkins上的Job
buildJenkinsJob() {
    # echo "正在执行命令：《 sh ${jenkinsScriptDir_Absolute}/jenkins.sh \"${temp_reslut_file_path}\" 》"
    sh ${jenkinsScriptDir_Absolute}/jenkins.sh "${temp_reslut_file_path}"
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
    tCatalogOutlineName=$(echo "$tCatalogOutlineMap" | jq -r ".key")
    tCatalogOutlineDes=$(echo "$tCatalogOutlineMap" | jq -r ".des")

    resultCode=$1
    if [ $resultCode = 0 ]; then
        printf "${GREEN}恭喜💐:您选择${YELLOW}%s${GREEN}操作已执行完成${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    elif [ $resultCode = 300 ]; then
        printf "${BLUE}温馨提示🤝:您选择${YELLOW}%s${RED}操作已退出${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    else
        printf "${RED}很遗憾😭:您选择${YELLOW}%s${RED}操作执行未执行/失败${NC}\n" "$option|$tCatalogOutlineName $tCatalogOutlineDes"
    fi
    # valid_option=ture # 设为ture后，执行 evalActionByInput 时候，可以退出 while 循环
}


uploadDSYMAction() {
    sh ${qtoolScriptDir_Absolute}/dsym/dsym_get_and_upload.sh "${allArgsOrigin}"
    checkResultCode $?
}

signApkAction() {
    python3 "${qtoolScriptDir_Absolute}/src/sign_apk_tool.py"
    checkResultCode $?
}

logFileMessageAction() {
    sh $qtoolScriptDir_Absolute/src/framework_category_showForResponsiblePerson.sh
    checkResultCode $?
}

checkUnuseImages() {
    python3 "${qtoolScriptDir_Absolute}/package-size/unuse_images.py"
    checkResultCode $?
}

decompileDexAction() {
    python3 "${qtoolScriptDir_Absolute}/src/decompile_dex.py"
    checkResultCode $?
}

decompileApkAction() {
    python3 "${qtoolScriptDir_Absolute}/src/decompile_apk.py"
    checkResultCode $?
}