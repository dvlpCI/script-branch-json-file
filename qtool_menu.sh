#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 21:05:13
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

shift 1  # 去除前一个参数
allArgsExceptFirstArg="$@"  # 将去除前一个参数，剩余的参数赋值给新变量

allArgsOrigin="$@"
# 是不是包含 help 参数
contains_help_in_allArgs=false
for arg in $allArgsOrigin; do
    case $arg in
        --help|-help|-h|help)
            contains_help_in_allArgs=true
            break
            ;;
    esac
done

# 是不是包含 verbose 参数
contains_verbose_in_allArgs=false
for arg in $allArgsOrigin; do
    case $arg in
        --verbose|-verbose|-v)
            contains_verbose_in_allArgs=true
            break
            ;;
    esac
done

# 是不是包含 --qian 参数，打开关键调试命令的打印
DEFINE_QIAN=false
for arg in $allArgsOrigin; do
    case $arg in
        --qian|-qian|-lichaoqian|-chaoqian)
            DEFINE_QIAN=true
            break
            ;;
    esac
done

function qian_log() {
    # 只有定义 --qian 的时候才打印这个log
    if [ "$DEFINE_QIAN" = true ]; then
        echo "$1" >&2   # 使用 echo 信息里的颜色才能正常显示出来
        # printf "%s\n" "$1" >&2
    fi
}



source ${qtoolScriptDir_Absolute}/base/get_system_env.sh


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

_resolve_tool_params_file_path() {
    tool_params_file_path=${QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}
    if [[ $tool_params_file_path =~ ^~.* ]]; then
    # 如果 $tool_params_file_path 以 "~/" 开头，则将波浪线替换为当前用户的 home 目录
        tool_params_file_path="${HOME}${tool_params_file_path:1}"
    fi
    echo "${tool_params_file_path}"
}

# 环境变量检查--TOOL_PATH（才能保证可以正确创建分支）
checkEnvValue_TOOL_PARAMS_FILE_PATH() {
    if [ "${#QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH}" -eq 0 ]; then
        sh "${qtoolScriptDir_Absolute}/qtool_change.sh" "${qtoolScriptDir_Absolute}"
        if [ $? != 0 ]; then
            return 1
        fi
    fi
}

checkEnvValue_TOOL_PARAMS_FILE_PATH
if [ $? != 0 ]; then
    exit 1
fi

project_dir=$(get_sysenv_project_dir)
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
        elif [ $i = 4 ]; then
            iCatalogColor=${YELLOW}
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

    qian_log "${YELLOW}正在执行命令(打印自定义脚本目录，供你来选择后执行):《${BLUE} python3 \"${qtoolScriptDir_Absolute}/src/dealScriptByCustomChoose.py\" ${YELLOW}》${NC}"
    python3 "${qtoolScriptDir_Absolute}/src/dealScriptByCustomChoose.py"
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
    # valid_option=ture # 设为ture后，执行 evalActionByInput 时候，可以退出 while 循环
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
            # printf "====选中的操作项为======${RED}${tCatalogOutlineMap}${NC}\n"
            # tCatalogOutlineActionType=$(echo "$tCatalogOutlineMap" | jq -r ".action_type")
            
            tCatalogOutlineAction=$(echo "$tCatalogOutlineMap" | jq -r ".action")
            qian_log "正在执行的选中的菜单命令：${BLUE} eval \"$tCatalogOutlineAction\" ${NC}"
            eval "$tCatalogOutlineAction"
        else
            echo "无此选项，请重新输入。"
        fi
    done
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

# 显示工具选项
showMenu() {
    qtool_menu_using_json_file_path=$1
    tool_menu "${qtool_menu_using_json_file_path}"
    evalActionByInput "${qtool_menu_using_json_file_path}"
}

showMenu "${qtoolScriptDir_Absolute}/qtool_menu_public.json"    # 定义菜单选项


# 退出程序
exit 0
