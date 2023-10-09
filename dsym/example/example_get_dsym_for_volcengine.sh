#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-10-09 11:54:08
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-10-09 15:02:41
 # @Description: 
### 

# 指定dSYM文件所在的文件夹路径
CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"

dSYM_folder=${CurrentDIR_Script_Absolute}

parent_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
test_script_path=${parent_HomeDir_Absolute}/get_dsym_for_volcengine.sh

sh ${test_script_path} -appDSYMDir "${dSYM_folder}"