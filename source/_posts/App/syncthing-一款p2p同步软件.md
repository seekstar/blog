---
title: 'syncthing: 一款p2p同步软件'
date: 2021-12-30 22:32:11
tags:
---

比较详细的教程：<https://zhuanlan.zhihu.com/p/121544814>

安卓端可以在F-Droid下载。F-Droid使用教程：<https://seekstar.github.io/2021/12/29/f-droid%E4%BD%BF%E7%94%A8%E6%95%99%E7%A8%8B/>

电脑端建议直接在github下载：<https://github.com/syncthing/syncthing/releases>

这里主要说一些坑点。

## 不要用Deepin商店里的syncthing

那个版本太低了，是v1.0.0-ds1，而我们手机端在F-Droid上下载的是最新版，不兼容这个v1.0.0-ds1，两者不能同步。电脑端建议直接到github上下载。

## 手机的同步目录的目录种类是`只发送`

如果尝试修改，会提示当前系统只支持`只发送`。我用的是鸿蒙系统，在系统里把默认存储改到存储卡，然后就可以把目录种类改成`发送和接收`了。

此外，千万别覆盖，不然远端的文件会全部被删掉。。。

## `$HOME is undefined`

在使用`supervisor`实现开启自动启动syncthing时，可能会失败，然后在日志里可能会发现这个错误信息。这是因为`supervisor`不会自动设置`HOME`等环境变量，但是syncthing又需要。这时只需要在conf里加上一行这个：

```
environment=HOME="/home/your_name"
```

就手动设置了`HOME`环境变量了。

来源：<http://supervisord.org/subprocess.html#subprocess-environment>

## 鸿蒙杀后台太快

从syncthing界面离开几秒钟之后，鸿蒙就会自动终止其网络传输。可以试试关掉syncthing的自动管理，换成手动管理，然后设置成允许后台活动。然后为了其耗电太快，将其设置成只在交流电下使用。

## 远程机器上设置GUI密码之后浏览器连不上了

不知道为啥。重启syncthing即可。
