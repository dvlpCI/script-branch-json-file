#!/bin/sh

# 使用方法:
#---项目文件夹/-----
#---项目文件夹/APP/test.ipa(需要签名的IPA）
#---项目文件夹/Payload（新建导出IPA文件路径）
#---项目文件夹/Temp（IPA解压的临时数据APP）
#---项目文件夹/embedded.mobileprovision（某可安装APP包：显示包内容，里面的文件，证书文件信息）
#---项目文件夹/new_provision.plist（从embedded.mobileprovision解析证书需要的plist,或手动生成）
#---项目文件夹/new_entitlements.plist（根据证书解析的plist的生产entitlements.plist，用于签名
#---项目文件夹/test.mobileprovision（新可以用的签名证书->生产对应的embedded.mobileprovision）
#---项目文件夹/export_resign_app.sh（签名脚本名字）

#终端执行：直接把脚本export_resign_app.sh 拖到终端 回车执行

# # 获取当前脚本所在目录
# script_dir="$(cd "$(dirname "$0")" && pwd)"
# # 工程根目录
# project_dir=$script_dir
# # 时间
# DATE=$(date '+%Y%m%d_%H%M%S')

echo "\n\033[32m+++++++++++++++++开始：项目路径+++++++++++++++++\033[0m"

#放入xcode的sh中的
# ${SRCROOT} 它是工程文件所在的目录（xcode的默认路径）
# BUILT_PRODUCTS_DIR 工程生成的APP包的路径（xcode的默认路径）
# TARGET_NAME target名称（xcode的默认路径）

# #自定义
# SRCROOT="$script_dir"
# #导出APP路径
# BUILT_PRODUCTS_DIR="${SRCROOT}/Payload"
# #APP文件命名
# TARGET_NAME="NewAPP"

# 项目三方重签证书(可通过在终端运行 security find-identity -v -p codesigning 来获取) 
# 证书名或者证书上SHA-1(显示的字符串，不需求空格),二者都可以
# EXPANDED_CODE_SIGN_IDENTITY="Apple Development: xxx (S8****VL)"
# EXPANDED_CODE_SIGN_IDENTITY="A2AB7AF90****8C7D889E"
EXPANDED_CODE_SIGN_IDENTITY="Apple Development: chaoqian li (L4V8UVH3CZ)"

#bundle_id
PRODUCT_BUNDLE_IDENTIFIER="com.dvlproad.TSDemoDemo"
# 新证书授权文件(本地可以安装的APP，显示包内容
# TARGET_MOBILEPROVISION_PATH="$SRCROOT/test.mobileprovision"
TARGET_MOBILEPROVISION_PATH="/Users/qian/Documents/重签名/TSDemoDemo.app/embedded.mobileprovision"
# #直接把上面文件重命名，用于后续签名（后面是重新复制命名）
# ORIGIN_MOBILEPROVISION_PATH="$SRCROOT/embedded.mobileprovision"
ORIGIN_MOBILEPROVISION_PATH="/Users/qian/Documents/重签名/TSOverlayDemo.app/embedded.mobileprovision"

# #手动创建修改的plist
# RE_SIGN_NEW_ENTITLEMENST="$SRCROOT/new_entitlements.plist"
RE_SIGN_NEW_ENTITLEMENST="/Users/qian/Documents/重签名/plist_from_mp.plist"

# #手动解析证书授权文件的关键信息，
# NEW_PROVISION="$SRCROOT/new_provision.plist"

# echo "\n\033[32m=======1、自动 获取正确的配置文件+++++++++++++++++\033[0m"

# 将新证书授权文件覆盖旧的【embedded.mobileprovision】
cp "$TARGET_MOBILEPROVISION_PATH" "$ORIGIN_MOBILEPROVISION_PATH"
# #上面用手动的

# security cms -D -i "$ORIGIN_MOBILEPROVISION_PATH" >"$NEW_PROVISION"
# /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' "$NEW_PROVISION" | tee "$RE_SIGN_NEW_ENTITLEMENST"

# echo "\n\033[32m========2、解压IPA 到Temp,(解压出来的.app拷贝Payload)路径+++++++++++++++++\033[0m"

# #----------------------------------------

# TEMP_PATH="${SRCROOT}/Temp"
# #资源文件夹，我们提前在工程目录下新建一个APP文件夹，里面放ipa包
# ASSETS_PATH="${SRCROOT}/APP"
# #目标ipa包路径
# TARGET_IPA_PATH="${ASSETS_PATH}/*.ipa"

# #清空Temp文件夹
# rm -rf "${SRCROOT}/Temp"
# mkdir -p "${SRCROOT}/Temp"

# #----------------------------------------
# # 1. 解压IPA到Temp下
# unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
# # 拿到解压的临时的APP的路径
# TEMP_APP_PATH=$(
#     set -- "$TEMP_PATH/Payload/"*.app
#     echo "$1"
# )
# # echo "路径是:$TEMP_APP_PATH"

# #----------------------------------------
# # 2. 将解压出来的.app拷贝进入工程下

# TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
TARGET_APP_PATH="/Users/qian/Documents/重签名/TSOverlayDemo.app"
echo "app路径:$TARGET_APP_PATH"

# rm -rf "$TARGET_APP_PATH"
# mkdir -p "$TARGET_APP_PATH"
# cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH"

# #----------------------------------------
# # 3. 删除extension和WatchAPP.个人证书没法签名Extention
# rm -rf "$TARGET_APP_PATH/PlugIns"
# rm -rf "$TARGET_APP_PATH/Watch"

# echo "\033[32m========3、info.plist+++++++++++++++++\033[0m"

# #----------------------------------------
# # 4. 更新info.plist文件 CFBundleIdentifier
# #  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"
# /usr/libexec/PlistBuddy -c "Set :CFBundleName $TARGET_NAME" "$TARGET_APP_PATH/Info.plist"
# #----------------------------------------

# # 5. 给MachO文件上执行权限
# # 拿到MachO文件的路径
# APP_BINARY="plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d>|cut -f1 -d<"
# #上可执行权限
# chmod +x "$TARGET_APP_PATH/$APP_BINARY"

#----------------------------------------
# 6. 重签名第三方 FrameWorks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ]; then
    for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*; do

        # 三方重签名
        /usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
    done
fi

/usr/bin/codesign -fs "$EXPANDED_CODE_SIGN_IDENTITY" --entitlements="$RE_SIGN_NEW_ENTITLEMENST" "$TARGET_APP_PATH"

# #----------------------------------------
# # 7.压缩包
# zip -qr "$SRCROOT/$TARGET_NAME.ipa" "${BUILT_PRODUCTS_DIR}/"

# echo "\n\n\033[32m======== 签名APP导出路径：${TARGET_APP_PATH} +++++++++++++++++\033[0m"
# echo "\n\033[32m======== 签名证书：${EXPANDED_CODE_SIGN_IDENTITY} +++++++++++++++++\033[0m"
# echo "\n\033[32m======== 签名证书plist：${RE_SIGN_NEW_ENTITLEMENST} +++++++++++++++++\033[0m"
# echo "\n\033[32m======== 导出IPA: ${SRCROOT}/${TARGET_NAME}.ipa +++++++++++++++++\033[0m\n"

exit 0
