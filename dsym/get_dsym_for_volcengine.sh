#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-09 11:54:08
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-09 15:24:37
 # @Description: 
### 

# 定义颜色常量
NC="\033[0m" # No Color
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
PURPLE="\033[0;35m"
CYAN="\033[0;36m"

# shell 参数具名化
while [ -n "$1" ]
do
        case "$1" in
                -appDSYMDir|--app-dsym-dir) DWARF_DSYM_FOLDER_PATH=$2; shift 2;; # 指定dSYM文件所在的文件夹路径
                --) break ;;
                *) echo ""; break ;;
        esac
done

# 指定压缩后的文件放置的目录
output_single_zip_folder="${DWARF_DSYM_FOLDER_PATH}/dsymZip"


# 创建输出目录
mkdir -p "$output_single_zip_folder"

# 遍历dSYM文件夹中的所有.dSYM文件
for file in "$DWARF_DSYM_FOLDER_PATH"/*.dSYM; do
  if [ -d "$file" ]; then # dSYM 是文件夹，而不是文件，不要判断错了
    # 获取文件名（不包含扩展名）
    filename=$(basename "$file" .dSYM)
    # 压缩文件为.zip格式
    # zip -r "$output_single_zip_folder/$filename.zip" "$file"
    # 将dSYM目录下的所有文件和子目录，但会排除掉以.DS_Store结尾的文件和名为__MACOSX的子目录。
    zip -r "$output_single_zip_folder/$filename.zip" "$file" -x "*.DS_Store" -x "__MACOSX"
    echo "压缩 $file 完成"
  fi
done


# 指定整体压缩后的文件放置的目录
output_all_zip_folder="${DWARF_DSYM_FOLDER_PATH}/dsymAllZip"

# 创建整体压缩文件的目录
mkdir -p "$output_all_zip_folder"

# 将所有.zip文件整体压缩成一个all.zip文件
output_all_zip_file="$output_all_zip_folder/all.zip"
zip -j "$output_all_zip_file" "$output_single_zip_folder"/*.zip
volcengine="https://console.volcengine.com/apmplus/app/mapping?aid=502194&org_id=2100483024&os=iOS"
echo "${GREEN}整体压缩完成,地址为${BLUE} ${output_all_zip_file} ${GREEN}。请在页面 符号表管理${BLUE} $volcengine ${GREEN}上进行提交。${NC}"
open "$output_all_zip_folder" # 为你打开 ${output_all_zip_file} 所在的文件夹
open "$volcengine" # 为你打开火山引擎符号表的上传网页