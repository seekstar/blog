---
title: Linux分离人声和伴奏
date: 2022-09-03 13:14:18
tags:
---

可以使用`Spleeter`。github: <https://github.com/deezer/spleeter>

## 安装Miniconda

```shell
wget https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda-latest-Linux-x86_64.sh
bash Miniconda-latest-Linux-x86_64.sh
```

安装过程会自动将以下内容加到.bashrc里：

```shell
# added by Miniconda2 4.0.5 installer
export PATH="/home/searchstar/miniconda2/bin:$PATH"
```

然后在`~/.condarc`里加入以下内容来使用清华镜像：

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

```shell
conda clean -i
```

试一下有没有用：

```shell
conda create -n myenv numpy
```

参考：

<https://mirrors.tuna.tsinghua.edu.cn/help/anaconda/>

[用Ubuntu子系统下载安装Miniconda3（小白版）](https://blog.csdn.net/wangcassy/article/details/123578709)

## 安装Spleeter

```shell
conda install -c conda-forge ffmpeg libsndfile
pip3 install spleeter
```

如果报这个错：`locale.Error: unsupported locale setting`

可以这样解决：

```shell
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
```

参考：[解决locale.Error: unsupported locale setting错误](https://zhuanlan.zhihu.com/p/61551172)

## 使用

```shell
spleeter separate -p spleeter:2stems -o output audio_example.mp3
```
