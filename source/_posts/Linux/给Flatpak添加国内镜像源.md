---
title: 给flatpak添加国内镜像源
date: 2021-12-30 20:24:23
tags:
---

如果已经添加了flathub的话，就用remote-modify修改：

```shell
sudo flatpak remote-modify flathub --url=https://mirror.sjtu.edu.cn/flathub
```

参考：<https://xuyiyang.com.cn/archives/%E7%BB%99flatpak%E6%B7%BB%E5%8A%A0%E5%9B%BD%E5%86%85%E9%95%9C%E5%83%8F%E6%BA%90>

如果没有的话，就用remote-add添加：

```shell
sudo flatpak remote-add flathub https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo
```

一些可以用flatpak安装的软件：

## Xournal++

PDF编辑软件。

相关：<https://seekstar.github.io/2021/10/10/linux-pdf%E7%BC%96%E8%BE%91%E8%BD%AF%E4%BB%B6/>

## MyPaint

可以当草稿纸用。但是写多了字之后会很卡。

相关：<https://seekstar.github.io/2021/02/04/linux%E8%8D%89%E7%A8%BF%E7%BA%B8%E8%BD%AF%E4%BB%B6mypaint/>

## vscode

运行在容器里，所以不能访问系统里的SDK。而且好像不提供code命令？还是建议去官网下载安装包来安装。
