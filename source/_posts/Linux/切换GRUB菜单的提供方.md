---
title: 切换GRUB菜单的提供方
date: 2022-01-10 13:15:54
tags:
---

安装Debian之后，GRUB菜单就变成Debian的了。但是Debian的GRUB菜单在高分屏下字特别小。

Deepin的GRUB菜单很好看，而且还可以方便地在设置里设置默认项。所以我想要将GRUB菜单切换回Deepin的。方法是在Deepin里执行：

```shell
sudo grub-install /dev/设备名
```

其中设备名是Deepin安装到的设备。

参考：<https://bbs.deepin.org/en/post/209123>
