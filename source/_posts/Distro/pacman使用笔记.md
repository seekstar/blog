---
title: pacman使用笔记
date: 2022-07-30 11:58:48
tags:
---

`--needed`: 当未安装或者版本较旧时才安装。

参考：https://superuser.com/questions/568967/prevent-pacman-from-reinstalling-packages-that-were-already-installed

## 查看已安装的包

```shell
pacman -Q
```

这里面也会把用yay安装的包列出来。

## 查看某包被哪些包依赖

```shell
pacman -Qi 包名
```

里面的`Required By`后面的就是依赖这个包的包。

或者用`pkgtools`包里的`whoneeds`：

```shell
# archlinuxcn源里也有pkgtools
sudo yay -S pkgtools
whoneeds 包名
```

## 无效或已损坏的软件包

可能是`archlinux-keyring`过时了，需要更新一下：

```shell
sudo pacman -Sy archlinux-keyring && sudo pacman -Su
```

来源：

<https://wiki.archlinux.org/title/Pacman#%22Failed_to_commit_transaction_(invalid_or_corrupted_package)%22_error>

<https://wiki.archlinux.org/title/Pacman/Package_signing#Upgrade_system_regularly>

## 不再使用的依赖

```shell
pacman -Qdt
```

其中有一些可能是yay自动下载用于构建包的，所以最好肉眼挑选出不需要的包，手动卸载。如果确认里面没有需要使用的包，才可以用这条指令把它们全部卸掉：`pacman -Rsn $(pacman -Qdtq)`。

来源：<https://bbs.archlinux.org/viewtopic.php?id=57431>

## 其他

- {% post_link Distro/'pacman查看可更新包' %}

- {% post_link Distro/'pacman查看命令由哪个包提供' %}

- {% post_link Distro/'pacman清理软件包缓存' %}

- {% post_link Distro/'pacman升级指定包' %}

- {% post_link Distro/'ArchLinux修复系统目录和文件的权限' '修复系统目录和文件的权限' %}

- {% post_link Distro/'修复pacman升级时断电导致的问题' %}
