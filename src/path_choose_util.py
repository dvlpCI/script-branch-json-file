'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-29 13:24:35
FilePath: path_choose_util.py
Description: 指定文件夹下的 文件 或 文件夹 的选择
'''
# -*- coding: utf-8 -*-
import os
import shutil
import re
from path_util import joinFullPath_checkExsit
from common_input import input_custom_path, CustomPathType


# 定义颜色常量
NC = '\033[0m'  # No Color
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
PURPLE = '\033[0;35m'
CYAN = '\033[0;36m'


# 显示指定文件夹下的所有文件夹，并在选择后输出
def show_and_choose_folder_in_dir(searchInDir, customPathType=CustomPathType.NONE):
    if customPathType ==CustomPathType.FOLDER:
        supportCustomString="文件夹路径"
    elif customPathType ==CustomPathType.FILE:
        supportCustomString="文件路径"
    elif customPathType ==CustomPathType.BOTH:
        supportCustomString="文件夹路径或者文件路径"
    else:
        supportCustomString="未知项路径"

    # 获取第一层文件夹名，如果是文件则不需要
    folder_names = [dir for dir in os.listdir(
        searchInDir) if os.path.isdir(os.path.join(searchInDir, dir))]

    if len(folder_names) == 0:
        print (f"{YELLOW}温馨提示：您的 ${searchInDir} 是空文件夹，请检查，且将自动进入自定义文件夹路径操作{NC}")
        git_project_folder_path = input_custom_path(f"请输入想要操作的{supportCustomString}（输入Q或q退出）：", customPathType=customPathType)
        isCustom = True
        return {
            "path": git_project_folder_path,
            "isCustom": isCustom,
        }
    
    # 打印第一层的文件夹列表
    print(f"")
    print(f"文件夹列表：{YELLOW} {searchInDir} {NC}目录下")
    for i, folder_name in enumerate(folder_names):
        print(f"{i+1}. {os.path.basename(folder_name)}")

    if customPathType !=CustomPathType.NONE:
        promt = "请输入想要操作的文件夹名（输入0自定义，输入Q或q退出）："
    else:
        promt = "请输入想要操作的文件夹名（输入Q或q退出）："
    while True:
        user_input = input(promt)
        if user_input.lower() == 'q':
            exit(2)
            break
        if customPathType !=CustomPathType.NONE and user_input.lower() == '0':
            

            git_project_folder_path = input_custom_path(
                f"请输入想要操作的{supportCustomString}（输入Q或q退出）：", customPathType=customPathType)
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

def show_and_choose_file_from_currentDir(fileExtension):
    current_path = os.getcwd()  # 获取当前路径
    return show_and_choose_file_in_dir(current_path, fileExtension)


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

    if len(lastBranchsInfo_files) == 0:
        print (f"{YELLOW}温馨提示：您的 {BLUE}{searchInDir} {YELLOW}下未找到 {BLUE}{fileExtension} {YELLOW}类型的文件。故转为需要您自己输入路径。{NC}")
        custom_input_file_path = input_custom_path(f"请输入想要操作的 {BLUE}{fileExtension} {NC}类型的文件路径（输入Q或q退出）：", customPathType=CustomPathType.FILE)
        if is_file_extension(custom_input_file_path, fileExtension):
            return custom_input_file_path
        else:
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
        elif not user_input.endswith(fileExtension):
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


# 显示指定所有路径，并通过编号选择路径
def show_and_choose_files_byNo(file_abspaths):
    if len(file_abspaths) == 1:
        return file_abspaths[0]
    
    # 打印文件列表
    print(f"")
    print(f"文件列表：共{YELLOW}{len(file_abspaths)}{NC}个")
    for i, file_abspath in enumerate(file_abspaths):
        print(f"{i+1}. {file_abspath}")

    while True:
        person_input = input("请输入想要操作的文件路径的编号（输入Q或q退出）：")
        if person_input.lower() == 'q':
            exit(2)
            break

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue
        
        index = int(person_input) - 1
        if index >= len(file_abspaths):
            print("输入错误，请重新输入想要操作的文件路径的编号（输入Q或q退出）：")
            continue
        else:
            selected_file_abspath = file_abspaths[index]
            break
    return selected_file_abspath


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


def is_file_extension(file_path, file_extension):
    """
    判断文件是否具有指定的扩展名或以指定的扩展名结尾
    :param file_path: 文件路径
    :param file_extension: 扩展名，可以是带"."的扩展名，例如".txt"，也可以是不带"."的扩展名，例如"txt"
    :return: 如果文件具有指定的扩展名或以指定的扩展名结尾，则返回True，否则返回False
    """
    # 获取文件扩展名
    _, ext = os.path.splitext(file_path)

    # 判断文件扩展名是否与指定的扩展名匹配
    return ext.lower() == file_extension.lower() or file_path.lower().endswith(file_extension.lower())

# # 示例用法
# file_path = "example.txt"
# file_extension = ".txt"
# if is_file_extension(file_path, file_extension):
#     print(f"{file_path} 是 {file_extension} 文件")
# else:
#     print(f"{file_path} 不是 {file_extension} 文件")