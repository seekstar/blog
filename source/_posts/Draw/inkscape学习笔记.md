---
title: inkscape学习笔记
date: 2021-06-15 22:47:51
---

视频教程：<https://www.bilibili.com/video/BV1Qf4y117Hg>

## 常用

- {% post_link App/Linux在PDF中插入文字 插入文字 %}
- {% post_link Draw/inkscape裁剪 裁剪 %}

## P1 界面和基本图

选择工具：快捷键`s`

鼠标左键选择对象，多次选择可以在调整大小模式和旋转模式之间切换。旋转模式中，中间的加号是旋转时的轴，可通过拖动调节。

选择对象后，可以单击下面的颜色调节填充色，按住shift再单击颜色可以调节边框色。

## P2 形状工具和选择

双击对象之后会进入第三个模式，此时会出现小正方形和小圆圈，每个对象可能不一样。对于矩形，有两个小正方形用于调整大小，两个小圆圈用于调整圆角。对于椭圆，同样有两个小正方形用于调整大小，但是拖动小圆圈时，如果在椭圆外面，就是一个吃豆人的形状，如果在椭圆里面，就是弓的形状。在这个模式下，上面的工具栏的最右边有选项可以将小圆圈的效果清空，例如对于正方形可以直接将角变得锐利，对于椭圆可以直接变成整个椭圆。

星形和多边形可以在上面的菜单栏里调整角的个数和圆角的程度。还有螺旋形，用法类似。

## P3 填充和描边设置

`对象->填充和笔刷`可以调整填充和边框的样式（笔刷就是边框）。
RGBA中的A就是透明度。还可以调整模糊、渐变、边框宽度、边框线型等等。

## P4 组，级别和对象选择

ctrl+d原地复制。

长按shift多选，然后`右键->群组`或者ctrl+g，即可将这些对象编入一组，以后就可以当作同一个对象处理了，`右键->解除群组`或者ctrl+shift+g即可解除群组。

tab键可以从最底层遍历到最顶层的对象。按住alt然后多按几次左键可以选择到躲在下面的对象，要拖动的话要按住alt。

## 调整页面大小

菜单栏 -> 文件 -> 文档属性

如果是双栏的论文，作单栏的图可以把宽度调成85mm

## 矩形

左边工具栏选择`矩形工具`，或者按快捷键`r`。

用选择工具选中之后，可以调整`填充与描边`。透明度调成0是完全透明。描边样式可以调整线宽和线型。默认情况下改变矩形形状时线宽也会跟着改，取消激活上方工具栏最右边的这个图标即可：![](https://www.ycproject.cn/_images/15zoom-stroke.svg)

## 文字

左边工具栏选择`文本工具`，或者按快捷键`t`。可以在上面的工具栏调整字号和行距。

注意，文字的颜色是由`填充`决定的。如果填充是透明的，那文字就看不到。

填充背景色：滤镜->滤镜编辑器，把滤镜勾上，然后调整`浸漫`下面的颜色和不透明度即可。

参考：[inkscape文本框背景颜色填充](https://blog.csdn.net/qq_40990642/article/details/122175619)

## 直线

左边工具栏选择`钢笔工具`，或者按快捷键`b`。然后在上方工具栏的最左边选择模式。直线的话是选折线模式。

按`ctrl`吸附角度，默认步进是15度，也就是吸附到0、15、30、45、60、75、90度。步进可以在`首选项`里调整。

按`Enter`或者右键取消绘制，`Shift+Enter`完成绘制。

要给直线加上箭头，只需要选择`描边样式`里的`标记`即可。

## 参考线

画一条直线，然后在菜单栏中选择 对象->对象转换为参考线，或者按快捷键`Shift+G`。

在右侧工具栏的最上面点击左三角形符号，点击`开启吸附`。或者也可以按快捷键`%`（一般是`Shift+5`来开启吸附。然后在移动对象的时候按`ctrl`就可以吸附到参考线上。除此之外还有等距吸附等很方便的功能。按住`Shift`可以暂时禁用吸附。

## 圆圈编号

可以直接复制进去

- 白圈数字

①②③④⑤⑥⑦⑧⑨⑩⑪⑫⑬⑭⑮⑯⑰⑱⑲⑳㉑㉒㉓㉔㉕㉖㉗㉘㉙㉚㉛㉜㉝㉞㉟㊱㊲㊳㊴㊵㊶㊷㊸㊹㊺㊻㊼㊽㊾㊿

- 小写字母

ⓐⓑⓒⓓⓔⓕⓖⓗⓘⓙⓚⓛⓜⓝⓞⓟⓠⓡⓢⓣⓤⓥⓦⓧⓨⓩ

- 大写字母

ⒶⒷⒸⒹⒺⒻⒼⒽⒾⒿⓀⓁⓂⓃⓄⓅⓆⓇⓈⓉⓊⓋⓌⓍⓎⓏ

- 来源

[如何输入带黑圈的1-100 的特殊符号？快快收藏这3个小技巧！](https://www.sohu.com/a/668072464_121124316)

[值得收藏：阿拉伯数字符号、带圈数字符号、罗马数字序号、常用序号编号输入法](https://niuchao.com/blog/cc901a86a409da183d6b8bb35d0c0972.html)

## 图标（符号）

inkscape内置了一些图标。在菜单栏选择 对象 -> 符号 即可在右边打开符号选择窗口。在下拉框里选择`所有符号集`，然后在搜索框里即可搜索想要的符号。注意，如果语言是中文，而且这个符号有中文名，那必须搜中文才能搜到这个图标。下面是一些常用的符号。

| 符号 | 中文名 |
| 照相机 | 照片（应该是翻译错了）|

找到了需要的图标之后把它拖到绘图区即可。

此外，还可以给inkscape安装额外的图标：<https://github.com/PanderMusubi/inkscape-open-symbols#how-do-i-install-inkscape-open-symbols>

- Debian

```shell
sudo apt install inkscape-open-symbols
```

- Arch Linux

```shell
yay -S inkscape-open-symbols-git
```

然后重启inkscape即可。

常用的符号：

| 符号 | 搜索关键词 |
| 锁 | lock |

原文：[Use Font Awesome in Inkscape](https://superuser.com/a/1219878)

## hatch

用这里提供的pattern：<https://inkscape.org/~henkjan_nl/%E2%98%85patterns-for-mechanical-drawings-in-inkscape>

这里提供的安装方法：[Alternate install method](https://github.com/zirafa/inkscape-hatch-patterns/issues/5)

```shell
wget https://raw.githubusercontent.com/seekstar/inkscape-hatch-patterns/paint-server/paint/hatch-patterns.svg
cp hatch-patterns.svg ~/.config/inkscape/paint/
```

然后关闭再重新打开inkscape。点击菜单栏里的`对象` -> 绘画服务器，`Hatch Patterns`里的就是新安装的hatch patterns。

hatch太密的话，pdf缩小来看的时候会变成一坨黑的。所以我一般用`Hatch 1.7`系列，疏密刚刚好。

## 存在的问题

[Markers / Arrow Heads don't use stroke gradient](https://gitlab.com/inkscape/inbox/-/issues/6730)

## 参考文献

[Inkscape操作指南](https://www.ycproject.cn/inkscape/inkscape.html)
