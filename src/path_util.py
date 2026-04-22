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

def get_qbase_python_module_path():
    import shutil
    qbase_path = shutil.which('qbase')
    if qbase_path:
        qbase_real_path = os.path.realpath(qbase_path)
        qbase_dir = os.path.dirname(qbase_real_path)
        return os.path.join(qbase_dir, 'pythonModuleSrc')
    return None

qbase_python_path = get_qbase_python_module_path()
if qbase_python_path and os.path.isdir(qbase_python_path):
    sys.path.insert(0, qbase_python_path)
    from path_util import (
        getAbsPathByRelativePath,
        joinFullPath_noCheck,
        joinFullPath_checkExsit,
        joinFullUrl,
    )
    # 别名，保持与旧版本兼容
    getAbsPathByFileRelativePath = getAbsPathByRelativePath
else:
    raise ImportError("Cannot find qbase pythonModuleSrc directory")
