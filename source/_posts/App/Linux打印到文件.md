---
title: Linux打印到文件
date: 2022-11-17 13:40:05
tags:
---

有些发行版默认不支持打印到文件，需要手动安装该功能。

## 安装CUPS-PDF

以ArchLinux为例：

```shell
sudo pacman -S cups-pdf
```

## 添加打印机

以KDE Plasma为例：

设置 -> 添加打印机 -> CUPS-PDF

选择驱动：Generic -> CUPS-PDF Printer (no options) (en)

## 参考文献

<https://askubuntu.com/questions/81817/how-to-install-a-pdf-printer>
