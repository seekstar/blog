---
title: Linux设置系统时间
date: 2022-06-05 18:37:46
tags:
---

首先关闭自动时间同步：

```shell
sudo timedatectl set-ntp 0
```

然后可以用`date`来设置时间：

```shell
sudo date -s "2018-01-19 11:24:47"
```

验证：

```shell
date
```

这时输出的应该就是刚刚设置的时间了。

重新打开自动时间同步：

```shell
sudo timedatectl set-ntp 1
```

来源：<https://www.linuxhelp.com/questions/failed-to-set-time-automatic-time-synchronization-is-enabled>

注意：修改为错误的时间的话，https连接可能会失败，校园网环境可能会导致掉线，甚至导致IP改变。
