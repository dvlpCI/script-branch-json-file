'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad dvlproad@163.com
LastEditTime: 2026-04-19 21:28:06
FilePath: dealScriptByCustomChoose.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import subprocess
from env_pack_util import getEnvValue_pack_input_params_file_path
from base_util import callScriptCommond
from dealScriptByCustomChoose_util import chooseCustomScriptFromFilePaths

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



# import argparse
# parser = argparse.ArgumentParser()
# for item in json.loads(" ".join(__import__("sys").argv[1:])):
#     parser.add_argument(item)
# args = parser.parse_args()
# print(args)

import argparse
import sys

def print_custom_help():
    print("""
Usage: python3 dealScriptByCustomChoose.py [其他参数]

Options:
  --verbose, -v                                  显示详细信息
  --qian                                         开启打印调试log模式
  --qbase-local-path <path>                      依赖的子库 qbase 使用指定的路径

Example:
  python3 dealScriptByCustomChoose.py
""")
    
def parse_arguments():
    # 先手动检查 help
    if '-h' in sys.argv or '--help' in sys.argv:
        print_custom_help()
        sys.exit(0)
    
    # 禁用自动 help，避免冲突
    parser = argparse.ArgumentParser(description='你的程序描述', add_help=False)
    
    parser.add_argument('--verbose', '-v', 
                       action='store_true',
                       help='显示详细信息')
    
    parser.add_argument('--qian', 
                       action='store_true',
                       help='开启打印调试log模式')
    
    parser.add_argument('--qbase-local-path', '-qbase-local-path', 
                   type=str,  # 指定类型为字符串
                   default=None,  # 默认值为 None
                   help='依赖的子库 qbase 使用指定的路径，用来顺便测试子库')
    
    parser.add_argument('--no-use-brew-path', 
                   action='store_true',
                   help='qtool 里的其他脚本路径是否使用本地来拼接，而不是 brew 里的路径')
    
    
    try:
        args = parser.parse_args()
    except SystemExit:
        print_custom_help()
        sys.exit(1)
    return args

def filter_argv(exclude_flags=None, exclude_options=None):
    """
    过滤命令行参数
    exclude_flags: 排除的标志参数（不需要值的），如 ['--qian']
    exclude_options: 排除的选项参数（需要值的），如 ['--qbase-local-path']
    """
    if exclude_flags is None:
        exclude_flags = ['--qian']
    if exclude_options is None:
        exclude_options = []
    
    filtered = []
    skip_next = False
    
    for i, arg in enumerate(sys.argv[1:]):
        if skip_next:
            skip_next = False
            continue
        
        # 检查是否是需要排除的标志参数
        if arg in exclude_flags:
            continue
        
        # 检查是否是需要排除的选项参数
        if arg in exclude_options:
            skip_next = True  # 跳过下一个参数（值）
            continue
        
        filtered.append(arg)
    
    return filtered

#### ------ qian_log_func() ------ ####
import inspect
# 声明全局变量
DEFINE_QIAN = None
def qian_log_func(msg):
    """只有定义 --qian 的时候才打印这个log(带函数名)"""
    global DEFINE_QIAN
    if DEFINE_QIAN:  # 只有当用户传了 --qian 相关参数时才打印
        func_name = inspect.currentframe().f_back.f_code.co_name
        print(f"{PURPLE}>>>>>>>>>>>>【{func_name}】{msg} {NC}", file=sys.stderr)
        
def qian_log(msg):
    """只有定义 --qian 的时候才打印这个log"""
    global DEFINE_QIAN
    if DEFINE_QIAN:  # 只有当用户传了 --qian 相关参数时才打印
        print(msg, file=sys.stderr)

# 解析参数（所有参数都是可选的）
args = parse_arguments()
contains_verbose_in_allArgs = args.verbose  # 用户没传 --verbose 时是 False
DEFINE_QIAN = args.qian  # 用户没传 --qian 时是 False
QBASE_CMD = "qbase"
if args.qbase_local_path:
    QBASE_CMD = args.qbase_local_path
    print(f"{GREEN}使用本地 qbase 路径: {QBASE_CMD} {NC}")
 
'''
# 传递给下个脚本的参数
next_args = filter_argv(
    exclude_flags=[],  # 若要排除 --qian ， [] 内填 '--qian'
    exclude_options=[]  # 不排除任何选项参数
)
qian_log(f"传递给下一个脚本的参数: {next_args}")

# 测试输出
if contains_verbose_in_allArgs:
    print("Verbose mode enabled")
'''


# 业务逻辑代码...
custom_script_files_abspath=getEnvValue_pack_input_params_file_path(shouldCheckExist=True)
if custom_script_files_abspath == None:
    exit(1)
chooseScriptMap=chooseCustomScriptFromFilePaths(custom_script_files_abspath, shouldCheckExist=True)
if chooseScriptMap == None:
    exit(1)
chooseScriptFilePath=chooseScriptMap["script_info_abspath"]
pack_input_params_file_path=chooseScriptFilePath
if pack_input_params_file_path == None:
    exit(1)
qian_log(f"{GREEN}要执行的脚本是{BLUE} {pack_input_params_file_path} {GREEN}。{NC}")


# '''
# 使用subprocess.run执行Shell命令
result = subprocess.run(
    f"{QBASE_CMD} -path execScript_by_configJsonFile",
    shell=True,
    capture_output=True, 
    text=True
)
# 检查命令执行结果
if result.returncode != 0:
    print(f"result.stderr={result.stderr}")    # 打印错误信息
    exit(1)
# else:
#     print(f"result.stdout={result.stdout}")    # 打印命令输出
qbase_execScript_by_configJsonFile_scriptPath=result.stdout.strip()  # 去除字符串两端的空白字符（避免多出个换行符）
# '''
# print(f"{GREEN}要执行的脚本是{BLUE} {sript_file_absPath} {GREEN} {GREEN}参数是【{BLUE} {pack_input_params_file_path} {GREEN}】。{NC}")

# 添加要执行的python脚本文件是否存在
if qbase_execScript_by_configJsonFile_scriptPath is None:
    print(f"{RED}错误: 找不到文件 dealScript_by_scriptConfig.py{NC}")
    print(f"{YELLOW}当前文件路径: {qbase_execScript_by_configJsonFile_scriptPath}{NC}")
    print(f"{YELLOW}查找相对路径: ./dealScript_by_scriptConfig.py{NC}")
    exit(1)
    
command=["python3", qbase_execScript_by_configJsonFile_scriptPath, "-script-config-file", pack_input_params_file_path]
qian_log(f"{GREEN}要执行的py脚本命令是【{BLUE} python3 {qbase_execScript_by_configJsonFile_scriptPath} -script-config-file {pack_input_params_file_path} {GREEN}】。{NC}")
# command = command + COMMON_FLAG_ARGS # 不是 +next_args 
# import shlex
# cmd_str = ' '.join(shlex.quote(arg) for arg in command)
# qian_log(f"{GREEN}执行【要执行的脚本】的py命令是【{BLUE} {cmd_str} {GREEN}】。{NC}")
# print(f"{GREEN}脚本执行完成。{NC}")
# exit(1)
callScriptCommond(command, qbase_execScript_by_configJsonFile_scriptPath)