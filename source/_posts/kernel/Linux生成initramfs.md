---
title: Linux生成initramfs
date: 2022-06-29 13:48:37
tags:
---

## dracut

各发行版通用。

```text
dracut [OPTION...] [<image> [<kernel version>]]
```

例子：

```shell
# 给/boot/vmlinuz-5.1.0-amd64-desktop+生成initramfs
dracut initramfs-5.1.0-amd64-desktop+.img 5.1.0-amd64-desktop+
```

## update-initramfs

Debian系可用。

```shell
sudo update-initramfs -ck 要生成initramfs的内核版本
```
