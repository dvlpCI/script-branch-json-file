#!/bin/bash

###
# @Author: dvlproad dvlproad@163.com
# @Date: 2023-04-12 22:15:22
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-20 10:49:28
# @FilePath: qtool_runenv.sh
# @Description: 检查安装环境
###

qtoolScriptDir_Absolute=$1


checkRunEnvironment() {
    sh "${qtoolScriptDir_Absolute}/common/install_package.sh" "jq"
}


checkRunEnvironment