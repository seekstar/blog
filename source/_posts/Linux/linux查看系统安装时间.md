---
title: linux查看系统安装时间
date: 2022-02-13 11:03:53
tags:
---

方法一：查看root账户上次更改密码的时间

```shell
sudo passwd -S root
```

方法二：查看根目录所在的文件系统的创建时间：

```shell
fs=$(df / | tail -1 | cut -f1 -d' ') && tune2fs -l $fs | grep 'Filesystem created'
```

参考：

<https://blog.csdn.net/qq_41781322/article/details/90407201>

<https://ostechnix.com/find-exact-installation-date-time-linux-os/>
