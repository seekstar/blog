---
title: wsl忘记root密码
date: 2020-03-26 21:23:51
---

参考：<https://blog.csdn.net/zcy_wxy/article/details/103621808>

要把所有连接上wsl的终端全部关闭，从而让wsl彻底关闭。最好是关机重启。
然后打开powershell，执行
```shell
ubuntu1804.exe config --default-user root
```
如果不是ubuntu18.04，则启动命令自行百度。

然后再连上wsl，运行passwd就可以改密码了。

再运行
```shell
ubuntu1804.exe config --default-user 你的用户名
```
把默认用户改回来。
