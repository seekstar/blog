---
title: conda使用笔记
date: 2025-05-15 13:15:38
tags:
---

## 安装

### 官方安装脚本

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda-latest-Linux-x86_64.sh
bash Miniconda-latest-Linux-x86_64.sh
```

安装过程会自动将以下内容加到.bashrc里：

```shell
# added by Miniconda2 4.0.5 installer
export PATH="/home/用户名/miniconda2/bin:$PATH"
```

参考：

<https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/>

[用Ubuntu子系统下载安装Miniconda3（小白版）](https://blog.csdn.net/wangcassy/article/details/123578709)

### {% post_link Distro/'使用国内源安装和使用Nix包管理器' Nix包管理器 %}

```shell
nix-channel --update
nix-env -iA nixpkgs.conda
# conda-shell会把基础环境安装到~/.conda，然后在conda-shell里执行`conda --version`，然后退出到原来的shell
# 直接执行conda-shell也会安装环境到~/.conda，但是会留在conda-shell里，不会退出到原来的shell
conda-shell -c "conda --version"
echo "export PATH=\"$HOME/.conda/bin:\$PATH\"" >> ~/.profile
. ~/.profile
# 会往~/.bashrc里加入一段代码
conda init
```

## 配置镜像

在`~/.condarc`里加入以下内容来使用清华镜像：

```text
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

## 创建虚拟环境

```shell
conda create -n 环境名字
```

激活环境

```shell
conda activate 环境名字
```

删除虚拟环境

```shell
conda remove -n 环境名字 --all
```

## 在虚拟环境中安装库

首先进入虚拟环境：`conda activate 环境名字`

然后：

```shell
conda install 包1 包2
```

如果是某个channel里的包：

```shell
conda install -c channel名 包1 包2
```

也可以这样：

```shell
conda install 包1 包2 channel名::包3 channel名::包4
```
