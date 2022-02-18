---
title: vnc root窗口无法弹出
date: 2021-01-21 09:45:45
---

参考：<https://blog.csdn.net/xeseo/article/details/11963473>

```shell
sudo xclock
```
```
X11 connection rejected because of wrong authentication.
Error: Can't open display: localhost:10.0
```
# 一步到位版
```shell
su -c "xauth add $(xauth list | grep :$(echo $DISPLAY | sed 's/.*://g' | sed 's/\..*//g'))"
```
# 循序渐进版
先查看当前终端的DISPLAY
```shell
echo $DISPLAY
```
```
localhost:10.0
```
```shell
xauth list
```
```
searchstar-PC/unix:0  MIT-MAGIC-COOKIE-1  36a28b824ea113035e9c72db3a83ac28
L1707:1  MIT-MAGIC-COOKIE-1  7da24adee7391ef7b649a5276da71a13
L1707/unix:1  MIT-MAGIC-COOKIE-1  7da24adee7391ef7b649a5276da71a13
L1707/unix:14  MIT-MAGIC-COOKIE-1  d2d47cec3ab49f0ad1075a1facf1ddc7
L1707/unix:13  MIT-MAGIC-COOKIE-1  9fff851524c6fcbdbdfde5bebca79c34
L1707:0  MIT-MAGIC-COOKIE-1  62a3324080875e36e9604b7acd567f11
L1707/unix:0  MIT-MAGIC-COOKIE-1  62a3324080875e36e9604b7acd567f11
L1707:2  MIT-MAGIC-COOKIE-1  04f9df176c77a732213a9c28d6f96b81
L1707/unix:2  MIT-MAGIC-COOKIE-1  04f9df176c77a732213a9c28d6f96b81
L1707/unix:12  MIT-MAGIC-COOKIE-1  9850050c877f8daf16513005186e9fa0
L1707/unix:11  MIT-MAGIC-COOKIE-1  0521aa38f800363529d304e9455b67d2
L1707/unix:10  MIT-MAGIC-COOKIE-1  c4afdb0113ff7caa556f57f65b8a8441
```
然后切换到root用户
```shell
sudo -s
```
把`:10`相关的行加到`xauth`里
```shell
xauth add L1707/unix:10  MIT-MAGIC-COOKIE-1  c4afdb0113ff7caa556f57f65b8a8441
```
退回到普通用户再试就好了
```shell
sudo xclock
```
![在这里插入图片描述](vnc%20root窗口无法弹出/20210121094442278.png)
