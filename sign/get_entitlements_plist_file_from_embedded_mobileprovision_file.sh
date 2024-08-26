#!/bin/sh
# 从 embedded.mobileprovision 获取生成签名需要的 entitlements.plist
# 参考文档：[PlistBuddy 对plist文件的操作](https://blog.csdn.net/ZHFDBK/article/details/130948132)
# 原理：将 Entitlements_plist_file 文件中 从 <key>Entitlements</key> 行开始到 <key>ExpirationDate</key> 之间的每一行添加到新文件中
# <key>Entitlements</key>
# 	<dict>
		
# 				<key>application-identifier</key>
# 		<string>8285LLMDV3.com.dvlproad.TSDemoDemo</string>
				
# 				<key>keychain-access-groups</key>
# 		<array>
# 				<string>8285LLMDV3.*</string>
# 		</array>
				
# 				<key>get-task-allow</key>
# 		<true/>
				
# 				<key>com.apple.developer.team-identifier</key>
# 		<string>8285LLMDV3</string>

# 	</dict>
# 	<key>ExpirationDate</key>


# 使用方法:

# shell 参数具名化
while [ -n "$1" ]
do
    case "$1" in
        # 新证书授权文件(可以从本地可以真机安装的APP，中通过显示包内容来看到)
        -embedded_mobileprovision_F|--embedded-mobileprovision-file-path) Embedded_MOBILEPROVISION_PATH=$2; shift 2;; # 本分支【当前打包】的所有分支名数组字符串
        # 通过 embedded.mobileprovision 得到的 entitlements.plist 所希望存放的路径
        -entitlements_plist_hope_path|--entitlements_plist_file_path) Entitlements_plist_file=$2; shift 2;; # 本分支【当前打包】的所获得的所有分支名数组是从哪个时间点开始获取来的
        --) break ;;
        *) break ;;
    esac
done


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


function debug_log() {
	echo "$1" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
}



# 将 mobileprovision 转换为 plist 格式
embedded_is_in_directory=$(dirname "$Embedded_MOBILEPROVISION_PATH")
embedded_plist_file="${embedded_is_in_directory}/embedded.plist"
security cms -D -i "${Embedded_MOBILEPROVISION_PATH}" > "$embedded_plist_file"
# open $embedded_plist_file


# 使用PlistBuddy创建plist文件，并添加键值对
if [ -f "Entitlements_plist_file" ]; then
    rm Entitlements_plist_file
fi

# 从源 embedded_plist_file 文件中提取指定字段的值
# key1="AppIDName"
# value1=$(/usr/libexec/PlistBuddy -c "Print :$key1" "$embedded_plist_file")
# echo "===== 字符串: $value1"
# /usr/libexec/PlistBuddy -c "Add :$key1 string $value1" "$Entitlements_plist_file"


# # 创建 plist 文件并添加键值对
# cat << EOF > "$Entitlements_plist_file"
# <?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>key1</key>
#     <string>value1</string>
# </dict>
# </plist>
# EOF
# open $Entitlements_plist_file
# exit 1


# 创建 plist 文件，及添加签名的行
debug_log "${GREEN}======创建 Entitlements 的 plist 文件，及添加前面的行======${NC}"
cat << EOF > "$Entitlements_plist_file"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
EOF


debug_log "${GREEN}======为 Entitlements 的 plist 文件添加真正的内容的行======${NC}"
start_pattern="<key>Entitlements</key>"
end_pattern="<key>ExpirationDate</key>"
line_num=1
canUse=false
while read -r line; do
    if [[ $line == *"${start_pattern}"* ]]; then
        # echo "$line_num $line"
        # echo "这是开头的标记"
        canUse=true
        
    elif [[ $line == *"${end_pattern}"* ]]; then
        # echo "$line_num $line"
        # echo "这是结尾的标记"
        canUse=false

    else
        if $canUse; then
            debug_log "$line_num $line"
            echo "$line" >> "$Entitlements_plist_file"    # 在文件末尾添加一行
        fi
    fi
    line_num=$((line_num+1))
done < $embedded_plist_file

debug_log "${GREEN}======为 Entitlements 的 plist 文件添加尾部的行======${NC}"
echo "</plist>" >> "$Entitlements_plist_file"    # 在文件末尾添加一行
# open $Entitlements_plist_file
