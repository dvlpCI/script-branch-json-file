#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-04-18 17:40:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-04-19 23:55:34
 # @FilePath: qtool_help.sh
 # @Description: qtool的help
### 

# echo "This is help"

cat << EOF
用法: $0 [选项]

选项:
  -qbase-local-path, --qbase-local-path PATH    qbase路径（默认: qbase）
  --no-use-brew-path                            qtool 里的其他脚本路径是否使用本地来拼接，而不是 brew 里的路径

  --qian, -qian, -lichaoqian, -chaoqian         调试模式
  --verbose, -v                                 详细信息
  --help, -h                                    帮助信息

示例:
  $0 --verbose --qian
  $0 --qbase-local-path /path/to/qbase
EOF