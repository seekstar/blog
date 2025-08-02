---
title: linglong学习笔记
date: 2025-02-17 20:29:19
tags:
---

## 安装

### ArchLinux

```shell
sudo pacman -S --needed linyaps
```

安装的包的`.desktop`文件在`/var/lib/linglong/entries/share/applications`下。注销重新登录之后这个目录才会出现在`XDG_DATA_DIRS`里，安装的软件才能在启动器里找到。

之后`ll-cli install`的时候要加`sudo`。

## 常用的命令

```shell
# 搜索
ll-cli search xxx
# 安装某包
ll-cli install 包名
# 列出所有已安装的包
ll-cli list
# 卸载某包
ll-cli uninstall 包名
# 运行某包
ll-cli run 包名
```

## 常用软件

### Seafile

```shell
ll-cli install com.seafile-gui.linyaps
```

### 网易云音乐

```shell
ll-cli install com.163.music
```
