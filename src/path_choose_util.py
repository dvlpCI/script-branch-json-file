'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-14 22:04:04
FilePath: path_choose_util.py
Description: 指定文件夹下的 文件 或 文件夹 的选择
'''
# -*- coding: utf-8 -*-
import os
import shutil
import re
from path_util import joinFullPath_checkExsit
from common_input import input_folder_path


# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'


# 显示指定文件夹下的所有文件夹，并在选择后输出
def show_and_choose_folder_in_dir(searchInDir, supportCustom=True):
    # 获取第一层文件夹名，如果是文件则不需要
    folder_names = [dir for dir in os.listdir(
        searchInDir) if os.path.isdir(os.path.join(searchInDir, dir))]

    # 打印第一层的文件夹列表
    print(f"")
    print(f"文件夹列表：{YELLOW}{searchInDir}{NC}目录下")
    for i, folder_name in enumerate(folder_names):
        print(f"{i+1}. {os.path.basename(folder_name)}")

    if supportCustom == True:
        promt = "请输入想要操作的文件夹名（输入0自定义，输入Q或q退出）："
    else:
        promt = "请输入想要操作的文件夹名（输入Q或q退出）："
    while True:
        user_input = input(promt)
        if user_input.lower() == 'q':
            exit(2)
            break
        if supportCustom == True and user_input.lower() == '0':
            git_project_folder_path = input_folder_path(
                "请输入想要操作的文件夹路径（输入Q或q退出）：")
            isCustom = True
            break
        elif user_input not in [os.path.basename(folder_name) for folder_name in folder_names]:
            print(f"{RED}不存在您指定的文件夹 {YELLOW}{user_input} {RED}，请重新输入文件夹名{NC}")
            continue
        else:
            git_project_folder_path = joinFullPath_checkExsit(
                searchInDir, user_input)
            git_project_folder_path = os.path.abspath(git_project_folder_path)
            # print(f"{YELLOW}{user_input}{NC} 文件夹存在，路径为：{git_project_folder_path}")
            isCustom = False
            break
    return {
        "path": git_project_folder_path,
        "isCustom": isCustom,
    }


# 显示指定文件夹下的所有指定后缀的文件，并在选择后输出
# fileExtension 文件后缀(.json 等)
def show_and_choose_file_in_dir(searchInDir, fileExtension, GiveupChoose=False):
    # 获取testDir文件夹下所有JSON文件的路径
    # 在这行代码中，f是一个变量名，用于迭代os.listdir(path)函数返回的文件名列表。os.listdir(path)返回指定目录下的所有文件和文件夹的名称列表，然后通过列表推导式[os.path.join(path, f) for f in os.listdir(path) if f.endswith('.json')]筛选出以.json结尾的文件，并使用os.path.join()函数将它们的路径与目录合并。在这个列表推导式中，f代表os.listdir(path)返回的列表中的每个文件名。
    try:
        lastBranchsInfo_files = [joinFullPath_checkExsit(
            searchInDir, f) for f in os.listdir(searchInDir) if f.endswith(fileExtension)]
    except ValueError as e:
        print(f"{RED}脚本执行发生错误了:{YELLOW}{e}{NC}\n")
        return None

    if lastBranchsInfo_files.__len__ == 0:
        print(f"{RED}目录last_branchs_info_dir_path={searchInDir}下未找到json类型的文件，请检查{NC}")
        return None
    # 打印文件列表
    print(f"")
    print(f"文件列表：{YELLOW}{searchInDir}{NC}目录下")
    for i, file in enumerate(lastBranchsInfo_files):
        print(f"{i+1}. {os.path.basename(file)}")

    if GiveupChoose == True:
        return True

    while True:
        user_input = input("请输入想要操作的文件名（输入Q或q退出）：")
        if user_input.lower() == 'q':
            exit(2)
            break
        elif not re.match(r'\.[jJ][sS][oO][nN]$', user_input):
            print(f"{RED}输入的{user_input}不是{fileExtension}格式的文件名，请重新输入{NC}")
            continue
        elif user_input not in [os.path.basename(file) for file in lastBranchsInfo_files]:
            print(f"{RED}文件不存在，请重新输入{NC}")
            continue
        else:
            last_branchs_info_file_path = joinFullPath_checkExsit(
                searchInDir, user_input)
            last_branchs_info_file_path = os.path.abspath(
                last_branchs_info_file_path)
            # print(f"{user_input} 文件存在，路径为：{last_branchs_info_file_path}")
            break
    return last_branchs_info_file_path


# 拷贝指定文件夹中，符合指定后缀格式的文件，到指定的备份文件夹中
def copy_special_file_inDir_toDir(source_dir_path, copy_file_extension, backup_to_dir_path):
    # 获取符合条件的文件列表
    try:
        apk_files = [filename for filename in os.listdir(
            source_dir_path) if filename.endswith(copy_file_extension)]
    except (FileNotFoundError, PermissionError) as e:
        print(f"{RED}Failed to list files in directory: {source_dir_path}{NC}")
        print(f"{RED}Error message: {str(e)}{NC}")
        apk_files = []
        return False

    num_apk_files = len(apk_files)

    # 如果备份目录不存在，则创建该目录
    if not os.path.exists(backup_to_dir_path):
        print(f"{YELLOW}正在创建父目录{backup_to_dir_path}{NC}")
        try:
            os.makedirs(backup_to_dir_path, exist_ok=True)
            print(f"{BLUE}成功创建父目录{backup_to_dir_path}{NC}")
        except OSError as error:
            print(f"{RED}Failed to create directory: {backup_to_dir_path}{NC}")
            print(f"{RED}Error message: {str(error)}{NC}")
            if error.errno == 13:  # 权限问题
                print(f"{RED}权限问题，以管理员身份重新执行或者手动创建")
            return False

    # 遍历符合条件的文件列表，并拷贝到备份目录
    for i, filename in enumerate(apk_files):
        # 构造源文件和备份文件的绝对路径
        src_file_abspath = os.path.join(source_dir_path, filename)
        backup_file_abspath = os.path.join(backup_to_dir_path, filename)
        # 复制文件到备份目录
        print(f"{BLUE}拷贝进度{i+1}/{num_apk_files}:正在拷贝 {YELLOW}{src_file_abspath}{BLUE} 到 {YELLOW}{backup_file_abspath}{BLUE} 中{NC}")
        shutil.copy(src_file_abspath, backup_file_abspath)
        # 输出拷贝进度信息
        print(f"{BLUE}拷贝进度{i+1}/{num_apk_files}:完成拷贝 {YELLOW}{src_file_abspath}{BLUE} 到 {YELLOW}{backup_file_abspath}{BLUE} 中{NC}")
