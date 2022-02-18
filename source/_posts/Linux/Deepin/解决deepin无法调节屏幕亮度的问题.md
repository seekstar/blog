---
title: 解决deepin无法调节屏幕亮度的问题
date: 2020-08-07 19:29:27
tags:
---

更新到deepin v20之后，新系统的设置里的亮度调节貌似只能调节硬件背光。而我的显示器不支持调节背光，所以设置里的亮度调节失效了。
解决方案是使用软件背光，并且设置自启。

先安装redshift。在终端输入
```shell
sudo apt install redshift
```
在`~/.config/autostart`里创建文件`redshift.desktop`，内容：
```
[Desktop Entry]
Version=1.0
Name=redshift
Comment=redshift
Exec=redshift -b 0.3
Terminal=false
Type=Application
Categories=System
```
其中的0.3是亮度，可以根据需求换成0.1到1。
然后重启就好了。
如果要立即生效（不重启），可以直接在终端执行
```shell
nohup redshift -b 0.3 &
```
