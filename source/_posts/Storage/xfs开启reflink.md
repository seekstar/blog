---
title: xfs开启reflink
date: 2021-07-02 10:35:03
---

这个要在格式化的时候就开启reflink的功能。

先备份数据，然后格式化
```shell
mkfs.xfs -m reflink=1 -f /dev/vdb1
```
然后再重新mount就好了。
