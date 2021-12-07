---
title: virtualbox安装deepin v15.11后安装增强功能
date: 2020-08-22 17:09:18
tags:
---

没有安装增强功能的话貌似不能让虚拟机自动调整分辨率。
点击
![在这里插入图片描述](virtualbox安装deepin%20v15.11后安装增强功能/20200822170258763.png)
结果提示挂载失败。
这一般是由于已经挂载上了。
在虚拟机里打开文件管理器
![在这里插入图片描述](virtualbox安装deepin%20v15.11后安装增强功能/2020082217052050.png)
不要运行autorun.sh，会提示出错。以root运行```VBoxLinuxAdditions.run```
![在这里插入图片描述](virtualbox安装deepin%20v15.11后安装增强功能/2020082217082673.png)
然后重启虚拟机就好了。
