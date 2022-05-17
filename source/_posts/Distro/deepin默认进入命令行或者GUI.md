---
title: deepin默认进入命令行或者GUI
date: 2020-09-19 23:49:38
tags:
---

# 默认进入命令行
参考：<https://www.cnblogs.com/zhscn/p/8607822.html>

```shell
sudo systemctl disable lightdm
```
先别执行。先看下面怎么恢复默认进入GUI。

# 临时进入GUI
```shell
startx
```
# 默认进入GUI
按理说`sudo systemctl enable lightdm`应该是可以的，但是我这里提示不能用`systemctl`启动lightdm。

## 方法1
参考：<https://tieba.baidu.com/p/5195178229>
```shell
sudo dpkg-reconfigure lightdm
```
## 方法2(不推荐)
把下面的放到/etc/rc.local里
```shell
sudo service lightdm start
```
缺点是开机的时候会短暂进入命令行界面。

如果没有`/etc/rc.local`，自行百度，利用systemctl模拟之。
