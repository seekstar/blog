---
title: Deepin使用笔记
date: 2024-11-29 23:19:38
tags:
---

Deepin V23

## 换源

官方源很慢。可以换成清华源。

`/etc/apt/sources.list`

原来的内容：

```text
deb https://community-packages.deepin.com/beige/ beige main commercial community
```

改成：

```text
deb https://mirrors.tuna.tsinghua.edu.cn/deepin/beige/ beige main commercial community
```

```shell
sudo apt update
sudo apt upgrade
```
