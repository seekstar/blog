---
title: flatpak教程
date: 2021-12-30 22:53:10
tags:
---

## 安装

flatpak是一款跨发行版的包管理器。官网：<https://flatpak.org/>

这里有各个发行版的安装方法：<https://flatpak.org/setup/>

这里以Deepin为例。

```shell
sudo apt install flatpak
```

## 添加源

官方源：

```shell
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

但是这个太慢了，建议添加国内镜像源，教程：<https://seekstar.github.io/2021/12/30/%E7%BB%99flatpak%E6%B7%BB%E5%8A%A0%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90/>

## 重启

会有这样一个提示：

```shell
Note that the directories 

'/var/lib/flatpak/exports/share'
'/home/searchstar/.local/share/flatpak/exports/share'

are not in the search path set by the XDG_DATA_DIRS environment variable, so
applications installed by Flatpak may not appear on your desktop until the
session is restarted.
```

意思是说，在重启之后，用flatpak安装的软件才能用桌面系统访问到。所以接下来先重启。

重启之后就可以正常使用了。但是即使之后这两个目录加入到`XDG_DATA_DIRS`了，有些应用可能仍然需要注销并且重新登录才能在启动器找到。

## 常用的命令

```shell
flatpak search xxx
flatpak install xxx
flatpak uninstall xxx
flatpak list # 列出已安装的包
flatpak run 包名(比如com.jgraph.drawio.desktop)
```

不同于apt，flatpak可以并行安装。安装的软件存放在`~/.var/app/`和`/var/lib/flatpak/app`里。一般来讲，软件的启动入口一般在`/var/lib/flatpak/app/com.jgraph.drawio.desktop/current/active/export/bin`。

## 为应用设置代理

由于flatpak的应用是运行在沙箱里的，看不到系统代理，所以如果应用需要使用代理的话，需要手动在沙箱环境里配置系统代理：

<https://seekstar.github.io/2022/01/06/flatpak%E5%BA%94%E7%94%A8%E8%AE%BE%E7%BD%AE%E4%BB%A3%E7%90%86/>

## 一些可以用flatpak安装的软件

### Xournal++

PDF编辑软件。

相关：<https://seekstar.github.io/2021/10/10/linux-pdf%E7%BC%96%E8%BE%91%E8%BD%AF%E4%BB%B6/>

### MyPaint

可以当草稿纸用。但是写多了字之后会很卡。

相关：<https://seekstar.github.io/2021/02/04/linux%E8%8D%89%E7%A8%BF%E7%BA%B8%E8%BD%AF%E4%BB%B6mypaint/>

### Zoom

会议软件。

### spotify

音乐软件

### Motrix

p2p下载客户端。支持多种p2p链接。

### Shadowsocks-Qt5

```shell
flatpak install shadowsocks
```

### 国际版Minecraft

`com.mojang.Minecraft`

### Clash for Windows

`io.github.Fndroid.clash_for_windows`

别被名字骗了，现在支持Linux了。

### LibreOffice

`org.libreoffice.LibreOffice`

里面的`LibreOffice Draw`是很棒的PDF编辑工具。

### Zotero

一款文献管理器。

### KeePassXC

密码管理器。要把apt安装的旧版卸载之后，Deepin启动器上的才会变成flatpak的版本。

其实我觉得2.6.6还没有2.3.4好用。新版上创建条目的时候不会要求输入两遍了，而且也不会显示密码强度。

### Seafile

但是没有单点登录。

### drawio

画图软件。装完之后Deepin系统的启动器里并找不到drawio，只能这样启动：

```shell
flatpak run com.jgraph.drawio.desktop
```

而且如果执行其启动脚本的话：

```shell
/var/lib/flatpak/app/com.jgraph.drawio.desktop/current/active/export/bin/com.jgraph.drawio.desktop
```

会报错：

```
bash: /var/lib/flatpak/app/com.jgraph.drawio.desktop/current/active/export/bin/com.jgraph.drawio.desktop：/bin/sh：解释器错误: 没有那个文件或目录
```

这是因为这个脚本的后缀名是`.desktop`，然后系统以为它是启动器。

### Element

包名是im.riot.Riot。需要配置代理。有一个很大的问题，是flatpak运行在沙箱环境中，所以传文件时不能看到系统里的文件。所以还是建议用官网提供的方式安装。

### Telegram

包名是`org.telegram.desktop`。需要注销重新登录才能在deepin启动器里找到。需要配置代理，用`flatpak run --command=sh`的方法好像没用，貌似要在应用内设置代理。这个好像就能访问系统里的文件，这说明是Element打包有问题。

### torbrowser-launcher

launcher能打开，但是在系统启动器死活打不开tor browser。。。

通过launcher下载好tor browser之后，其实可以直接在命令行执行这个打开tor browser：

```shell
~/.var/app/com.github.micahflee.torbrowser-launcher/data/torbrowser/tbb/x86_64/tor-browser_zh-CN/Browser/start-tor-browser
```

注意如果选择下载的是英文版，那其中的`tor-browser_zh-CN`要换掉。

关于tor browser本身能不能进flatpak可以看这个issue:

<https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/25578>

### vscode

运行在容器里，所以不能访问系统里的SDK。而且好像不提供code命令？还是建议去官网下载安装包来安装。

### Firefox国际版

`org.mozilla.firefox`

要先把系统里旧的firefox卸载，不然启动器启动的还是旧版本。

在浏览器里没法把自己设置为默认浏览器了。但是一般可以在系统设置里手动设置。Deepin是在`设置->默认程序->网页`。

我这里一开始是正常的，但是过了几天之后显示就出问题了。

### WPS

国产办公软件。但是flatpak上只有英文版的。
