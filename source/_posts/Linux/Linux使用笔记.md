---
title: Linux使用笔记
date: 2023-01-21 08:09:26
tags:
---

## WIFI热点

使用`linux-wifi-hotspot`即可。ArchLinux安装方式：

```shell
# archlinuxcn源
sudo pacman -S linux-wifi-hotspot
# 或者AUR
yay -S linux-wifi-hotspot
```

## KDE Connect

### 控制媒体播放

可以用手机控制电脑上的媒体播放，比如前进和后退等。把电脑连在电视上的时候比较有用。

### 发送文本

电脑KDE Connect GUI好像没有发送文本的功能，只能用命令行。先查看手机的设备名：

```shell
kdeconnect-cli -a
```

```text
- CDY-TN90: df757ff7464d6545 (paired and reachable)
```

可以看到设备名是`CDY-TN90`。然后就可以发送到这台手机了：

```shell
kdeconnect-cli --name CDY-TN90 --share-text testtest233
```

文本会被自动保存到手机剪切板。

## 安装字体

以Debian为例：

```shell
# Times New Roman
sudo apt install ttf-mscorefonts-installer
# 如果是matplotlib，还得清一下cache：https://stackoverflow.com/a/49884009
rm ~/.cache/matplotlib -rf
```
