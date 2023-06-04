#!/bin/bash
:<<!
测试的脚本
!

# shell 参数具名化
show_usage="args: [-pl , -pt , -pn, -saveToF]\
                                  [--platformType=, --package_target_type=, --package_network_type=, --save_to_file=]"

while [ -n "$1" ]
do
        case "$1" in
                -pl|--platformType) PlatformType=$2; shift 2;;
                -pt|--package_target_type) PackageTargetType=$2; shift 2;;
                -pn|--package_network_type) PackageNetworkType=$2; shift 2;;
                -saveToF|--save_to_file) APPEVN_SAVE_TO_FILE=$2; shift 2;;
                --) break ;;
                *) echo $1,$2,$show_usage; break ;;
        esac
done


exit_script() { # 退出脚本的方法，省去当某个步骤失败后，还去继续多余的执行其他操作
    exit 1
}

if [ ! -f "${APPEVN_SAVE_TO_FILE}" ]; then
    printf "文件 APPEVN_SAVE_TO_FILE=${APPEVN_SAVE_TO_FILE}不能存在，请检查"
    echo "这是echo"
    exit_script
fi

echo "所有脚本执行结束"