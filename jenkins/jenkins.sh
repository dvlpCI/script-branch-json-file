#!/bin/bash

###
# @Author: dvlproad
# @Date: 2023-04-13 10:40:15
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-06 14:16:48
# @Description:
###

# 下面是一个示例的 shell 脚本，它实现了以下功能：
# 1. 设置需要操作的 Jenkins 服务器的地址、用户名和 API token。
# 2. 列出所有的 Jenkins 作业。
# 3. 执行指定的 Jenkins 作业，并传递参数。
# 4. 等待作业执行完成，并检查作业执行结果。
# 5. 如果作业执行成功，则输出日志信息。

# 请注意，这个示例脚本需要使用 curl 命令和 Python 3 运行 Python 脚本。如果您的系统上没有安装 curl 和 Python 3，请先安装它们。

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

jenkinsScriptDir_Absolute=$1
if [ ${#jenkinsScriptDir_Absolute} -eq 0 ]; then
    echo "❌Error：请先设置jenkins脚本的绝对路径"
    exit 1
fi

temp_reslut_file_path=$2
if [ ${#temp_reslut_file_path} -eq 0 ]; then
    echo "❌Error：脚本内部出错，请检查"
    exit 1
fi

# 设置 Jenkins 服务器的地址、用户名和 API token
JENKINS_URL="http://192.168.72.202:8080"
JENKINS_USER="lichaoqian"
JENKINS_API_TOKEN="114a967bff5f8cc3a4803aea747f2ddec4"

# Function to encode URL
urlencode() {
    # urlencode <string>
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for ((i = 0; i < length; i++)); do
        local c="${1:i:1}"
        case $c in
        [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
        *) printf '%%%02X' "'$c" ;;
        esac
    done

    LC_COLLATE=$old_lc_collate
}

# List all jobs: 列出所有的 Jenkins 作业
list_jobs() {
    JENKINS_JOBS_URL="$JENKINS_URL/api/json?tree=jobs\[name\]"
    # echo "正在执行命令：《 curl -sS -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_JOBS_URL\" 》"
    jobs=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_JOBS_URL")
    # echo "=======job名分别为:\n$jobs"
    jobNames=$(echo "$jobs" | jq -r '.jobs[].name')
    # echo "======job名分别为:\n$jobNames"

    #   local url=$(urlencode "$JENKINS_URL")
    #   local jobs=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" "${url}/api/json?tree=jobs[name]")
    #   echo "Jobs:"
    #   echo "$jobs" | jq -r '.jobs[].name'
}

# Build a job
# build_job() {
#     local job_name="$1"
#     local url=$(urlencode "$JENKINS_URL")
#     echo "build_job url=$url"
#     local crumb=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" "${url}/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
#     echo "build_job crumb=$crumb"
#     local result=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" -X POST -H "$crumb" "${url}/job/${job_name}/build")
#     echo "Build result: $result"
# }

# # Get build status
# get_build_status() {
#     local job_name="$1"
#     local build_number="$2"
#     local url=$(urlencode "$JENKINS_URL")
#     local build=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" "${url}/job/${job_name}/${build_number}/api/json")
#     local result=$(echo "$build" | jq -r '.result')
#     echo "Build status: $result"
# }

# # Main program
# my_job="wish_android_测试"
# list_jobs
# build_job "$my_job"
# get_build_status "$my_job" "1"


# 执行指定的 Jenkins 作业，并传递参数
# JOB_NAME="test"

# JOB_NAME="wish_android_测试"
# PackageNetworkType=测试

# NotificatePeople=all
# MultiChannel=false
# UseDoKit=true


# echo  "正在执行命令:《 python3 ${jenkinsScriptDir_Absolute}/jenkins_input.py \"$temp_reslut_file_path\" 》"
python3 ${jenkinsScriptDir_Absolute}/jenkins_input.py "$temp_reslut_file_path"    # 内部含需交互的输入操作，所以结果先存到临时文件中

# JENKINS_JOB_URLs=$(python3 ${jenkinsScriptDir_Absolute}/jenkins_input_result_get.py "$temp_reslut_file_path")
# echo "-----------JENKINS_JOB_URLs=\n${JENKINS_JOB_URLs}"

# 读取temp_result.json文件中的jenkinsUrls字段的值
# jenkinsUrls=$(cat "${temp_reslut_file_path}" | jq -r '.jenkinsUrls[]')


buildResultJobs() {
    AllInterceptArrayKey="jenkinsUrls"
    jenkinsUrlCount=$(cat ${temp_reslut_file_path} | jq ".${AllInterceptArrayKey}" | jq ".|length")
    # echo "=============TEST_ROBOT_CONENT_COUNT=${TEST_ROBOT_CONENT_COUNT}"
    if [ ${jenkinsUrlCount} -eq 0 ]; then
        echo "友情提醒💡💡💡：没有找到可发送的测试数据"
        return 1
    fi

    happenError=false
    for (( i = 0; i < ${jenkinsUrlCount}; i++ )); do
        jenkinsUrl=$(cat "${temp_reslut_file_path}" | jq ".${AllInterceptArrayKey}" | jq -r ".[${i}]") # 添加 jq -r 的-r以去掉双引号
        # http://localhost:8080/job/xxx_iOS_测试/buildWithParameters? 获取job之后和buildWithParameters之前的job名
        job=${jenkinsUrl##*/job/}   # 先去掉job前面的部分
        jobName=${job%%/*}       # 再去掉buildWithParameters后面的部分
        buildJob "$jenkinsUrl"
        if [ $? != 0 ]; then
            happenError=true
        fi
        echo "✅[$((i+1))] $jobName 已开始执行"
    done
    if [ ${happenError} == false ]; then
        printf "${GREEN}恭喜：jenkins打包任务已启动${NC}\n"
    fi

    firstJenkinsUrl=$(cat "${temp_reslut_file_path}" | jq ".${AllInterceptArrayKey}" | jq -r ".[0]") # 添加 jq -r 的-r以去掉双引号
    jenkinsBaseUrl=${firstJenkinsUrl%%/job*}
    open "${jenkinsBaseUrl}"
}



buildJob() {
    # JENKINS_JOB_URL="$JENKINS_URL/job/$JOB_NAME/buildWithParameters?$PARAMS"
    JENKINS_JOB_URL=$1
    # echo "正在执行命令：《 curl -sS -X POST -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_JOB_URL\" 》"
    curl -sS -X POST -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_JOB_URL"
}

buildResultJobs



# # 等待作业执行完成，并检查作业执行结果
# echo "Waiting for the job to complete..."
# while true; do
#     result=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/api/json | jq -r '.result')
#     if [ "$result" != "null" ]; then
#         if [ "$result" = "SUCCESS" ]; then
#             echo "Job completed successfully!"
#             echo "Log:"
#             curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/consoleText
#             exit 0
#         else
#             echo "Job failed with result: $result"
#             exit 1
#         fi
#     fi
#     sleep 5
# done
