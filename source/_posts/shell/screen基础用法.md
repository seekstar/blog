---
title: screen基础用法
date: 2021-03-20 09:14:23
---

新建screen
```shell
screen
```
detach：```ctrl+a d```

重连：
```shell
screen -ls
```
```
There is a screen on:
        210569.pts-0.localhost  (Detached)
1 Socket in /run/screen/S-searchstar.
```
```shell
screen -r 210569
```
或者```screen -r```后按一下tab，会自动帮你补全。

上翻：```ctrl+a ESC```进入复制模式(copy mode)，然后就可以按照vim的方式翻页了。
