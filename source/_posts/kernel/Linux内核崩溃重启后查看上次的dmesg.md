---
title: Linux内核崩溃重启后查看上次的dmesg
date: 2020-09-25 19:14:44
tags:
---

参考：<https://stackoverflow.com/questions/9682306/android-how-to-get-kernel-logs-after-kernel-panic>

在centos 8上在```/sys/fs/pstore/```
![在这里插入图片描述](Linux内核崩溃重启后查看上次的dmesg/20200925191324546.png#pic_center)
时间戳最大的就是最近的。
如果没有，或者信息不全的话，可以参照[这篇文章](https://blog.csdn.net/qq_41961459/article/details/109127592)，用```kdump```来保存完整的dmesg。
