#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-04-23 13:18:33
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-06-14 10:45:11
 # @Description: 
# @FilePath: qtool_change.sh
### 

qtoolScriptDir_Absolute=$1
if [ -z "${qtoolScriptDir_Absolute}" ]; then
    echo "请传参 qtoolScriptDir_Absolute"
    exit 1
elif [ ! -d "${qtoolScriptDir_Absolute}" ]; then
    echo "qtoolScriptDir_Absolute=${qtoolScriptDir_Absolute}路径不存在，请检查"
    exit 1
fi

sh "${qtoolScriptDir_Absolute}/qtool_env_change.sh" \
      --any-env-anme QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH \
      --action-type change \
      --env-descript "项目配置信息" \
      --env-var-placeholder "your_project_params_json_file" \
      --env-reference-json-file-example "${qtoolScriptDir_Absolute}/test/example_project_params.json" \
      --output-filename-if-copy "tool_input.json"
