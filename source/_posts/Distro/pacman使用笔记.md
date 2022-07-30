---
title: pacman使用笔记
date: 2022-07-30 11:58:48
tags:
---

## 无效或已损坏的软件包

可能是`archlinux-keyring`过时了，需要更新一下：

```shell
sudo pacman -Sy archlinux-keyring && sudo pacman -Su
```

来源：

<https://wiki.archlinux.org/title/Pacman#%22Failed_to_commit_transaction_(invalid_or_corrupted_package)%22_error>

<https://wiki.archlinux.org/title/Pacman/Package_signing#Upgrade_system_regularly>

## 其他

- {% post_link Distro/'pacman查看可更新包' %}

- {% post_link Distro/'pacman查看命令由哪个包提供' %}

- {% post_link Distro/'pacman清理软件包缓存' %}

- {% post_link Distro/'pacman升级指定包' %}

- {% post_link Distro/'ArchLinux修复系统目录和文件的权限' '修复系统目录和文件的权限' %}

- {% post_link Distro/'修复pacman升级时断电导致的问题' %}
