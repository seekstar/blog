---
title: qemu archlinux Could not find an installable distribution
date: 2022-01-09 01:24:35
tags:
---

archlinux的ISO是hybrid结构的，要用```--cdrom=xxx.iso```来启动。

例子：

```shell
virt-install --name=archlinux --memory=1024 --vcpus=4 --cdrom='/home/searchstar/Downloads/ISO/archlinux-2022.01.01-x86_64.iso' --disk path=archlinux.img,size=32
```

参考：<https://bbs.archlinux.org/viewtopic.php?id=227412>
