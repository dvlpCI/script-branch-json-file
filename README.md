# script-branch-json-file

## 安装

* 确保已安装 brew 命令，详见 官网 https://brew.sh/zh-cn/

  ```
  ```

  

* [Mac终端上Homebrew的常用命令](https://www.jianshu.com/p/536abd711af2)

```shell
# 1、引入
brew tap dvlpCI/qtool 或者 brew tap dvlpCI/tools

# 2、安装
brew install qtool
# 如果上述命令执行失败，可能需要进入如下命令，删干净 qtool 相关问题
open /usr/local/var/homebrew/

# 3、使用:终端直接执行
qtool
# 其依赖qbase，请确保先执行 brew install qbase 安装 qbase。且安装过程请确保相应地址非private，即 https://github.com/dvlpCI/homebrew-qbase 和 https://github.com/dvlpCI/script-qbase 都不能private， 否则会导致qbase下载失败

输入 `qbase -help` 其会提示支持的命令。这里可得支持的命令及其含义分别为 {"-quickCmd":"快捷命令","-path":"支持的脚本"}
输入 `qbase -path`

# 3、更新
brew upgrade qtool

# 4、删除
brew uninstall qtool
```



## Shell 结果要点

### 1、结果

```shell
// printf "%s" 会保留\n等
printf "%s" "${responseJsonString}"
```


### 2、日志

```shell
# 使用>&2将echo输出重定向到标准错误，作为日志

function debug_log() {
	echo "$1" >&2  # 使用>&2将echo输出重定向到标准错误，作为日志
}



# 2>/dev/null 只将标准错误输出重定向到 /dev/null，保留标准输出。
# >/dev/null 2>&1 将标准输出和标准错误输出都重定向到 /dev/null，即全部丢弃。
```

