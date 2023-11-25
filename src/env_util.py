'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2023-06-13 21:03:05
FilePath: /script-branch-json-file/src/env_util.py
Description: 获取环境变量的值
'''
import os
import subprocess
from env_util_tool import get_json_file_data, getProject_dir_path_byToolParamFile, getBranch_json_file_dir_path_fromToolParamFile

# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'

def check_command(cmd): # TODO计算不准，如求 coscmd 时候
    try:
        subprocess.run([cmd], check=True)
    except subprocess.CalledProcessError:
        print(f"{cmd} command not found, installing...")
        if cmd == "realpath":
            cmd = "coreutils"
        elif cmd == "coscmd":
            os.system("pip install coscmd")
            return
        if "darwin" in os.uname().sysname.lower():
            print(f"正在执行安装命令：《 brew install {cmd} 》")
            os.system(f"brew install {cmd}")
        elif "linux" in os.uname().sysname.lower():
            if os.path.exists("/etc/debian_version"):
                os.system("sudo apt-get update")
                os.system(f"sudo apt-get install -y {cmd}")
            elif os.path.exists("/etc/redhat-release"):
                os.system(f"sudo yum install -y {cmd}")
            elif os.path.exists("/etc/fedora-release"):
                os.system(f"sudo dnf install -y {cmd}")
            else:
                print(f"Unable to install {cmd}, please install it manually.")
                exit(1)
        else:
            print(f"Unsupported operating system, please install {cmd} manually.")
            exit(1)


# 获取环境变量的值
def getEnvValueByKey(key):
    envValue = os.getenv(key)
    # if key in os.environ:
    #     envValue = os.environ[key]
    #     print(envValue)
    # else:
    #     print("\033[1;31m{}\033[0m environment variable not set".format(envValue))
    print("envValue: \033[1;31m{}\033[0m".format(envValue))
    return envValue

def getEnvValue_params_file_path():
    # return "/Users/qian/Project/CQCI/script-branch-json-file/test/tool_input.json"
    tool_params_file_path = os.getenv('QTOOL_DEAL_PROJECT_PARAMS_FILE_PATH')
    if tool_params_file_path.startswith('~'):
        tool_params_file_path = os.path.expanduser(tool_params_file_path) # 将~扩展为当前用户的home目录
    return tool_params_file_path

def getEnvValue_params_file_data():
    tool_params_file_path = getEnvValue_params_file_path()
    return get_json_file_data(tool_params_file_path)


# 获取环境变量的值-项目路径 project_dir_path
def getEnvValue_project_dir_path():
    tool_params_file_path = getEnvValue_params_file_path()
    return getProject_dir_path_byToolParamFile(tool_params_file_path)
    
# 获取环境变量的值-项目的父路径 project_parent_dir_path
def getEnvValue_project_parent_dir_path():
    project_dir_abspath=getEnvValue_project_dir_path()
    if project_dir_abspath == None:
        return None
    # print("文件路径1：", project_dir_abspath)
    
    # 获取上级目录，使用 os.path.abspath()函数获取 project_dir_abspath 文件夹的绝对路径，能有效去除目录路径结尾可能多一个/的问题
    project_dir_abspath=os.path.abspath(project_dir_abspath)
    project_parent_dir_path = os.path.dirname(project_dir_abspath)
    if not os.path.isdir(project_parent_dir_path):
        print(f"{RED}项目的父路径目录project_parent_dir_path={project_parent_dir_path}不存在，请检查{NC}")
        return None
    return project_parent_dir_path
    

# 获取环境变量的值-项目中分支信息文件的存放路径
def getEnvValue_branch_json_file_dir_path(shouldCheckExist=False):
    tool_params_file_path = getEnvValue_params_file_path()
    return getBranch_json_file_dir_path_fromToolParamFile(tool_params_file_path, shouldCheckExist)



# 获取工程的所在目录(①用户Jenkins打包机的 打包项目 选择；②要更新哪个打包的历史json文件选择)
def getEnvValue_pack_workspace():
    project_dir_path = getEnvValue_project_dir_path()
    return project_dir_path

    # jenkins_data=data['pack']
    # jenkins_workspace=jenkins_data['workspace']
    # if jenkins_workspace.startswith('~'):
    #     jenkins_workspace = os.path.expanduser(jenkins_workspace) # 将~扩展为当前用户的home目录

    # if not os.path.isdir(jenkins_workspace):
    #     print(f"{RED}目录{jenkins_workspace}不存在，请检查{tool_params_file_path}中的jenkins.workspace字段(已自动为你打开) {NC}")
    #     # 在 macOS 或 Linux 上打开 file_path 文件。
    #     # subprocess.Popen(['open', file_path])
    #     subprocess.Popen(['open', tool_params_file_path])
    #     return 1
    
    # return jenkins_workspace

# branch_json_file_git_home=getEnvValue_project_dir_path()
# getEnvValue_branch_json_file_dir_path()
# getEnvValue_project_dir_path()