'''
Author: dvlproad dvlproad@163.com
Date: 2023-04-16 00:10:18
LastEditors: dvlproad
LastEditTime: 2026-04-22 11:42:23
FilePath: path_util.py
Description: 路径的计算方法（从 qbase 导入）
'''
import os
import sys
import shutil
import importlib.util

def get_qbase_python_module_path():
    qbase_path = shutil.which('qbase')
    if qbase_path:
        qbase_real_path = os.path.realpath(qbase_path)
        qbase_dir = os.path.dirname(qbase_real_path)
        return os.path.join(qbase_dir, 'pythonModuleSrc')
    return None

qbase_python_path = get_qbase_python_module_path()
if qbase_python_path and os.path.isdir(qbase_python_path):
    qbase_path_util_file = os.path.join(qbase_python_path, 'path_util.py')
    spec = importlib.util.spec_from_file_location("qbase_path_util", qbase_path_util_file)
    qbase_path_util = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(qbase_path_util)

    getAbsPathByRelativePath = qbase_path_util.getAbsPathByRelativePath
    joinFullPath_noCheck = qbase_path_util.joinFullPath_noCheck
    joinFullPath_checkExsit = qbase_path_util.joinFullPath_checkExsit
    joinFullUrl = qbase_path_util.joinFullUrl
else:
    raise ImportError("Cannot find qbase pythonModuleSrc directory")
