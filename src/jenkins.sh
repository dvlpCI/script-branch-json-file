#!/bin/bash

###
# @Author: dvlproad
# @Date: 2023-04-13 10:40:15
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-17 16:07:03
# @Description:
###

# 下面是一个示例的 shell 脚本，它实现了以下功能：
# 1. 设置需要操作的 Jenkins 服务器的地址、用户名和 API token。
# 2. 列出所有的 Jenkins 作业。
# 3. 执行指定的 Jenkins 作业，并传递参数。
# 4. 等待作业执行完成，并检查作业执行结果。
# 5. 如果作业执行成功，则输出日志信息。

# 请注意，这个示例脚本需要使用 curl 命令和 Python 3 运行 Python 脚本。如果您的系统上没有安装 curl 和 Python 3，请先安装它们。

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
    echo "正在执行命令：《 curl -sS -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_JOBS_URL\" 》"
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



# 获取job参数
JOB_NAMES=("wish_iOS_测试" "wish_android_测试")
# 简单
# PARAMS="PackageNetworkType=${PackageNetworkType}&ChangeLog=${ChangeLog}&NotificatePeople=${NotificatePeople}&MultiChannel=${MultiChannel}&UseDoKit=${UseDoKit}"

# 自动
jobParams='{
  "PackageNetworkType": "测试",
  "NotificatePeople": "all",
  "MultiChannel":"false",
  "UseDoKit": "true"
}'

# jobParams=$(echo ${jobParams} | jq --arg job_name "${JOB_NAME}" '. + {jobName: $job_name}')

# ChangeLog="Please ignore me"
ChangeLog=$(git log -1 --pretty=format:'%an %s')
ChangeLog=$(urlencode "$ChangeLog") # 避免出现空格
jobParams=$(echo ${jobParams} | jq --arg ChangeLog "${ChangeLog}" '. + {ChangeLog: $ChangeLog}')

# encoded_jobParams=$(echo ${jobParams})
encoded_jobParams=$(echo ${jobParams} | jq -r @uri)
PARAMS=$(echo ${encoded_jobParams} | sed 's/%0A/\&/g')



JENKINS_JOB_URL="$JENKINS_URL/job/$JOB_NAME/buildWithParameters?$PARAMS"
echo "正在执行命令：《 curl -sS -X POST -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_JOB_URL\" 》"
exit
job_url=$(curl -sS -X POST -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_JOB_URL")
echo "======job_url:$job_url"
build_url=$(echo "$job_url" | jq -r '.url')
echo "======build_url:$build_url"

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
