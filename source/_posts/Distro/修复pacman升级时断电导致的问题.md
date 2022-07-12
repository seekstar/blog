---
title: 修复pacman升级时断电导致的问题
date: 2022-07-11 10:16:47
tags:
---

## 重装所有包

pacman升级时断电可能会导致一些文件甚至是内核变成0长度。可以让pacman重装所有包来解决问题：

```shell
pacman -Qqn | sudo pacman -S - --overwrite=*
```

参考：

[[SOLVED]crash during upgrade, pacman broken](https://bbs.archlinux.org/viewtopic.php?id=250008)

<https://wiki.archlinux.org/title/pacman/Tips_and_tricks#Reinstalling_all_packages>

## 重装内核后initramfs没有自动生成

如果进不去系统的话用Live OS启动，挂载对应的操作系统的根文件系统，然后chroot进去重装所有包即可。然后可以先重启一下系统，如果能成功启动就可以了，否则可能是重新安装内核后initramfs没有自动生成：

```shell
sudo pacman -S linux
```

报错：

```text
==> WARNING: Preset file `/etc/mkinitcpio.d/linux.preset' is empty or does not contain any presets.
```

解决方案是删掉这个空的文件，然后重新安装内核：

```shell
sudo rm /etc/mkinitcpio.d/linux.preset
sudo pacman -S linux
```

然后`/etc/mkinitcpio.d/linux.preset`和两个initramfs `/boot/initramfs-linux.img`以及`/boot/initramfs-linux-fallback.img`就都有了。

参考：<https://unix.stackexchange.com/questions/571124/no-mkinitcpio-preset-present>
