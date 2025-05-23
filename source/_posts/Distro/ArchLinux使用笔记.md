---
title: ArchLinux使用笔记
date: 2024-07-23 15:12:24
tags:
---

- {% post_link Distro/'免启动盘安装ArchLinux' %}

- {% post_link Distro/'ArchLinux-TLP' %}

## 安装NVIDIA驱动

官方完整教程：<https://wiki.archlinux.org/title/NVIDIA>

只要卡不是太老，一般情况下，如果用的是stable内核(`linux`)，就安装`nvidia`，如果用的是LTS内核(`linux-lts`)，就安装`nvidia-lts`。包里自带了把`nouveau`屏蔽掉的配置文件，因此重启即可。

然后执行`nvidia-smi`，有这种输出就说明安装成功了：

```text
Sat Dec 10 11:54:20 2022
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 525.60.11    Driver Version: 525.60.11    CUDA Version: 12.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|                               |                      |               MIG M. |
|===============================+======================+======================|
|   0  NVIDIA GeForce ...  Off  | 00000000:01:00.0 Off |                  N/A |
| N/A   74C    P0    50W /  N/A |     67MiB /  4096MiB |     94%      Default |
|                               |                      |                  N/A |
+-------------------------------+----------------------+----------------------+

+-----------------------------------------------------------------------------+
| Processes:                                                                  |
|  GPU   GI   CI        PID   Type   Process name                  GPU Memory |
|        ID   ID                                                   Usage      |
|=============================================================================|
|    0   N/A  N/A       950      G   /usr/lib/Xorg                       4MiB |
|    0   N/A  N/A     18194      C   ...psieveCUDA_0.2.3b_linux64       58MiB |
+-----------------------------------------------------------------------------+
```

有些应用依赖`opencl`，一款编程框架，类似于CUDA，因此也建议安装`opencl-nvidia`，这样使用opencl的程序就可以调用NVIDIA GPU的算力了。

## aur

孤立包其实就是orphan，也就是没有Maintainer。

尽量不要安装aur上的软件包，因为包的维护者往往不是官方，而且安装脚本有root权限，不安全。

## 常用软件的安装

### 微信

#### flatpak

原生微信。

```shell
flatpak install com.tencent.WeChat
flatpak run com.tencent.WeChat
```

也可以从系统的启动器里启动。

{% post_link App/'flatpak教程' %}

#### deepin-wine-wechat

```shell
yay -S deepin-wine-wechat
```

我尝试的版本：3.9.0.28-3

如果是KDE的话，大概会报这个错：

```shell
/opt/apps/com.qq.weixin.deepin/files/run.sh
```

```text
==> Creating /home/searchstar/.deepinwine/Deepin-WeChat/PACKAGE_VERSION ...
  X Error of failed request:  BadWindow (invalid Window parameter)
  Major opcode of failed request:  20 (X_GetProperty)
  Resource id in failed request:  0x0
  Serial number of failed request:  10
  Current serial number in output stream:  10
```

相关issue: [Xorg显示服务器无法运行微信 #293](https://github.com/vufa/deepin-wine-wechat-arch/issues/293)

解决方案参考<https://wiki.archlinux.org/title/Deepin-wine>的3.1部分：

```shell
sudo pacman -S xsettingsd
cat > $HOME/.config/autostart/xsettingsd.desktop <<EOF
[Desktop Entry]
Name=xsettingsd
Exec=/usr/bin/xsettingsd
Type=Application
EOF
```

注销再重新登录就好了。

第一次启动可能会报一个serious bug的错，不用管，再启动一次就好了。

### WPS

flatpak里只有英文版，建议用nix安装中文版：

```shell
nix-env -iA nixpkgs.wpsoffice-cn
```

教程：{% post_link Distro/'使用国内源安装和使用Nix包管理器' %}

## 修复系统目录和文件的权限

根目录权限有时会变成777。可能是AUR里的`wps-office-cn`导致的：<https://aur.archlinux.org/packages/wps-office-cn?O=40#comment-836049>。可以用flatpak安装国际版的WPS。教程：{% post_link App/'flatpak教程' %}

权限修复教程：{% post_link Distro/'ArchLinux修复系统目录和文件的权限' %}

## Wayland存在的一些问题

ArchLinux在某次升级之后就默认wayland了，但会导致一些问题。如果有需要的话可以在登录界面的左上角选择X11 session。

- keepass桌面客户端不能执行auto-type，因为wayland没有提供向另一个窗口发送keypress的API：<https://keepass.info/help/kb/autotype_wayland.html>

相关issue: [Support Auto-Type on Wayland](https://github.com/keepassxreboot/keepassxc/issues/2281)

相关PR: [Wayland autotype implementation (using xdg-desktop-portal)](https://github.com/keepassxreboot/keepassxc/pull/10905)

已解决的问题：

- 腾讯会议无法共享屏幕。
