#!/bin/bash
# 构建 Qtool 桌面端 — 支持多菜单源
# 编译 SwiftUI 源码 → gui/Qtool binary → 组装 gui/Qtool.app
# 用法: 多菜单源，自定义显示名
#   sh gui/build.sh \
#       -jsonFile /path/to/qbase_custom_menu.json -categoryType custom -name "qbase" \
#       -jsonFile /path/to/qtool_menu_public.json -categoryType catalog -name "qtool" \
#       [-output /path/to]
# 用法示例： sh qtool_gui.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="${TMPDIR:-/tmp}/qtool_gui_build_$$"

# ---- 解析参数 ----
declare -a JSON_FILES=()
declare -a CATEGORY_TYPES=()
declare -a NAMES=()
DEST_PATH=""

while [ $# -gt 0 ]; do
    case "$1" in
        -jsonFile)      JSON_FILES+=("$2"); shift 2 ;;
        -categoryType)  CATEGORY_TYPES+=("$2"); shift 2 ;;
        -name)          NAMES+=("$2"); shift 2 ;;
        -output)        DEST_PATH="$2"; shift 2 ;;
        *)              echo "❌ 未知参数: $1"; exit 1 ;;
    esac
done

if [ ${#JSON_FILES[@]} -eq 0 ] || [ ${#CATEGORY_TYPES[@]} -eq 0 ]; then
    echo "❌ 至少需要一组 -jsonFile 和 -categoryType"
    echo "用法: sh gui/build.sh -jsonFile <path> -categoryType <key> [-name \"显示名\"] [-jsonFile <path> -categoryType <key> -name \"显示名\" ...]"
    exit 1
fi

if [ ${#JSON_FILES[@]} -ne ${#CATEGORY_TYPES[@]} ]; then
    echo "❌ -jsonFile 和 -categoryType 数量不匹配"
    exit 1
fi

# 补齐 name（未提供则用文件名）
while [ ${#NAMES[@]} -lt ${#JSON_FILES[@]} ]; do
    idx=${#NAMES[@]}
    NAMES+=("$(basename "${JSON_FILES[$idx]}")")
done

for f in "${JSON_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        echo "❌ 文件不存在: $f"
        exit 1
    fi
done

# ---- 1. 编译（使用临时目录） ----
echo "📦 编译 main.swift → Qtool ..."
mkdir -p "$BUILD_DIR"
swiftc -o "$BUILD_DIR/Qtool" "$SCRIPT_DIR/main.swift" \
    -framework SwiftUI -framework Cocoa -parse-as-library

# ---- 2. 组装 .app ----
echo "📁 组装 Qtool.app ..."
rm -rf "$BUILD_DIR/Qtool.app"
mkdir -p "$BUILD_DIR/Qtool.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/Qtool.app/Contents/Resources"
cp "$BUILD_DIR/Qtool" "$BUILD_DIR/Qtool.app/Contents/MacOS/"
cp "$SCRIPT_DIR/qtool_run_action.sh" "$BUILD_DIR/Qtool.app/Contents/Resources/"

# 生成 QBMenuSources 数组（含原始路径，app 运行时直接读源文件）
SOURCES_XML=""
for i in "${!JSON_FILES[@]}"; do
    f="${JSON_FILES[$i]}"
    t="${CATEGORY_TYPES[$i]}"
    n="${NAMES[$i]}"
    echo "   📄 [$t] $(basename "$f") → \"$n\""
    SOURCES_XML="$SOURCES_XML
        <dict>
            <key>file</key>
            <string>$f</string>
            <key>type</key>
            <string>$t</string>
            <key>name</key>
            <string>$n</string>
        </dict>"
done

# 写入 Info.plist
cat > "$BUILD_DIR/Qtool.app/Contents/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>Qtool</string>
    <key>CFBundleIdentifier</key>
    <string>com.qbase.Qtool</string>
    <key>CFBundleName</key>
    <string>Qtool</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>QBMenuSources</key>
    <array>$SOURCES_XML
    </array>
</dict>
</plist>
PLIST

# ---- 3. 输出到目标路径 ----
if [ -n "$DEST_PATH" ]; then
    DEST_PATH="${DEST_PATH/#\~/$HOME}"
    mkdir -p "$DEST_PATH"
    rm -rf "$DEST_PATH/Qtool.app"
    cp -R "$BUILD_DIR/Qtool.app" "$DEST_PATH/"
    echo ""
    echo "✅ 已输出到: $DEST_PATH/Qtool.app"
elif [ -t 0 ]; then
    echo ""
    read -p "📋 输出路径？(yes=桌面 / 输入路径 / 回车=不拷贝): " dest
    if [ "$dest" = "yes" ] || [ "$dest" = "y" ]; then
        DEST_PATH="$HOME/Desktop"
    elif [ -n "$dest" ]; then
        DEST_PATH="${dest/#\~/$HOME}"
    fi

    if [ -n "$DEST_PATH" ]; then
        mkdir -p "$DEST_PATH"
        rm -rf "$DEST_PATH/Qtool.app"
        cp -R "$BUILD_DIR/Qtool.app" "$DEST_PATH/"
        echo ""
        echo "✅ 已输出到: $DEST_PATH/Qtool.app"
    fi
fi

# 如果源码目录可写，保留一份二进制方便开发
if [ -w "$SCRIPT_DIR" ]; then
    cp "$BUILD_DIR/Qtool" "$SCRIPT_DIR/Qtool" 2>/dev/null
fi
# 清理临时目录
rm -rf "$BUILD_DIR"

echo ""
echo "✅ 构建完成:"
if [ -n "$DEST_PATH" ]; then
    echo "   $DEST_PATH/Qtool.app"
fi
if [ -w "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/Qtool" ]; then
    echo "   $SCRIPT_DIR/Qtool        (二进制)"
fi
