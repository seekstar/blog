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
# 删除没有被任何application使用的runtime和extension
flatpak uninstall --unused
# 列出已安装的包
flatpak list
flatpak run 包名(比如com.jgraph.drawio.desktop)
# 查看源列表
flatpak remotes
# 或者flatpak remote-list
# 似乎不能看某个remote的URL之类的: https://github.com/flatpak/flatpak/issues/1983
```

不同于apt，flatpak可以并行安装。安装的软件存放在`~/.var/app/`和`/var/lib/flatpak/app`里。一般来讲，软件的启动入口一般在`/var/lib/flatpak/app/com.jgraph.drawio.desktop/current/active/export/bin`。

## 为应用设置代理

由于flatpak的应用是运行在沙箱里的，看不到系统代理，所以如果应用需要使用代理的话，需要手动在沙箱环境里配置系统代理：

<https://seekstar.github.io/2022/01/06/flatpak%E5%BA%94%E7%94%A8%E8%AE%BE%E7%BD%AE%E4%BB%A3%E7%90%86/>

## 闭源软件

flatpak很适合用来安装闭源软件，因为闭源软件的行为不可控，而flatpak可以将闭源软件的活动范围限制在一个沙箱中。

### QQ

`com.qq.QQ`

### 微信

`com.tencent.WeChat`

### Steam

`com.valvesoftware.Steam`

#### 解决steam字体在高分屏下过小的问题

```shell
flatpak install com.github.tchx84.Flatseal
```

然后在启动器里打开`Flatseal`，在`Environment`里加上：

```shell
STEAM_FORCE_DESKTOPUI_SCALING=2
```

3000x2000的屏幕分辨率建议用`2`。

参考：

<https://superuser.com/questions/1762685/font-size-in-flatpak-obs>

<https://forum.manjaro.org/t/steam-fontsize-to-small-the-solution/142572/7>

### 腾讯会议

`com.tencent.wemeet`

### Zoom

`us.zoom.Zoom`

会议软件。

### Baidu Netdisk

`com.baidu.NetDisk`

只能看到`Downloads`, `Documents`, `Desktop`, `Music`, `Pictures`, `Videos`这几个路径，所以上传文件的时候要先把文件放到这些目录，然后才能拖拽上传。

### 国际版Minecraft

`com.mojang.Minecraft`

### WPS国际版

`com.wps.Office`

英文界面，不能登录帐号，没有云同步。但是可以正常显示中文。

### 音乐软件

#### QQ音乐

`com.qq.QQmusic`

只能听，不能下载歌曲

#### spotify

`com.spotify.Client`

好像不会自动使用系统代理，要手动设置代理。

就算充了premium，也只能缓存歌曲，不能下载成mp3：<https://community.spotify.com/t5/Content-Questions/Can-I-download-music-to-my-MP3-player/td-p/322028>

#### 网易云音乐

`com.netease.CloudMusic`

好像连不上网络。Flatseal里看到已经给了网络权限，不知道怎么回事。

## 开源软件

有些开源软件在发行版的软件源里没有或者版本太旧，这时可以考虑使用flatpak安装。

### 思源笔记

`org.b3log.siyuan`

本地化的笔记。支持webdav同步。

### Inkscape

`org.inkscape.Inkscape`

矢量绘图软件。

### KeePassXC

密码管理器。要把apt安装的旧版卸载之后，Deepin启动器上的才会变成flatpak的版本。

### LibreOffice

`org.libreoffice.LibreOffice`

里面的`LibreOffice Draw`是很棒的PDF编辑工具。

### MyPaint

可以当草稿纸用。但是写多了字之后会很卡。

相关：<https://seekstar.github.io/2021/02/04/linux%E8%8D%89%E7%A8%BF%E7%BA%B8%E8%BD%AF%E4%BB%B6mypaint/>

### Motrix

p2p下载客户端。支持多种p2p链接。

### Plots

`com.github.alexhuntley.Plots`

<https://github.com/alexhuntley/Plots>

`Plots`是一款非常简单的函数作图工具，直接输入表达式即可。可以是只含x的表达式，也可以是一个含x和y的等式。

可以定义一些常量，然后在之后的表达式里使用这个常量。例如先输入`s=1.747`，再输入`k=0.0819`，最后输入`\frac{1}{s}(1+\frac{kx}{s})^{-1-\frac{1}{k}}`：

$$\frac{1}{s}(1+\frac{kx}{s})^{-1-\frac{1}{k}}$$

对应函数的曲线就会画出来了。

#### 存在的问题

<https://github.com/alexhuntley/Plots/issues/146>

不支持中文locale。会报错：

```text
        Using the fallback 'C' locale.
Traceback (most recent call last):
  File "/app/bin/plots", line 8, in <module>
    sys.exit(main())
  File "/app/lib/python3.10/site-packages/plots/__init__.py", line 22, in main
    plots.Plots().run(sys.argv)
  File "/app/lib/python3.10/site-packages/plots/plots.py", line 42, in __init__
    plots.i18n.bind()
  File "/app/lib/python3.10/site-packages/plots/i18n.py", line 26, in bind
    locale.setlocale(locale.LC_ALL, "")
  File "/usr/lib/python3.10/locale.py", line 620, in setlocale
    return _setlocale(category, locale)
locale.Error: unsupported locale setting
```

解决方法是用命令行指定locale：

```shell
flatpak run --env=LC_ALL="en_US.UTF-8" com.github.alexhuntley.Plots
```

### Thunderbird

Mozilla出品的邮件客户端。

### Xournal++

PDF编辑软件。

相关：<https://seekstar.github.io/2021/10/10/linux-pdf%E7%BC%96%E8%BE%91%E8%BD%AF%E4%BB%B6/>

### Zotero

一款文献管理器。可以选择把文献导出为文件，也可以直接把文献拖到文本编辑器，格式在`Edit -> Preferences -> Export -> Item Format`设置。

参考：

<https://www.zotero.org/support/creating_bibliographies#quick_copy>

<https://forums.zotero.org/discussion/87285/export-bibtex-to-clipboard>

### Seafile

云盘客户端。但是截至`9.0.6`，flatpak版本没有单点登录。而且高分屏下窗口很小。

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

```text
bash: /var/lib/flatpak/app/com.jgraph.drawio.desktop/current/active/export/bin/com.jgraph.drawio.desktop：/bin/sh：解释器错误: 没有那个文件或目录
```

这是因为这个脚本的后缀名是`.desktop`，然后系统以为它是启动器。

### Matrix客户端

#### Element

包名是im.riot.Riot。需要配置代理。有一个很大的问题，是flatpak运行在沙箱环境中，默认传文件时不能看到系统里的文件。可以设置其允许读取home目录下的文件：

```shell
# https://docs.flatpak.org/en/latest/sandbox-permissions.html#filesystem-access
# https://github.com/flathub/im.riot.Riot/issues/33
flatpak override --user --filesystem=home:ro im.riot.Riot
```

#### Nheko

```shell
flatpak install io.github.NhekoReborn.Nehko
```

### Telegram

包名是`org.telegram.desktop`。需要注销重新登录才能在deepin启动器里找到。需要配置代理，用`flatpak run --command=sh`的方法好像没用，貌似要在应用内设置代理。

### torbrowser-launcher

launcher能打开，但是在系统启动器死活打不开tor browser。。。

通过launcher下载好tor browser之后，其实可以直接在命令行执行这个打开tor browser：

```shell
~/.var/app/com.github.micahflee.torbrowser-launcher/data/torbrowser/tbb/x86_64/tor-browser_zh-CN/Browser/start-tor-browser
```

注意如果选择下载的是英文版，那其中的`tor-browser_zh-CN`要换掉。

关于tor browser本身能不能进flatpak可以看这个issue:

<https://gitlab.torproject.org/tpo/applications/tor-browser/-/issues/25578>

### Firefox国际版

`org.mozilla.firefox`

要先把系统里旧的firefox卸载，不然启动器启动的还是旧版本。

在浏览器里没法把自己设置为默认浏览器了。但是一般可以在系统设置里手动设置。Deepin是在`设置->默认程序->网页`。

我这里一开始是正常的，但是过了几天之后显示就出问题了。
