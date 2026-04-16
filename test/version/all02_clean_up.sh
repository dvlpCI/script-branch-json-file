#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-06-13 09:43:53
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-20 11:32:45
 # @Description: 整理已上线的json为版本version
### 


# shell 参数具名化
show_usage="args: [-jsonDir]\
                                  [--json-dir-path=]"

while [ -n "$1" ]
do
        case "$1" in
                -jsonDir|--json-dir-path) json_dir_path=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

json_dir_path=./bulidScript/featureBrances

#!/bin/bash
# 遍历目录下的所有 JSON 文件，将它们的路径存入数组中
json_files=()
for file in $json_dir_path/*.json; do
    if [ -f "$file" ]; then
        json_files+=("$file")
    fi
done

# 检查是否有 JSON 文件
if [ ${#json_files[@]} -eq 0 ]; then
    json_array="[]"
else
    # 构造 JSON 数组
    json_array="["
    for ((i=0; i<${#json_files[@]}; i++)); do
        # 读取 JSON 文件内容
        json=$(cat "${json_files[i]}")

        # 构造 JSON 数组元素
        if [ $i -eq 0 ]; then
            json_array+="$(echo "$json")"
        else
            json_array+=", $(echo "$json")"
        fi
    done
    json_array+="]"
fi

# 构造完整 JSON 对象
version="1.2.6"
online_time="06.06周二"
online_branches="{\"version\": \"$version\", \"online_time\": \"$online_time\", \"online_branches\": $json_array}"
echo "$online_branches"



# 将 JSON 对象添加到历史版本记录文件中
history_record_time=$(date "+%m.%d")
history_file="v${history_record_time}.json"
echo "$online_branches" > "$history_file"
