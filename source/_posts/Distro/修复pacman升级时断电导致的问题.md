---
title: 修复pacman升级时断电导致的问题
date: 2022-07-11 10:16:47
tags:
---

pacman升级时断电可能会导致一些文件甚至是内核变成0长度。可以让pacman重装所有包来解决问题：

```shell
pacman -Qqn | sudo pacman -S - --overwrite=*
```

参考：

[[SOLVED]crash during upgrade, pacman broken](https://bbs.archlinux.org/viewtopic.php?id=250008)

<https://wiki.archlinux.org/title/pacman/Tips_and_tricks#Reinstalling_all_packages>

如果进不去系统的话用Live OS启动，挂载对应的操作系统的根文件系统，然后chroot进去重装所有包即可。然后可以先重启一下系统，如果能成功启动就可以了，否则可能是initramfs坏掉了，而initramfs是不归包管理器管的，所以重装所有包是无法修复的，需要手动重新生成initramfs，教程：{% post_link kernel/'Linux生成initramfs' %}
