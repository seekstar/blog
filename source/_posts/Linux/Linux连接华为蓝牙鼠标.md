---
title: Linux连接华为蓝牙鼠标
date: 2021-12-29 19:54:39
tags:
---

鼠标说明书上说只支持Windows和Android，其实Linux也支持的。在Linux上直接连接华为蓝牙鼠标的话，可能连不上。要另外装一个叫`blueman`的软件，然后在`blueman`里连接或者在系统自带的蓝牙管理界面连接，就能连上了。

`blueman`的安装方法：

```shell
sudo apt install blueman
```

如果是deepin的话，应用商店搜`blueman`也能搜到。

至于为什么装了这个就能连上，我也不知道。

Update: 在神舟电脑上成功，但是在MateBook X Pro上失败了。。。

参考：<https://jingyan.baidu.com/article/e5c39bf575b25579d6603309.html>
