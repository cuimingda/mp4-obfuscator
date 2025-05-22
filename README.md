# mp4-obfuscator

会将当前目录所有mp4文件中，meta属性的comment字段修改为一个随机数

## Install

安装AtomicParsley

```shell
brew install atomicparsley
```

确保系统中提供 `uuidgen` 命令（在大多数 Linux 发行版中属于 util-linux 包，macOS 默认自带）。
配置

```shell
ln -s "$(pwd)/mp4-obfuscator.sh" /usr/local/bin/
```

## Usage

```shell
mp4-obfuscator.sh
```
