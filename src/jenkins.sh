#!/bin/bash

###
 # @Author: dvlproad
 # @Date: 2023-04-13 10:40:15
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-04-13 19:28:12
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

# 列出所有的 Jenkins 作业
echo "正在执行命令：《 curl -sS -u \"$JENKINS_USER:$JENKINS_API_TOKEN\" \"$JENKINS_URL/api/json?tree=jobs[name]\" | jq -r '.jobs[].name' 》"
jobs=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_URL/api/json?tree=jobs[name]")
echo "job名分别为:$jobs"
jobNames=$(echo "$jobs" | jq -r '.jobs[].name')
echo "job名分别为:$jobNames"


# 执行指定的 Jenkins 作业，并传递参数
JOB_NAME="wish_android_测试"
PARAMS="ChangeLog=请忽略我&param2=value2"
build_url=$(curl -sS -X POST -u "$JENKINS_USER:$JENKINS_API_TOKEN" "$JENKINS_URL/job/$JOB_NAME/buildWithParameters?$PARAMS" | jq -r '.url')

# 等待作业执行完成，并检查作业执行结果
echo "Waiting for the job to complete..."
while true; do
    result=$(curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/api/json | jq -r '.result')
    if [ "$result" != "null" ]; then
        if [ "$result" = "SUCCESS" ]; then
            echo "Job completed successfully!"
            echo "Log:"
            curl -sS -u "$JENKINS_USER:$JENKINS_API_TOKEN" $build_url/consoleText
            exit 0
        else
            echo "Job failed with result: $result"
            exit 1
        fi
    fi
    sleep 5
done