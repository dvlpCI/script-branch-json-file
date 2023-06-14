'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-15 00:53:11
FilePath: sign_apk_tool.py
Description: apk签名
'''
# -*- coding: utf-8 -*-
import os
import subprocess

from env_pack_util import getEnvValue_android_waitSignApkVersions_dir_path, getEnvValue_android_waitSignApkDirPath_forVersion, getEnvValue_android_resultSignApkDirPath_forVersion, getEnvValue_android_sign_script_file_path, getEnvValue_android_resultSignApkDirPath_backup_forVersion, getEnvValue_android_resultSignApkWebsite_backup_forVersion, getEnvValue_android_sign_script_params_file_path
from path_choose_util import show_and_choose_folder_in_dir, show_and_choose_file_in_dir, copy_special_file_inDir_toDir
from path_util import joinFullPath_noCheck

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'


# 选择要加固的apk的版本文件夹
def choose_SignApkVersion_dir_path():
    waitSignApkVersions_dir_path=getEnvValue_android_waitSignApkVersions_dir_path(shouldCheckExist=True)
    if waitSignApkVersions_dir_path == None:
        return None
    # print(f"待加固的apk所有版本的所在目录路径：{RED}{waitSignApkVersions_dir_path}{NC}")

    selected_folder_map=show_and_choose_folder_in_dir(waitSignApkVersions_dir_path)
    selected_folder_abspath=selected_folder_map['path']
    selected_folder_isCustom=selected_folder_map['isCustom']
    if selected_folder_isCustom==True:
        selected_folder_map['apk_waitSignDir_abspath']=selected_folder_abspath
        selected_folder_map['apk_signResult_dir_abspath']=joinFullPath_noCheck(selected_folder_abspath, "signed")
        return selected_folder_map
   
    android_waitSignApkVersion_dir_abspath=getEnvValue_android_waitSignApkDirPath_forVersion(selected_folder_abspath)
    if android_waitSignApkVersion_dir_abspath == None:
        return None
    selected_folder_map['apk_waitSignDir_abspath']=android_waitSignApkVersion_dir_abspath


    android_apkSignResult_dir_abspath=getEnvValue_android_resultSignApkDirPath_forVersion(selected_folder_abspath)
    selected_folder_map['apk_signResult_dir_abspath']=android_apkSignResult_dir_abspath

    return selected_folder_map

    
    
# def removeJsonByName(file_path, removeBranchName):
#     # 打开JSON文件
#     with open(file_path, 'r') as f:
#         data = json.load(f)

#     # 从package_merger_branchs数组中删除name为'dev_login_err'的JSON对象
#     data['package_merger_branchs'] = [obj for obj in data['package_merger_branchs'] if obj['name'] != removeBranchName]

#     # 保存更新后的JSON文件
#     with open(file_path, 'w') as f:
#         json.dump(data, f, indent=2, ensure_ascii=False)
        
def checkShouldContinue_ApkVersion_dir(android_waitSignApkVersion_dir_abspath, android_apkSignResult_dir_abspath):
    while True:
        showResultCode=show_and_choose_file_in_dir(android_waitSignApkVersion_dir_abspath, '.apk', GiveupChoose=True)
        if showResultCode == None:
            exit(2)
        shouldContinue = input(f"等待签名的apk文件目录如上。签名结果会保存到 {BLUE}{android_apkSignResult_dir_abspath} {NC}。请确认是否继续进行签名.[继续y/退出n] : ")
        if shouldContinue.lower() == 'y':
            break
        elif shouldContinue.lower() == 'n':
            print(f"放弃操作，将退出")
            exit(2)
        else:
            print(f"字符串{RED}{shouldContinue}{NC}不符合要求，请重新输入[继续y/退出n]\n")
    return 0

# 请选择操作类型
def chooseVersionApk_SignThem(): 
    # 版本目录的获取及版本文件夹的罗列
    selected_folder_map=choose_SignApkVersion_dir_path()
    if selected_folder_map == None:
        # print(f"selected_folder_map={RED}{selected_folder_map}{NC}不符合要求\n")
        return None
    
    # 版本apk目录的获取及apk文件罗列
    signApkVersion_dir_path=selected_folder_map['path']
    android_waitSignApkVersion_dir_abspath=selected_folder_map['apk_waitSignDir_abspath']
    android_apkSignResult_dir_abspath=selected_folder_map['apk_signResult_dir_abspath']
    if checkShouldContinue_ApkVersion_dir(android_waitSignApkVersion_dir_abspath, android_apkSignResult_dir_abspath) == 1:
        return None
    
    # 版本apk目录下的所有apk的签名
    print(f"")
    android_sign_script_file_abspath=getEnvValue_android_sign_script_file_path()
    android_sign_scriptParams_file_abspath=getEnvValue_android_sign_script_params_file_path()
    # 调用shell脚本，并传递文件夹参数
    # 构造 shell 命令和参数列表

    cmd = [android_sign_script_file_abspath, android_waitSignApkVersion_dir_abspath, android_apkSignResult_dir_abspath]

    # 调用 subprocess.run() 函数执行 shell 命令
    cmdString=' '.join(cmd)
    escaped_command = cmdString.replace("(", r"\(").replace(")", r"\)")
    print(f"{BLUE}开始签名....:《 {YELLOW}{escaped_command} {BLUE}》{NC}")
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    # 判断 shell 命令的返回值，并输出结果
    if result.returncode != 0:
        print(f"{RED}抱歉:签名失败，请检查上述签名命令{NC}")
        print(f"{RED}Failed with exit code {result.returncode}{NC}")
        print(f"{RED}Error message: {result.stderr.strip()}{NC}")
        exit(1)
    else:
        print(f"{BLUE}签名结果如下: {result.stdout.strip()}")
    
    if not os.path.exists(android_apkSignResult_dir_abspath):
        print(f"{RED}Error:android签名结束的apk存放的文件夹:{YELLOW}{android_apkSignResult_dir_abspath} {RED}不存在，请检查{NC}")
        exit(1)
    print(f"{GREEN}恭喜:签名成功，签名结果存在的文件夹(已为你自动打开)为 {YELLOW}{android_apkSignResult_dir_abspath}{NC}")

    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', android_apkSignResult_dir_abspath])


    # 备份
    android_resultSignApkVersion_dir_backup_abspath=getEnvValue_android_resultSignApkDirPath_backup_forVersion(signApkVersion_dir_path)
    copySuccess=copy_special_file_inDir_toDir(android_apkSignResult_dir_abspath, '.apk', android_resultSignApkVersion_dir_backup_abspath)
    if copySuccess == False:
        return False
    android_resultSignApkVersion_dir_backup_absUrl=getEnvValue_android_resultSignApkWebsite_backup_forVersion(signApkVersion_dir_path)
    print(f"{GREEN}恭喜:拷贝成功，内网可直接访问(已为你自动打开){YELLOW}{android_resultSignApkVersion_dir_backup_absUrl}{GREEN} ，本地地址为 {YELLOW}{android_resultSignApkVersion_dir_backup_abspath}{NC}")

# 执行命令
chooseVersionApk_SignThem()