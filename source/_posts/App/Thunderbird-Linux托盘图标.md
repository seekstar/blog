---
title: Thunderbird Linux托盘图标
date: 2023-10-18 17:07:20
tags:
---

官方只支持了windows上的托盘图标。

Linux上要支持托盘，可以使用SysTray-X，安装方法：<https://github.com/Ximi1970/systray-x#linux-distributions>

Arch Linux:

```shell
# KDE
sudo pacman -S systray-x-kde
# 其他
sudo pacman -S systray-x-common
```

然后重启Thunderbird就可以看到托盘图标了。

参考：<https://discourse.mozilla.org/t/persistant-tray-icon-for-linux/59215>
