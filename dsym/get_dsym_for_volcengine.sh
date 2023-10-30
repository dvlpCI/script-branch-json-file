#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-09 11:54:08
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-30 15:40:14
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
find $DWARF_DSYM_FOLDER_PATH -name "*.dSYM" | while read -r file; do 
    # 获取文件名（不包含扩展名）
    filename=$(basename "$file" .dSYM)
    # 将dSYM目录下的所有文件和子目录压缩文件为.zip格式，但会排除掉以.DS_Store结尾的文件和名为__MACOSX的子目录。
    # 区别于 -r ，通过在 zip 命令中添加 -j 选项，它将忽略源文件的路径信息，并将文件仅保存为 ZIP 文件中的文件名。这样生成的 ZIP 文件中将只包含文件名，而不会有深层的目录结构。
    zip -j "$output_single_zip_folder/$filename.zip" "$file" # -x "*.DS_Store" -x "__MACOSX"
    if [ $? != 0 ]; then
      echo "${RED}压缩 $((++count)) $file 失败，将退出执行火山dsym所需压缩文件的获取脚本。执行的命令是《${BLUE} zip -j \"$output_single_zip_folder\/$filename.zip\" \"$file\" ${RED}》${NC}"
      exit 1 # 这里的 exit 1 只会退出当前的子进程（即 while 循环），而不会直接退出整个 Shell 脚本。
    # else
    #   echo "${GREEN}压缩 $((++count)) $file 完成${NC}"
    fi
done
# 判断前面的循环是否有错误，如果有错则退出脚本
if [ $? != 0 ]; then
    exit 1
fi


# 指定整体压缩后的文件放置的目录
output_all_zip_folder="${DWARF_DSYM_FOLDER_PATH}/dsymAllZip"

# 创建整体压缩文件的目录
mkdir -p "$output_all_zip_folder"

# 将所有.zip文件整体压缩成一个all.zip文件
output_all_zip_file="$output_all_zip_folder/all.zip"
zip -j "$output_all_zip_file" "$output_single_zip_folder"/*.zip
if [ $? != 0 ]; then
      echo "${RED}进一步压缩 $output_single_zip_folder 下的所有zip文件为 $output_all_zip_file 失败，将退出执行火山dsym所需压缩文件的获取脚本。执行的命令是《${BLUE} zip -j \"$output_all_zip_file\" \"$output_single_zip_folder\"\/*.zip ${RED}》${NC}"
      exit 1
fi
volcengine="https://console.volcengine.com/apmplus/app/mapping?aid=502194&org_id=2100483024&os=iOS"
echo "${GREEN}整体压缩完成,地址为${BLUE} ${output_all_zip_file} ${GREEN}。请在页面 符号表管理${BLUE} $volcengine ${GREEN}上进行提交。${NC}"
open "$output_all_zip_folder" # 为你打开 ${output_all_zip_file} 所在的文件夹
open "$volcengine" # 为你打开火山引擎符号表的上传网页