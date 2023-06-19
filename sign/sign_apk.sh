#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-24 19:18:57
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-19 19:01:20
 # @Description: 签名apk
### 

if [ $# -ne 3 ]; then
  echo "Usage: 参数个数错误，请重新处理（需要三个参数：分别为 签名使用的 properties 信息文件 \ 要签名的目录 \ 签名结果存放的路径）"
  exit 1
fi

sign_properties_file_path="$1"
# printf "${YELLOW}你所有的签名使用的信息来自文件:%s${NC}\n" "${sign_properties_file_path}"
sign_properties_map=$(cat ${sign_properties_file_path} | jq -r ".")
# echo "sign_properties_map=$sign_properties_map"


# 获取传递的参数，即APK文件夹的相对路径
apk_folder="$2"

# echo "apk_folder=$apk_folder"

# 构建APK文件夹的绝对路径
apk_folder_abspath="$(
  cd "$(dirname "$apk_folder")"
  pwd
)/$(basename "$apk_folder")"

# 创建signed文件夹用于存放签名后的APK文件
apkSignResult_dir_abspath="$3"
apk_signIdsig_folder_abspath="${apkSignResult_dir_abspath}/idsig"
mkdir -p "${apkSignResult_dir_abspath}"
mkdir -p "${apk_signIdsig_folder_abspath}"



# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
  exit 1
}

# 获取相对于指定文件的相对目录的绝对路径
function getAbsPathByFileRelativePath() {
    file_path=$1
    rel_path=$2

    file_parent_dir_path="$(dirname $file_path)"
    
    joinFullPath_checkExsit "${file_parent_dir_path}" "${rel_path}"
}

joinFullPath_checkExsit() {
  dir_path_this=$1
  path_rel_this_dir=$2
  createIfNoExsit=$3
  # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
  # path_rel_this_dir="../../"
  temp_result_path="$dir_path_this/$path_rel_this_dir"
  if [ ! -d "${temp_result_path}" ] && [ ! -f "${temp_result_path}" ]; then
    if [ "${createIfNoExsit}" == true ]; then
      mkdir "${temp_result_path}"
    else
      printf "${RED}❌Error:路径不存在:%s${NC}\n" "${temp_result_path}"
      return 1
    fi
  fi

  result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中
  if [ $? != 0 ]; then
    return 1
  fi
  echo $result_path
}



# 指定签名文件路径
keystore_file_path_rel_this_file=$(echo ${sign_properties_map} | jq -r ".keystore_file_rel_this_file")
keystore_file_abspath=$(getAbsPathByFileRelativePath "$sign_properties_file_path" $keystore_file_path_rel_this_file)
if [ $? != 0 ]; then
  printf "${RED}拼接 ${BLUE}${sign_properties_file_path} ${RED}和 ${BLUE}${keystore_file_path_rel_this_file} ${RED}组成的路径结果错误，错误结果为 ${keystore_file_abspath}${NC}\n"
  exit_script
fi
keystore_password=$(echo ${sign_properties_map} | jq -r ".keystore_password")
key_alias=$(echo ${sign_properties_map} | jq -r ".key_alias")
key_password=$(echo ${sign_properties_map} | jq -r ".key_password")
printf "${BLUE}签名脚本的实际参数为：\n keystore_file_abspath=%s\n keystore_password=%s\n key_alias=%s\n key_password=%s${NC}\n" "${keystore_file_abspath}" "${keystore_password}" "${key_alias}" "${key_password}"


function getBuildToolsVersionDir() {
  # 指定目录
  dir_path="$ANDROID_HOME/build-tools"

  # 获取目录下所有文件的列表
  files=("$dir_path"/*)

  # 从文件列表中筛选出版本号
  versions=()
  for file in "${files[@]}"; do
    version=$(basename "$file" | cut -d "-" -f 2)
    versions+=("$version")
  done

  # 选择最新的版本号
  latest_version=$(echo "${versions[@]}" | tr ' ' '\n' | sort -r | head -n 1)

  # 输出最新版本的路径
  build_tools_home_dir="$dir_path/$latest_version"
  echo "$build_tools_home_dir"

  if [ ! -d "${build_tools_home_dir}" ]; then
    return 1
  fi
}

function signApkFile() {
  apk_file=$1

  echo "Processing $apk_file"

  # 对APK进行对齐
  aligned_apk="${apk_file%%.apk}_aligned.apk" # apk_file%%.apk 表示从 apk_file 的末尾开始，删除最长的 .apk 子字符串，并返回剩余的部分。
  ${build_tools_home_dir}/zipalign -v 4 "$apk_file" "$aligned_apk"
  if [ $? != 0 ]; then
    printf "${RED}签名失败(对APK进行对齐):《 ${build_tools_home_dir}/zipalign -v 4 \"$apk_file\" \"$aligned_apk\" 》"
    exit_script
  fi

  # 签名对齐后的APK文件
  signed_apk="${aligned_apk%%.apk}_signed.apk"
  ${build_tools_home_dir}/apksigner sign --ks "$keystore_file_abspath" --ks-pass "pass:$keystore_password" --key-pass "pass:$key_password" --out "$signed_apk" --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --ks-key-alias "$key_alias" "$aligned_apk"
  if [ $? != 0 ]; then
    printf "${RED}签名失败(签名对齐后的APK文件):《 ${build_tools_home_dir}/apksigner sign --ks \"$keystore_file_abspath\" --ks-pass \"pass:$keystore_password\" --key-pass \"pass:$key_password\" --out \"$signed_apk\" --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true --ks-key-alias \"$key_alias\" \"$aligned_apk\" 》"
    exit_script
  fi

  # 将签名后的APK文件名中的"-sign_114_jiagu"替换为空字符串
  renamed_apk=$(echo "$signed_apk" | sed 's/-sign_[0-9]*//g')
  mv "$signed_apk" "${renamed_apk}"
  if [ $? != 0 ]; then
    printf "${RED}签名失败(重命名apk失败):《 mv \"$signed_apk\" \"${renamed_apk}\" 》"
    exit_script
  fi
  renamed_apkIdsig=$(echo "$signed_apk.idsig" | sed 's/-sign_[0-9]*//g')
  mv "$signed_apk.idsig" "${renamed_apkIdsig}"
  if [ $? != 0 ]; then
    printf "${RED}签名失败(重命名apk.idsig失败):《 mv \"$signed_apk.idsig\" \"${renamed_apkIdsig}\" 》"
    exit_script
  fi

  # 将签名后的文件移动到signed文件夹中，并更名为原始文件名
  mv -v "$renamed_apk" "${apkSignResult_dir_abspath}"
  mv -v "$renamed_apkIdsig" "${apk_signIdsig_folder_abspath}"
  rm -rf $aligned_apk
  # mv -v "$signed_apk" "${apk_folder_abspath}/signed/$(basename "$apk_file" .apk)_aligned_signed.apk"
}


# build_tools_version=32.0.0 # 个人机子测试
# build_tools_home_dir=$ANDROID_HOME/build-tools/${build_tools_version}
build_tools_home_dir=$(getBuildToolsVersionDir)
if [ $? != 0 ]; then
  printf "${RED}签名失败：未找到签名工具 ${YELLOW}$build_tools_home_dir ${RED}，请检查${NC}"
  exit_script
fi

# 使用find命令找到所有以.apk结尾的文件并循环处理
find "$apk_folder_abspath" -type f -name "*.apk" | while read apk_file; do
  signApkFile $apk_file
done

printf "${GREEN}恭喜:${YELLOW}${apk_folder_abspath} ${GREEN}下所有apk文件签名完成。签名结果存放在 ${BLUE}${apkSignResult_dir_abspath}${NC}\n"
printf "${BLUE}重复一遍之前打印的内容：签名脚本的实际参数为：\n keystore_file_abspath=%s\n keystore_password=%s\n key_alias=%s\n key_password=%s${NC}\n" "${keystore_file_abspath}" "${keystore_password}" "${key_alias}" "${key_password}"
