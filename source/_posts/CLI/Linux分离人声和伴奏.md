---
title: Linux分离人声和伴奏
date: 2022-09-03 13:14:18
tags:
---

可以使用`Spleeter`。github: <https://github.com/deezer/spleeter>

## 安装conda

教程：{% post_link 'shell/conda使用笔记.md' %}

试一下有没有用：

```shell
conda create -n myenv numpy
```

## 安装Spleeter

```shell
conda install -c conda-forge ffmpeg libsndfile
pip3 install spleeter
```

如果报这个错：`locale.Error: unsupported locale setting`

设置一下locale即可：

```shell
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
```

参考：[解决locale.Error: unsupported locale setting错误](https://zhuanlan.zhihu.com/p/61551172)

## 使用

```shell
spleeter separate -p spleeter:2stems -o output audio_example.mp3
```
