---
title: '在chroot环境中挂载dev, proc, sys'
date: 2022-04-27 16:33:44
tags:
---

```shell
cd /location/of/new/root
mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount --rbind /dev dev/
```

按照我的理解，`mount -rbind a b`相当于把a目录挂载到b目录，这样访问b目录就相当于访问a目录了。

如果运行某命令出现`syslog is not available`的报错，可以试试：

```shell
mount --rbind /run run/
```

来源：

<https://wiki.archlinux.org/title/Chroot#Using_chroot>

<https://blog.csdn.net/sinat_37322535/article/details/117022038>
