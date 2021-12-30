---
title: flatpak教程
date: 2021-12-30 22:53:10
tags:
---

flatpak是一款跨发行版的包管理器。官网：<https://flatpak.org/>

这里有各个发行版的安装方法：<https://flatpak.org/setup/>

这里以Deepin为例。

```shell
sudo apt install flatpak
```

接下来是添加源。官方源：

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

但是这个太慢了，建议添加国内镜像源，教程：<https://seekstar.github.io/2021/12/30/%E7%BB%99flatpak%E6%B7%BB%E5%8A%A0%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90/>

然后会有这样一个提示：

```shell
Note that the directories 

'/var/lib/flatpak/exports/share'
'/home/searchstar/.local/share/flatpak/exports/share'

are not in the search path set by the XDG_DATA_DIRS environment variable, so
applications installed by Flatpak may not appear on your desktop until the
session is restarted.
```

意思是说，在重启之后，用flatpak安装的软件才能用桌面系统访问到。所以接下来先重启。

重启之后就可以正常使用了。常用的命令：

```shell
flatpak search xxx
flatpak install xxx
flatpak uninstall xxx
flatpak list # 列出已安装的包
```

不同于apt，flatpak可以并行安装。安装的软件存放在```~/.var/app/```。

一些可以用flatpak安装的软件：

## Xournal++

PDF编辑软件。

相关：<https://seekstar.github.io/2021/10/10/linux-pdf%E7%BC%96%E8%BE%91%E8%BD%AF%E4%BB%B6/>

## MyPaint

可以当草稿纸用。但是写多了字之后会很卡。

相关：<https://seekstar.github.io/2021/02/04/linux%E8%8D%89%E7%A8%BF%E7%BA%B8%E8%BD%AF%E4%BB%B6mypaint/>

## vscode

运行在容器里，所以不能访问系统里的SDK。而且好像不提供code命令？还是建议去官网下载安装包来安装。

## drawio

画图软件。

## WPS

国产办公软件。

## Zoom

会议软件。

## spotify

音乐软件

## Element

包名是im.riot.Riot，但是用flatpak装的话，好像不能使用代理？官网的方法安装的可以用代理。

## torbrowser-launcher

launcher能打开，但是tor browser死活打不开。。。
