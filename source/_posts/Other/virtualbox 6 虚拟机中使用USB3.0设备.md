---
title: virtualbox 6 虚拟机中使用USB3.0设备
date: 2020-08-24 21:11:35
tags:
---

参考：
<https://superuser.com/questions/1490216/virtual-box-6-0-12-does-not-recognize-usb-device-even-guest-addon-is-installed-a>
<https://unix.stackexchange.com/questions/402400/windows-7-guest-in-virtualbox-not-recognizing-usb-3-0-devices>

首先安装virtualbox，并安装配套的extension pack，并且在虚拟机中安装增强功能。
然后执行
```shell
sudo usermod -aG vboxusers "$USER"
```
然后宿主机重启（或者注销重新登录？）
然后打开虚拟机，将控制器设置为USB3.0
![在这里插入图片描述](virtualbox%206%20虚拟机中使用USB3.0设备/20200824210841405.png)

![在这里插入图片描述](virtualbox%206%20虚拟机中使用USB3.0设备/20200824210521786.png)
然后点击你想在虚拟机里用的设备，这个设备就会在宿主机被移除，在虚拟机中被挂载。

![在这里插入图片描述](virtualbox%206%20虚拟机中使用USB3.0设备/2020082421104879.png)
