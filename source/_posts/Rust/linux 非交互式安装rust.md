---
title: linux 非交互式安装rust
date: 2020-08-05 17:14:56
tags:
---

官网提供的安装方式是交互式的，需要手动输入回车来使用默认配置。
```shell
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```
其实下载下来的脚本里有使用帮助
```shell
rustup-init 1.22.1 (76644d669 2020-07-08)
The installer for rustup

USAGE:
    rustup-init [FLAGS] [OPTIONS]

FLAGS:
    -v, --verbose           Enable verbose output
    -q, --quiet             Disable progress output
    -y                      Disable confirmation prompt.
        --no-modify-path    Don't configure the PATH environment variable
    -h, --help              Prints help information
    -V, --version           Prints version information

OPTIONS:
        --default-host <default-host>              Choose a default host triple
        --default-toolchain <default-toolchain>    Choose a default toolchain to install
        --default-toolchain none                   Do not install any toolchains
        --profile [minimal|default|complete]       Choose a profile
    -c, --component <components>...                Component name to also install
    -t, --target <targets>...                      Target name to also install
```
可以看到`-y`就是非交互式模式了。
所以在脚本中写入：
```shell
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf > rustup.sh
sh rustup.sh -y
sudo bash -c "echo source $HOME/.cargo/env >> /etc/bash.bashrc"
```
就可以非交互式安装rust了。
