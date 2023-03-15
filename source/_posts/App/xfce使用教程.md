---
title: xfce使用教程
date: 2023-02-23 21:37:44
tags:
---

XFCE是一款轻量级桌面环境，但是上手并不容易。本文以ArchLinux上的XFCE为例介绍其基础用法。

## 安装

```shell
sudo pacman -S xfce4
```

## 设置快捷键

设置窗口相关的快捷键：Settings Manager -> Window Manager -> Keyboard

设置执行自定义命令的快捷键：Settings Manager -> Keyboard -> Application Shortcuts

也可以用命令行来设置快捷键：{% post_link App/'xfce命令行设置快捷键' %}

## 托盘项

### 音量调节

```shell
sudo pacman -S xfce4-pulseaudio-plugin
```

然后在右上角的托盘右键，依次点击`Panel -> Panel Preferences -> Items -> Add`，选择`PulseAudio Plugin`，点击`Add`，然后音量调节的托盘项就出现在托盘的最右边了。可以在`Items`界面调整其位置。

如果用的是pipewire，需要安装pulseaudio的兼容层：

```shell
sudo pacman -S --needed pipewire-pulse
```

参考：<https://wiki.archlinux.org/title/PipeWire>

### 网络管理

```shell
sudo pacman -S --needed network-manager-applet
```

然后启动`nm-applet`：`nohup nm-applet &`，托盘中就会出现网络管理的托盘项了。logout再login之后它会被自动启动。

在Settings Manager里没有网络管理的入口。如果需要管理网络连接，需要右键网络管理的托盘项，选择`Edit Connections`，里面就可以设置自动连接之类的了。

### 蓝牙管理

```shell
sudo pacman -S --needed blueman
```

然后`nohup blueman-applet &`，托盘中就出现蓝牙管理的托盘项了。重启之后会被自动启动。

## 代理

XFCE的桌面设置中没有提供系统代理的设置。可以将代理设置写入`/etc/profile.d/profile.sh`，例如：

```shell
export http_proxy=http://localhost:端口号/
export https_proxy=$http_proxy
export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"
```

然后重启即可。

参考：<https://wiki.archlinux.org/title/Proxy_server>

## 翻转滚动方向

默认不是自然滚动。可以通过翻转滚动方向来实现自然滚动。

### 用`synclient`设置

#### 手动交互式配置

首先要把系统设置里的`Reverse scroll direction`取消勾选。

```shell
sudo pacman -S xf86-input-synaptics
```

然后重启。运行`synclient`，查看`VertScrollDelta`和`HorizScrollDelta`的当前值，我的：

```text
    VertScrollDelta         = 87
    HorizScrollDelta        = 87
```

然后将其设置成原来的相反数：

```text
synclient VertScrollDelta=-87
synclient HorizScrollDelta=-87
```

但是重启之后又会回到原来的状态。

参考：<https://askubuntu.com/a/853262>

#### 开机自动配置

将下面的命令放入`/etc/profile`：

```shell
old_value=$(synclient | awk '{if ($1 == "VertScrollDelta") { print $3 }}')
synclient VertScrollDelta=$((-$old_value))
old_value=$(synclient | awk '{if ($1 == "HorizScrollDelta") { print $3 }}')
synclient HorizScrollDelta=$((-$old_value))
```

然后`source /etc/profile`或者重启即可生效。

### 系统设置（不推荐）

`Settings Manager -> Mouse and Touchpad`，先在`Device:`选择设备，然后勾选`Reverse scroll direction`即可。注意这里鼠标和触摸板的设置是分开的，需要在`Device:`分别选择鼠标和触摸板来设置。

来源：<https://askubuntu.com/a/690513>

但是vscode和konsole好像不认这个设置，滚动方向跟设置前一样。这是XFCE的一个历史悠久的BUG: <https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/47>

## Tap to click

`Settings Manager -> Mouse and Touchpad`，`Device:`选择触摸板，然后选择`Touchpad`选项卡，勾选`Tap touchpad to click`。

来源：<https://forums.linuxmint.com/viewtopic.php?t=272698>

## 锁屏

```shell
sudo pacman -S xfce4-screensaver
nohup xfce4-screensaver &
```

然后左键右上角，点击`Lock Screen`就可以锁屏了。

快捷键设置在`Settings Manager -> Keyboard -> Application shortcuts -> xflock4`。默认是`ctrl+alt+L`。可以改成`Super+L`。

参考：<https://wiki.archlinux.org/title/Xfce#Lock_the_screen>

## 剪切板管理工具

### 快捷键

弹出所有剪切板历史的命令：

```shell
xfce4-clipman-history
```

所以将快捷键映射到这个命令即可。用命令行设置快捷键：

```shell
# Super+v 弹出剪切板历史
xfconf-query --create -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>v" -s "xfce4-clipman-history" --type string
```

### 托盘项

```shell
sudo pacman -S xfce4-clipman-plugin
```

然后在右上角的面板右键，依次点击`Panel -> Panel Preferences -> Items -> Add`，选择Clipman，点击`Add`，然后托盘项就出现在托盘的最右边了。可以在`Items`界面调整其位置。
