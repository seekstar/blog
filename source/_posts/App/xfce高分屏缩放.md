---
title: xfce高分屏缩放
date: 2023-02-23 21:44:20
tags:
---

Settings Manager -> Appearance -> Settings -> Window Scaling -> 调成2x

然后logout，再login，系统自带的组件就变大了。

注意，与其他桌面不同，Settings Manager -> Display中的Scale调整的是桌面本身的大小，其越大，桌面就越大，而桌面中的各个组件看起来就越小。相关：

[Display - wrong behaviour of scale](https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/259)

<https://www.reddit.com/r/xfce/comments/lg4eji/fractional_scaling_in_416_makes_things_smaller/>

这个系统自带缩放设置只对系统自带的组件有效。为了让其他软件的窗口也进行缩放，需要进行一些额外设置。

## Qt

设置Qt应用（如Seafile、konsole）的缩放系数。将以下内容放入`/etc/profile`：

```shell
export QT_SCALE_FACTOR=2
```

然后重启即可生效。

## 参考文献

<https://wiki.archlinux.org/title/HiDPI>
