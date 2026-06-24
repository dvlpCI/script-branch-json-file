#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: qtool_change.sh
### 

CurrentDIR_Script_Absolute="$( cd "$( dirname "$0" )" && pwd )"
# qtool_HomeDir_Absolute=${CurrentDIR_Script_Absolute%/*} # 使用此方法可以避免路径上有..
qtool_HomeDir_Absolute=${CurrentDIR_Script_Absolute}

sh "${qtool_HomeDir_Absolute}/qtool_env_change.sh" \
      --any-env-anme QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH \
      --action-type change \
      --env-descript "项目配置信息" \
      --env-var-placeholder "your_project_params_json_file" \
      --env-reference-json-file-example "${qtool_HomeDir_Absolute}/test/example_project_params.json" \
      --output-filename-if-copy "tool_input.json"
