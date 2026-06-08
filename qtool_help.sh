#!/bin/bash
###
 # @Author: dvlproad dvlproad@163.com
 # @Date: 2023-04-18 17:40:33
 # @LastEditors: dvlproad dvlproad@163.com
 # @LastEditTime: 2026-06-08
 # @FilePath: qtool_help.sh
 # @Description: qtool的help
###

NC='\033[0m'
GREEN='\033[32m'
BLUE='\033[34m'

printf "用法: qtool [命令] [选项]\n\n"

printf "${GREEN}Commands:${NC}\n"
printf "    ${GREEN}+ cz${NC}                规范化 Git 提交\n"
printf "    ${GREEN}+ help${NC}              显示帮助信息\n"
printf "    ${GREEN}+ gui${NC}              构建 Qtool.app（桌面端）\n"

printf "\n${BLUE}Options:${NC}\n"
printf "    ${BLUE}-qbase-local-path${NC}    依赖的子库 qbase 使用指定的路径（默认: qbase）\n"
printf "    ${BLUE}--no-use-brew-path${NC}   qtool 脚本使用本地路径而非 brew 路径\n"
printf "    ${BLUE}--qian${NC}               开启打印调试 log 模式\n"
printf "    ${BLUE}--verbose${NC}            详细信息\n"
printf "    ${BLUE}--version${NC}            显示版本号\n"
printf "    ${BLUE}--help${NC}               显示帮助信息\n"

printf "\n${BLUE}Examples:${NC}\n"
printf "    qtool --qian\n"
printf "    qtool cz\n"
printf "    qtool gui\n"
printf "    qtool --qbase-local-path /path/to/qbase\n"
