---
title: linux 非交互式安装rust
date: 2020-08-05 17:14:56
tags:
---

## 使用官方源

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
sh <(curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf) -y
```

就可以非交互式安装rust了。

## 使用国内镜像

详情：[Rust使用国内Crates 源、 rustup源 |字节跳动新的 Rust 镜像源以及安装rust](https://blog.csdn.net/inthat/article/details/106742193)

这里直接给脚本：

```shell
mkdir -p ~/.cargo
cat >> ~/.cargo/config <<EOF
[source.crates-io]
replace-with = 'rsproxy'

[source.rsproxy]
registry = "https://rsproxy.cn/crates.io-index"

[registries.rsproxy]
index = "https://rsproxy.cn/crates.io-index"

[net]
git-fetch-with-cli = true
EOF
cat >> ~/.profile <<EOF
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
EOF
source ~/.profile
sh <(curl --proto '=https' --tlsv1.2 -sSf https://rsproxy.cn/rustup-init.sh) -y
source "$HOME/.cargo/env"
```
