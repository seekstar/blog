---
title: pacman清理软件包缓存
date: 2022-04-27 15:52:16
tags:
---

pacman并不会自动清理下载的软件包，这样的好处是出问题之后可以方便地进行reinstall和downgrade，不然就只能从官方的仓库下载了，但是官方的仓库只保存最新版，所以只能将整个系统升级到最新版，而且出问题的时候可能会没有网络。但是软件包缓存过多的话可能会占用太多存储，所以如果存储不够可以清理pacman软件包缓存。

```shell
# 仅包含最近的三个版本
paccache -r
# 仅包含最近的1个版本
paccache -rk1
# 清理未安装软件包
pacman -Sc
# 清理缓存中所有内容
pacman -Scc
```

来源：

<https://wiki.archlinux.org/title/Pacman>

[pacman 安装包缓存位置及清理](http://t.zoukankan.com/lif323-p-13970346.html)

<https://ostechnix.com/recommended-way-clean-package-cache-arch-linux/>
