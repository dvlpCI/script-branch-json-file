#!/bin/bash
###
 # @Author: dvlproad
 # @Date: 2023-05-06 14:57:41
 # @LastEditors: dvlproad
 # @LastEditTime: 2023-05-24 19:32:36
 # @Description: 
### 


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

joinFullPath_noCheck() {
    dir_path_this=$1
    path_rel_this_dir=$2
    # dir_path_this="/Users/qian/Project/CQCI/script-branch-json-file/test/"
    # path_rel_this_dir="../../"
    temp_result_path="$dir_path_this/$path_rel_this_dir"
    result_path=$(realpath "$temp_result_path") # shell 获取文件或文件夹的绝对路径，保存到临时变量中
    
    echo $result_path
}
