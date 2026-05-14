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

sh "${qtoolScriptDir_Absolute}/qbase_env_change.sh" \
      "${qtoolScriptDir_Absolute}" \
      --choices-env QTOOL_DEAL_PROJECT_CHOICES_PATH \
      --target-env QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH \
      --placeholder "your_project_choices_json_file" \
      --action change \
      --desc-not-set "您还未添加项目选择列表可操作的项目的环境变量" \
      --desc-file-not-found "您用来配置所有可操作项目的环境变量"

# if [ -z "${QTOOL_DEAL_PROJECT_CHOICES_PATH}" ]; then
#     addEnvPlaceHolder
#     if [ $? != 0 ]; then
#         exit 1
#     fi
#     printf "${RED}请先按以上提示，完成添加修改，再继续!${NC}"
#     exit 1
# else
#     checkFile
# fi
