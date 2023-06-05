'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-06-05 10:32:34
FilePath: src/base_util.py
Description: 获取环境变量的值
'''
import os
import subprocess

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

def openFile(file_path):
    # 在 macOS 或 Linux 上打开 file_path 文件。
    # subprocess.Popen(['open', file_path])
    subprocess.Popen(['open', file_path])
    
    
       
        
def callScriptCommond(command, sript_file_absPath):
    print(f"\n{BLUE}开始执行脚本，执行过程中输出内容如下：{NC}")
    # 调用 subprocess.run() 函数执行 shell 命令
    # print(f"{BLUE}正在执行命令:《 {YELLOW}{' '.join(command)}{NC} 》")

    # try:
    #     subprocess.check_call(command)
    # except subprocess.CalledProcessError as e:
    #     print("Error: ", e.returncode, e.output)
    try:
        # 尝试执行脚本
        # 设置了 check=True 参数，这可以使函数在命令执行失败时抛出一个 CalledProcessError 异常。
        # capture_output=True 参数可以捕获命令的标准输出和标准错误输出。
        # text=True 参数可以将输出解码为字符串。如果省略 capture_output=True 参数，则无法在 except 块中访问命令的输出
        result = subprocess.run(command)
    except PermissionError:
        # 如果没有执行权限，添加执行权限并重试
        os.chmod(sript_file_absPath, 0o755)
        result = subprocess.run(command)
    except subprocess.CalledProcessError as error:
        # 如果脚本执行失败，输出错误信息
        print(f'{RED}脚本调用失败，错误码:{YELLOW}{error.returncode}{NC}', )
        print(f'{RED}脚本调用失败，错误信息如下:{YELLOW}{error.stderr}{NC}')
        # print(f"{RED}脚本调用失败：{error}{NC}")
        return False

    print(f"\n{BLUE}脚本执行结束，执行结果如下：{NC}")
    # 判断 shell 命令的返回值，并输出结果
    if result.returncode != 0:
        print(f"{RED}抱歉:命令执行失败，请检查，returncode={result.returncode}。所执行的命令如下：《 {YELLOW}{' '.join(command)}{RED} 》{NC}")
        exit(1)
    elif "exit 1" in result.stdout:
        print("脚本执行失败")
        print(result.stdout)
    else:
        print(f"{BLUE}命令执行成功,结果如下:\n {result.stdout.strip()}")


# sript_file_absPath = "/Users/lichaoqian/Project/CQCI/script-branch-json-file/test/test_shell.sh"
# scriptParamMaps = [
#     {"key": '-pl', "value": 'iOS'}, 
#     {"key": '-pn', "value": 'test1'}, 
#     {"key": '-pt', "value": 'formal'}, 
#     {"key": '-saveToF', "value": 'hello4.json'}
# ]
# command = ['sh', sript_file_absPath]
# for i, scriptParamMap in enumerate(scriptParamMaps):
#     param = scriptParamMap["key"]
#     value = scriptParamMap["value"]
#     command += [f"{param}", value]
    
# callScriptCommond(command, sript_file_absPath)
