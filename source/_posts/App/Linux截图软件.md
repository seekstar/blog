---
title: Linux截图软件
date: 2023-10-18 22:38:03
tags:
---

## deepin-screenshot

我觉得最好用。但是没人维护了。

## spectacle

KDE应用。可以截取当前活动窗口，也可以截取矩形区域。

在KDE的快捷键设置的列表里如果没有spectacle的话，可以选择`Add New` -> `Applications`，然后在里面选中spectacle，即可把spectacle加进去。

## shutter

界面有点像windows的截图工具。可以自动识别窗口。截图之后自动保存到剪切板。但是不能像deepin-screenshot那样在自动识别窗口模式拖动切换到选区模式。

## flameshot

全平台，可以添加箭头之类的。
运行之后会在状态栏出现一个火焰图标，然后点一下就可以截屏了。

缺点：

不能直接选中窗口：<https://github.com/flameshot-org/flameshot/issues/5>

KDE 6下选区的时候屏幕内容会缩小到左上角，而且会把鼠标也截进去。

## deepin-screen-recorder

可以录屏和截屏。但是截屏之后不能保存到剪切板：<https://github.com/linuxdeepin/developer-center/issues/5921>

## maim

更像是个命令行工具。

划取区域，或者点击来截取窗口：

```shell
maim -s > test.png
```

但是窗口识别没有实时预览，截取之后才能看到截取的是不是对的。

截取当前active window:

```shell
maim -i $(xdotool getactivewindow) > test.png
```

## HotShots

Arch Linux源里没有，好像只能用flatpak安装。

Grab window不知道为什么并没有让用户选择，而是直接把整个屏幕截下来了。

## dmenu_shot

<https://codeberg.org/mehrad/dmenu_shot>

选`Select_Window`之后点击一下，会自动回退到flameshot。终端输出：

```text
QSettings::value: Empty key passed
```

不知道怎么回事。

图形平台是X11。按照作者的说法应该是支持的才对：<https://github.com/flameshot-org/flameshot/issues/5#issuecomment-1586772954>
