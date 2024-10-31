---
title: 用Linux卸载手机上的系统软件
date: 2024-10-31 13:33:01
tags:
---

很多手机系统滥用系统软件定义，把没用的软件归类为系统软件，不让用户卸载。但我们可以用adb卸载这些软件。

首先用USB数据线将手机连接到电脑，在手机上切换到文件传输模式（MTP模式）

## 安装`adb`

### ArchLinux

```shell
# https://wiki.archlinux.org/title/Android_Debug_Bridge
sudo pacman -S android-tools
```

## 打开USB调试

这个选项一般在开发者模式中。

进入开发者模式：一般是在系统信息中连续点击系统版本。

然后在开发者选项中打开USB调试。可能还需要打开弹窗提醒。

## USB调试

```shell
adb devices
```

会自动启动daemon:

```text
* daemon not running; starting now at tcp:5037
* daemon started successfully
```

`List of devices attached`下面会有一行，这就是你的手机。

然后手机上会弹出是否允许USB调试的选项框，点击确定即可。

## `adb shell`

在终端中执行`adb shell`。然后就可以在这里面卸载应用了。

以下是shell里的命令：

```shell
pm list packages
# https://stackoverflow.com/questions/21164748/difference-between-pm-clear-and-pm-uninstall-k-on-android
pm uninstall --user 0 包名
exit
```

`--user 0`: The user to disable. User 0 is the system user.

`-k` : Keep the data and cache directories around after package removal.

也可以在Linux的shell里直接执行指令：

```shell
adb shell pm list packages
adb shell pm uninstall --user 0 包名
```

可以用F-Droid在手机上装`Package Manager`查看应用的包名：{% post_link App/'F-Droid使用教程' %}

## 你可能想卸载的系统软件

### 华为手机

```shell
# 智慧助手-今天
adb shell pm uninstall --user 0 com.huawei.intelligent
```

## 参考文献

[利用adb卸载手机预装软件(系统软件)](https://blog.csdn.net/m0_43404934/article/details/124902494)
