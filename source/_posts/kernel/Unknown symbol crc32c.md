---
title: Unknown symbol crc32c
date: 2021-07-19 21:26:23
---

是因为提供crc32c这个符号的内核模块没有被load。在内核模块的目录下搜一下
```shell
cd /lib/modules/$(uname -r)
find . -iname "*crc32c*"
```
```
./kernel/lib/libcrc32c.ko
```
这就是我们要load的模块了。

```shell
sudo modprobe libcrc32c
```

然后就好了。

参考文献：<https://dev.archive.openwrt.org/ticket/14452>
