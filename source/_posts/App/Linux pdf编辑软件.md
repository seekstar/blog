---
title: Linux pdf编辑软件
date: 2021-10-10 10:17:04
---

## libreoffice draw

可以画直线、曲线、圆圈、方框，插入文本框，有的PDF甚至可以直接编辑原有的字。

旧版本可能有问题，建议安装新版本。可以用flatpak安装。教程：{% post_link App/"flatpak教程" %}

## Xournal / Xournal++

File->Annotate PDF->找到要编辑的PDF文件

Tools里选择Pen可以画线，选择Eraser可以擦掉画的线，但是不能擦掉原有内容，选择Highlighter可以当荧光笔用，选择Text可以插入文字，选择Image可以插入图片，选择Select Region可以移动插入的图片。

编辑完之后可以保存为`.xoj`文件。但是一定要注意这个xoj文件不是stand alone的，它是以原PDF文件作为背景的，所以原PDF文件一定要保存好，而且路径不能变。

但是这个软件好像已经没人维护了：<http://xournal.sourceforge.net/>

然后有一个C++重构版Xournal++好像挺活跃的：<https://github.com/xournalpp/xournalpp>

Xournal++的用法跟Xournal差不多。Xournal++在deepin商店里找不到。不过可以用flatpak安装，教程：{% post_link App/"flatpak教程" %}

## Okular

可以插入文本框，可以插入弹出式笔记，可以画线之类的，但是不能插入图片。

## Scribus

好像打不开PDF。而且最新版1.5.7在deepin上会段错误。

## 参考链接

<https://itsfoss.com/pdf-editors-linux/>
<https://www.2daygeek.com/best-pdf-editors-for-linux/>
