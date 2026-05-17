#!/bin/bash
# 构建 Qtool 桌面端
# 编译 SwiftUI 源码 → gui/Qtool binary → 组装 gui/Qtool.app
# 用法: sh gui/build.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. 编译 SwiftUI 源码为可执行二进制
#    输入: gui/main.swift
#    依赖: SwiftUI.framework, Cocoa.framework
#    输出: gui/Qtool
echo "📦 编译 main.swift → Qtool ..."
swiftc -o "$SCRIPT_DIR/Qtool" "$SCRIPT_DIR/main.swift" \
    -framework SwiftUI -framework Cocoa -parse-as-library

# 2. 组装 .app 包目录结构
#    Qtool.app 是 macOS 应用包，双击即运行
#    MacOS/   → 二进制（程序入口）
#    Resources/ → 辅助脚本
echo "📁 组装 Qtool.app ..."
mkdir -p "$SCRIPT_DIR/Qtool.app/Contents/MacOS"
mkdir -p "$SCRIPT_DIR/Qtool.app/Contents/Resources"
cp "$SCRIPT_DIR/Qtool" "$SCRIPT_DIR/Qtool.app/Contents/MacOS/"
cp "$SCRIPT_DIR/qtool_run_action.sh" "$SCRIPT_DIR/Qtool.app/Contents/Resources/"

# 写入 Info.plist（macOS 识别 .app 必需的元信息）
cat > "$SCRIPT_DIR/Qtool.app/Contents/Info.plist" << 'PLIST'
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
</dict>
</plist>
PLIST

echo ""
echo "✅ 构建完成:"
echo "   $SCRIPT_DIR/Qtool        (二进制)"
echo "   $SCRIPT_DIR/Qtool.app    (可分发安装包)"
