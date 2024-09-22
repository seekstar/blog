---
title: pacman使用笔记
date: 2022-07-30 11:58:48
tags:
---

## `-S, --sync`：源里的包

```shell
# 安装或升级某包
pacman -S 包名
# 当未安装或者版本较旧时才安装
# https://superuser.com/questions/568967/prevent-pacman-from-reinstalling-packages-that-were-already-installed
pacman -S --needed 包名
# 源中某包的详细信息
pacman -Si 包名
```

## `-R`: 移除某包

一般用`sudo pacman -Rs 包名`:

```text
-s, --recursive
	Remove each target specified including all of their dependencies, provided that (A) they are not required by other
	packages; and (B) they were not explicitly installed by the user. This operation is recursive and analogous to a
	backwards --sync operation, and it helps keep a clean system without orphans. If you want to omit condition (B), pass
	this option twice.
```

`-c`: cascade，同时移除依赖该包的其他包。例如A依赖B依赖C，那么`pacman -Rc C`会同时移除A B C。

参考：[pacman: cascade vs. recursive](https://bbs.archlinux.org/viewtopic.php?id=21470)

## `-F, --files`: Query the files database

首先需要更新一下file database:

```shell
pacman -Fy
```

一般用来查看命令由哪个包提供。比如查看`dig`命令由哪个包提供。有两种方法：

```shell
pacman -F dig
```

输出：

```text
extra/bind 9.16.25-1
    usr/bin/dig
community/epic4 2.10.10-2
    usr/share/epic/script/dig
```

这个方法可以自己写正则表达式匹配，可能比较灵活一点：

```shell
pacman -Fl | grep -e "/dig$"
```

`-e`: 使用正则表达式。

`$`: 匹配行末。

输出：

```text
bind usr/bin/dig
epic4 usr/share/epic/script/dig
```

## 所以安装`bind`

```shell
sudo pacman -S bind
dig -v
```

```text
DiG 9.18.0
```

参考：[manjaro pacman查看已安装命令隶属于哪个包(arch应该也行)](https://blog.csdn.net/LoveZoeAyo/article/details/107096964)

## `-Q`: 查看已安装的包

```shell
# 所有包
pacman -Q
# 某包
pacman -Q 包名
# 详细信息
pacman -Qi 包名
# 包内的所有文件
pacman -Ql 包名
# 查看文件由哪个包提供
# https://bbs.archlinux.org/viewtopic.php?id=90635
pacman -Qo 相对路径或绝对路径
```

这里面也包括用yay安装的包。

参考：

[pacman常用命令](https://hustlei.github.io/2018/11/msys2-pacman.html)

[How to find which package holds a file?](https://bbs.archlinux.org/viewtopic.php?id=90635)

### `-Qu`: 查看可更新包

先更新源，获取最新应用的列表：

```shell
sudo pacman -Sy
```

查询可更新包：

```shell
pacman -Qu
```

yay同理：

```shell
yay -Sy
yay -Qu
```

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

- {% post_link Distro/'pacman查看未安装的包内的文件' %}

- {% post_link Distro/'pacman清理软件包缓存' %}

- {% post_link Distro/'pacman升级指定包' %}

- {% post_link Distro/'ArchLinux修复系统目录和文件的权限' '修复系统目录和文件的权限' %}

- {% post_link Distro/'修复pacman升级时断电导致的问题' %}
