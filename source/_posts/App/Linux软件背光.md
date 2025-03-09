---
title: Linux软件背光
date: 2024-12-14 23:33:25
tags:
---

有时候显示器的亮度已经调到最低了，但还是太亮了。这时候就需要软件背光了。

可以先试试`redshift`:

```shell
redshift -b 亮度
```

亮度是0.1到1之间的数。完整文档：<https://wiki.archlinux.org/title/redshift>

但不知道为什么我这里不管用。可能是因为我把内置显示器关了，只用外置显示器。

如果`redshift`不行，可以试试`xrandr`。首先查看所有显示设备：

```shell
xrandr
```

在里面找`connected primary`：

```text
HDMI-1 connected primary 2560x1440+0+0 (normal left inverted right x axis y axis) 597mm x 336mm
```

这就是我的显示器了。将其亮度调到原来的0.3倍：

```shell
xrandr --output HDMI-1 --brightness 0.3
```

如果要调回来：

```shell
xrandr --output HDMI-1 --brightness 1
```

注意，以上方法只在X11上有效。
