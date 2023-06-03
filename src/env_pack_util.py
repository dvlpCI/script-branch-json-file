'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-06-02 19:21:36
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import json
import subprocess
from path_util import joinFullPath, joinFullUrl
from env_util import getEnvValue_params_file_data, getEnvValue_project_dir_path

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


def getEnvValue_pack_path_rel_home_map():
    data = getEnvValue_params_file_data()
    if data == None:
        return None
    pack_path_rel_home_map = data['project_path']['pack_path_rel_home']
    if pack_path_rel_home_map == None:
        return None
    else:
        return pack_path_rel_home_map  
    
def getEnvValue_android_signScript_map():
    pack_path_rel_home_map = getEnvValue_pack_path_rel_home_map()
    if pack_path_rel_home_map == None:
        return None
    android_signScript_map = pack_path_rel_home_map['android_sign_script']
    if android_signScript_map == None:
        return None
    else:
        return android_signScript_map  

def getEnvValue_android_waitSignApk_map():
    pack_path_rel_home_map = getEnvValue_pack_path_rel_home_map()
    if pack_path_rel_home_map == None:
        return None
    android_waitSignApk_map = pack_path_rel_home_map['android_waitSignApk']
    if android_waitSignApk_map == None:
        return None
    else:
        return android_waitSignApk_map  

# 获取环境变量的值-打包参数信息文件的存放路径
def getEnvValue_pack_input_params_file_path():
    project_home_dir_path = getEnvValue_project_dir_path()
    
    pack_path_rel_home_map = getEnvValue_pack_path_rel_home_map()
    if pack_path_rel_home_map == None:
        return None
    
    pack_input_params_file_path_relhome = pack_path_rel_home_map['pack_input_params_file_RELATIVE_HOME']
    pack_input_params_file_abspath = joinFullPath(project_home_dir_path, pack_input_params_file_path_relhome)
    print(f"pack_input_params_file_abspath:{RED}{pack_input_params_file_abspath} {NC}")
    return pack_input_params_file_abspath

# 获取环境变量的值-android等待签名的版本文件夹
def getEnvValue_android_waitSignApkVersions_dir_path(shouldCheckExist=False):
    project_home_dir_path = getEnvValue_project_dir_path()
    
    android_waitSignApk_map = getEnvValue_android_waitSignApk_map()
    if android_waitSignApk_map == None:
        return None
    
    android_waitSignApkVersions_dir_path_relhome = android_waitSignApk_map['android_waitSignApkVersions_dir_RELATIVE_HOME']
    android_waitSignApkVersions_dir_abspath = joinFullPath(project_home_dir_path, android_waitSignApkVersions_dir_path_relhome)
    # print(f"android_sign_script_file_abspath:{RED}{android_sign_script_file_abspath} {NC}")
    if shouldCheckExist==False:
        return android_waitSignApkVersions_dir_abspath
    else:
        if not os.path.exists(android_waitSignApkVersions_dir_abspath):
            print(f"android等待签名的版本文件夹:{RED}{android_waitSignApkVersions_dir_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：android等待签名的版本文件夹:{RED}{android_waitSignApkVersions_dir_abspath}{NC}存在")
            return android_waitSignApkVersions_dir_abspath
    

# 获取环境变量的值-android等待签名的apk文件夹
def getEnvValue_android_waitSignApkDirPath_forVersion(selectedSignApkVersion_dir_path, shouldCheckExist=False):
    android_waitSignApk_map = getEnvValue_android_waitSignApk_map()
    if android_waitSignApk_map == None:
        return None
    
    android_waitSignApkVersion_dir_path_relSelectedVersionDir = android_waitSignApk_map['android_waitSignApkVersion_dir_RELATIVE_SELECTED_VERSION_DIR']
    android_waitSignApkVersion_dir_abspath = joinFullPath(selectedSignApkVersion_dir_path, android_waitSignApkVersion_dir_path_relSelectedVersionDir)
    # print(f"android_waitSignApkVersion_dir_abspath:{YELLOW}{android_waitSignApkVersion_dir_abspath} {NC}")
    if shouldCheckExist==False:
        # print(f"恭喜：你选择的版本的android等待签名的apk文件夹:{RED}{android_waitSignApkVersion_dir_abspath}{NC}存在")
        return android_waitSignApkVersion_dir_abspath
    else:
        if not os.path.exists(android_waitSignApkVersion_dir_abspath):
            print(f"android等待签名的apk文件夹:{RED}{android_waitSignApkVersion_dir_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：你选择的版本的android等待签名的apk文件夹:{RED}{android_waitSignApkVersion_dir_abspath}{NC}存在")
            return android_waitSignApkVersion_dir_abspath
        


# 获取环境变量的值-android签名结果的apk文件夹
def getEnvValue_android_resultSignApkDirPath_forVersion(selectedSignApkVersion_dir_path, shouldCheckExist=False):
    android_waitSignApk_map = getEnvValue_android_waitSignApk_map()
    if android_waitSignApk_map == None:
        return None
    
    android_resultSignApkVersion_dir_path_relSelectedVersionDir = android_waitSignApk_map['android_resultSignApkVersion_dir_RELATIVE_SELECTED_VERSION_DIR']
    android_resultSignApkVersion_dir_abspath = joinFullPath(selectedSignApkVersion_dir_path, android_resultSignApkVersion_dir_path_relSelectedVersionDir)
    # print(f"android_resultSignApkVersion_dir_abspath:{YELLOW}{android_resultSignApkVersion_dir_abspath} {NC}")
    if shouldCheckExist==False:
        # print(f"恭喜：你选择的版本的android等待签名的apk文件夹:{RED}{android_resultSignApkVersion_dir_abspath}{NC}存在")
        return android_resultSignApkVersion_dir_abspath
    else:
        if not os.path.exists(android_resultSignApkVersion_dir_abspath):
            print(f"android等待签名的apk文件夹:{RED}{android_resultSignApkVersion_dir_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：你选择的版本的android等待签名的apk文件夹:{RED}{android_resultSignApkVersion_dir_abspath}{NC}存在")
            return android_resultSignApkVersion_dir_abspath
        


# 获取环境变量的值-android签名结果的apk文件夹
def getEnvValue_android_resultSignApkDirPath_backup_forVersion(selectedSignApkVersion_dir_path, shouldCheckExist=False):
    android_waitSignApk_map = getEnvValue_android_waitSignApk_map()
    if android_waitSignApk_map == None:
        return None
    
    android_resultSignApkVersion_backupdir_parent_abspath = android_waitSignApk_map['android_resultSignApkVersion_dir_backup_ABSOLUTE_PATH']
    # 获取文件夹名称
    folder_name = os.path.basename(os.path.normpath(selectedSignApkVersion_dir_path))

    android_resultSignApkVersion_dir_backup_abspath=joinFullPath(android_resultSignApkVersion_backupdir_parent_abspath, folder_name)
    # print(f"android_resultSignApkVersion_dir_backup_abspath:{YELLOW}{android_resultSignApkVersion_dir_backup_abspath} {NC}")
    if shouldCheckExist==False:
        # print(f"恭喜：签名结果备份到的文件夹(用于内网直接访问):{RED}{android_resultSignApkVersion_dir_backup_abspath}{NC}存在")
        return android_resultSignApkVersion_dir_backup_abspath
    else:
        if not os.path.exists(android_resultSignApkVersion_dir_backup_abspath):
            print(f"签名结果备份到的文件夹(用于内网直接访问):{RED}{android_resultSignApkVersion_dir_backup_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：签名结果备份到的文件夹(用于内网直接访问):{RED}{android_resultSignApkVersion_dir_backup_abspath}{NC}存在")
            return android_resultSignApkVersion_dir_backup_abspath
        

# 获取环境变量的值-android签名结果的apk网址
def getEnvValue_android_resultSignApkWebsite_backup_forVersion(selectedSignApkVersion_dir_path):
    android_waitSignApk_map = getEnvValue_android_waitSignApk_map()
    if android_waitSignApk_map == None:
        return None
    
    android_resultSignApkVersion_backup_website_home = android_waitSignApk_map['android_resultSignApkVersionBackup_website_home']
    # 获取文件夹名称
    folder_name = os.path.basename(os.path.normpath(selectedSignApkVersion_dir_path))

    android_resultSignApkVersion_dir_backup_absUrl=joinFullUrl(android_resultSignApkVersion_backup_website_home, folder_name)
    # print(f"android_resultSignApkVersion_dir_backup_absUrl:{YELLOW}{android_resultSignApkVersion_dir_backup_absUrl} {NC}")
    return android_resultSignApkVersion_dir_backup_absUrl


# 获取环境变量的值-签名脚本文件的存放路径
def getEnvValue_android_sign_script_file_path(shouldCheckExist=False):
    project_home_dir_path = getEnvValue_project_dir_path()
    
    android_signScript_map=getEnvValue_android_signScript_map()
    android_sign_script_file_path_relhome = android_signScript_map['android_sign_script_file_RELATIVE_HOME']
    android_sign_script_file_abspath = joinFullPath(project_home_dir_path, android_sign_script_file_path_relhome)
    # print(f"android_sign_script_file_abspath:{RED}{android_sign_script_file_abspath} {NC}")
    if shouldCheckExist==False:
        return android_sign_script_file_abspath
    else:
        if not os.path.exists(android_sign_script_file_abspath):
            print(f"android签名使用的脚本文件:{RED}{android_sign_script_file_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：android签名使用的脚本文件:{RED}{android_sign_script_file_abspath}{NC}存在")
            return android_sign_script_file_abspath
        
# 获取环境变量的值-签名脚本文件的使用的签名配置信息存放路径
def getEnvValue_android_sign_script_params_file_path(shouldCheckExist=False):
    project_home_dir_path = getEnvValue_project_dir_path()
    
    data = getEnvValue_params_file_data()
    if data == None:
        return None
    
    android_signScript_map=getEnvValue_android_signScript_map()
    android_sign_script_params_file_path_relhome = android_signScript_map['keystore_file_RELATIVE_HOME']
    android_sign_script_params_file_abspath = joinFullPath(project_home_dir_path, android_sign_script_params_file_path_relhome)
    # print(f"android_sign_script_params_file_abspath:{RED}{android_sign_script_params_file_abspath} {NC}")
    if shouldCheckExist==False:
        return android_sign_script_params_file_abspath
    else:
        if not os.path.exists(android_sign_script_params_file_abspath):
            print(f"android签名脚本使用的配置信息文件:{RED}{android_sign_script_params_file_abspath}{NC}不存在，请检查")
            return None
        else:
            # print(f"恭喜：android签名脚本使用的配置信息文件:{RED}{android_sign_script_params_file_abspath}{NC}存在")
            return android_sign_script_params_file_abspath