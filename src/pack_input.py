'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-12 22:15:22
LastEditors: dvlproad
LastEditTime: 2023-06-03 19:06:20
FilePath: pack_input.py
Description: 打包-输入
'''
# -*- coding: utf-8 -*-

# 如果你希望用户在输入答案时不换行，可以使用 input() 函数的 end 参数将输入的结尾字符改为一个空字符串。默认情况下，input() 函数的 end 参数是一个换行符 \n，这会导致用户输入答案后自动换行。
# print("请输入测试人员编号：", end="")

import os
import json

import subprocess
from base_util import openFile
from env_pack_util import getEnvValue_pack_input_params_file_path
from path_util import joinFullPath
from env_util import get_json_file_data


# 定义颜色常量
NC='\033[0m' # No Color
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'



def getActionById(actions, actionId):
    # for iPerson in persons:
    #     if iPerson['id'] == personId:
    #         person=iPerson
    #         break
    # return person

    matchPersons = list(filter(lambda x: x['id'] == actionId, actions))
    if matchPersons:
        person = matchPersons[0]

    return person

def getChooseValueById(values, valueId):
    # for iPerson in persons:
    #     if iPerson['id'] == personId:
    #         person=iPerson
    #         break
    # return person

    matchPersons = list(filter(lambda x: x['id'] == valueId, values))
    if matchPersons:
        person = matchPersons[0]

    return person

def dealActions():
    pack_input_params_file_path=getEnvValue_pack_input_params_file_path(shouldCheckExist=True)
    if pack_input_params_file_path == None:
        return False
    data=get_json_file_data(pack_input_params_file_path)
    if data == None:
        print(f"{RED}发生错误:从{YELLOW}{pack_input_params_file_path}{RED} 文件获取数据失败，请检查{NC}")
        return False

    # 1、选择环境
    chooseEnvMap=chooseFullActionMapByInputFromData(data)
    scriptParamMaps=getScriptChangeParamsFromFileData(data, chooseEnvMap, pack_input_params_file_path)
    
    
    # 3、获取脚本文件
    if 'action_sript_file_rel_this_dir' not in data:
        print(f"{RED}发生错误:{pack_input_params_file_path} 文件中不存在'action_sript_file_rel_this_dir'键，请检查{NC}")
        return False
    action_sript_file_rel_this_dir=data['action_sript_file_rel_this_dir']
    # 获取当前执行的Python脚本所在的目录
    current_pack_input_json_dir_path = os.path.dirname(pack_input_params_file_path)
    # 获取脚本的实际绝对路径
    action_sript_file_absPath=joinFullPath(current_pack_input_json_dir_path, action_sript_file_rel_this_dir)
    if not os.path.isfile(action_sript_file_absPath):
        print(f"{RED}发生错误:脚本文件不存在，原因为计算出来的相对目录不存在。请检查您的 {YELLOW}{pack_input_params_file_path}{NC} 中的 {BLUE}action_sript_file_rel_this_dir{RED} 属性值 {BLUE}{action_sript_file_rel_this_dir}{RED} 是否正确。（其会导致计算相对于 {YELLOW}{pack_input_params_file_path}{RED} 的父目录 {BLUE}${current_pack_input_json_dir_path}{RED} 该属性值路径 {YELLOW}{action_sript_file_absPath}{RED} 不存在)。{NC}")
        openFile(pack_input_params_file_path)
        return False

    # 4、使用获得的脚本文件和参数，执行脚本命令
    # 调用脚本
    command = ["sh", action_sript_file_absPath]
    for scriptParamMap in scriptParamMaps:
        param = scriptParamMap["resultForParam"]
        value = scriptParamMap["resultValue"]
        command += [f"-{param}", value]

    # 调用 subprocess.run() 函数执行 shell 命令
    print(f"{BLUE}正在执行命令:《 {YELLOW}{' '.join(command)}{NC} 》")
    try:
        # 尝试执行脚本
        # subprocess.run(["bash", action_sript_file_absPath], check=True)
        result = subprocess.run(command, capture_output=True, text=True)
    except PermissionError:
        # 如果没有执行权限，添加执行权限并重试
        os.chmod(action_sript_file_absPath, 0o755)
        # subprocess.run(["bash", action_sript_file_absPath], check=True)
        result = subprocess.run(command, capture_output=True, text=True)
    except subprocess.CalledProcessError as e:
        # 如果脚本执行失败，输出错误信息
        print(f"脚本执行失败：{e}")
        return False

    
    # 判断 shell 命令的返回值，并输出结果
    if result.returncode != 0:
        print(f"{RED}抱歉:命令执行失败，请检查{NC}")
        print(f"{RED}Failed with exit code {result.returncode}{NC}")
        print(f"{RED}Error message: {result.stderr.strip()}{NC}")
        print(f"{RED}Error message: {result}{NC}")
        exit(1)
    elif "exit 1" in result.stdout:
        print("脚本执行失败")
        print(result.stdout)
    else:
        print(f"{BLUE}命令执行成功,结果如下:\n {result.stdout.strip()}")


    


# # 1、从 jsonFile 中获取脚本的所有固定参数
# def getScriptFixParamsFromFile(data, pack_input_params_file_path):
#     # 1、选择环境
#     if 'fixed_params' not in data:
#         print(f"{RED}发生错误:{data} 文件中不存在'fixed_params'键，请检查{NC}")
#         return False
    
#     fixedParamMaps=data['fixed_params']
    
#     print(f"")
#     resultMaps=[]
#     for i, fixedParamMap in enumerate(fixedParamMaps):
#         resultMap=getFixParamMapFromFile(fixedParamMap, pack_input_params_file_path)
#         resultMaps.append(resultMap)
#         print(f"")

#     print(f"您脚本的固定参数如下：{NC}")
#     for i, resultMap in enumerate(resultMaps):
#         print(f"{i+1}. {resultMap['resultForParam']} ({resultMap['resultValue']})")
    
#     return resultMap



# 2、从 fileData 中获取脚本的所有变化参数
def chooseFullActionMapByInputFromData(data):
    actions_envs=data['actions_envs']
    for i, actions_env in enumerate(actions_envs):
        print(f"{i+1}. {actions_env['env_id']} ({actions_env['env_name']})")

    envDes="要操作的环境"
    while True:
        env_input = input("请选择%s编号（退出q/Q）：" % (envDes))
        if env_input == "q" or env_input == "Q":
            exit()

        if not env_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        index = int(env_input) - 1
        if index >= len(actions_envs):
            continue
        else:
            chooseEnvMap = actions_envs[index]
            chooseEnvMapName = chooseEnvMap["env_name"]
            break

    print(f"您选择的{envDes}：{YELLOW}{chooseEnvMapName}{NC}")
    return chooseEnvMap

# 2、根据所选择的操作的所需的所有参数，遍历获取每个【参数】的内容
def getScriptChangeParamsFromFileData(data, chooseEnvMap, pack_input_params_file_path):
    print(f"")

    # 2、针对选择的环境，执行所需的操作
    env_action_ids=chooseEnvMap['env_action_ids']
    # print(f"所选择操作所需要的所有参数为:{YELLOW}{env_action_ids}的用户{NC}")
    resultMaps=[]
    for i, env_action_id in enumerate(env_action_ids):
        resultMap=_getScriptParamFromFileDataByOperate(data, env_action_id, pack_input_params_file_path)
        if resultMap == None:
            print(f"{RED}获取 {env_action_id} 的参数过程失败：{NC}")
            exit(1)
        resultMaps.append(resultMap)
        print(f"")

    print(f"您所有参数的结果如下：{NC}")
    for i, resultMap in enumerate(resultMaps):
        # print(f"{i+1}.========参数如下：{resultMaps}{NC}")
        print(f"{i+1}. {resultMap['resultForParam']} : {resultMap['resultValue']}")

    return resultMap


def _getScriptParamFromFileDataByOperate(data, operate, pack_input_params_file_path):
    operateHomeMap=getActionById(data['actions'],operate)

    # 对 homeMap 进行处理，判断 "固定值"、"选择" 还是 "输入"
    operateActionType = operateHomeMap['actionType']
    if operateActionType == "fixed": # 固定值
        return __getFixParamMapFromFile(operateHomeMap, pack_input_params_file_path)
    elif operateActionType == "choose": # 选择值
        return __getChooseParamMapFromFile(operateHomeMap)
    else: # 输入值
        return __getInputParamMapFromFile(operateHomeMap)


# showFixedFileParamErrorBy

# ①从 jsonFile 中获取脚本的指定固定参数
def __getFixParamMapFromFile(operateHomeMap, pack_input_params_file_path):
    # 对 homeMap 进行处理
    operateDes = operateHomeMap['des']

    param_type = operateHomeMap['fixedType']
    if param_type == "dir-path-rel-this-dir" or param_type == "file-path-rel-this-dir":
        # 如果是相对目录
        param_value = operateHomeMap['fixedValue']
        dir_path=joinFullPath(pack_input_params_file_path, param_value)
        if not os.path.exists(dir_path):
            print(f"{RED}参数指向的文件获取失败，原因为计算出来的相对目录不存在。请检查您的 {YELLOW}{pack_input_params_file_path}{NC} 中选中的 {BLUE}{operateHomeMap}{NC} 里的 {BLUE}fixedValue{RED} 属性值 {BLUE}{param_value}{RED} 是否正确。（其会导致计算相对于 {YELLOW}{pack_input_params_file_path}{RED} 的该属性值路径 {YELLOW}{dir_path}{RED} 不存在)。{NC}")
            openFile(pack_input_params_file_path)
            
            return None
        else:
            param_key = operateHomeMap['resultForParam']
            return {
                "resultForParam": param_key,
                "resultValue": dir_path,
            }
    else:
        print(f"{RED}错误:不支持{param_type}的处理，请检查{NC}")
        return None
    

# ②从 jsonFile 中获取脚本的指定固定参数
def __getChooseParamMapFromFile(operateHomeMap):
    operateActionTypeDes="选择"

    # ③如果是选择，选择项有哪些，然后提示进行"选择"输入(只需要输入)
    operateDes = operateHomeMap['des']
    operateChooseMaps = operateHomeMap['chooseValues']
    for i, chooseMap in enumerate(operateChooseMaps):
        chooseName = chooseMap['name']
        if chooseName:
            print(f"{i+1}. {chooseName}")
        else:
            print(f"未找到id为{YELLOW}{chooseName}的用户{NC}")

    while True:
        person_input = input("请%s%s编号（自定义请填0,退出q/Q）：" % (operateActionTypeDes, operateDes))
        if person_input == "q" or person_input == "Q":
            exit()

        if not person_input.isnumeric():
            print("输入的不是一个数字，请重新输入！")
            continue

        if person_input == "0":
            personName=input("请输入%s名（退出q/Q）：" % (operateDes))
            if personName == "q" or personName == "Q":
                exit()
            break

        index = int(person_input) - 1
        if index >= len(operateChooseMaps):
            continue
        else:
            chooseValueMap = operateChooseMaps[index]
            personName = chooseValueMap["name"]
            break

    print(f"您{operateActionTypeDes}的{operateDes}：{YELLOW}{personName}{NC}")


    # ④选择的结果给谁用
    resultForParam = operateHomeMap['resultForParam']

    return {
        "resultForParam": resultForParam,
        "resultValue": personName,
    }


# ③从 jsonFile 中获取脚本的指定固定参数
def __getInputParamMapFromFile(operateHomeMap):
    # 其他情况，提示进行"完整的"输入
    operateActionTypeDes="输入"
    operateDes = operateHomeMap['des']
    while True:
        person_input = input("请%s%s名（退出q/Q）：" % (operateActionTypeDes, operateDes))
        if person_input == "q" or person_input == "Q":
            exit()

        personName=input("请输入%s名（退出q/Q）：" % (operateDes))
        if personName == "q" or personName == "Q":
            exit()
        break

    print(f"您{operateActionTypeDes}的{operateDes}：{YELLOW}{personName}{NC}")

    # ④选择的结果给谁用
    resultForParam = operateHomeMap['resultForParam']

    return {
        "resultForParam": resultForParam,
        "resultValue": personName,
    }




# import argparse
# parser = argparse.ArgumentParser()
# for item in json.loads(" ".join(__import__("sys").argv[1:])):
#     parser.add_argument(item)
# args = parser.parse_args()
# print(args)

# chooseAnswer()
# chooseTester()
dealActions()
# choosePlatform()
