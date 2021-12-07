---
title: qemu挂载物理磁盘
date: 2021-01-21 21:37:02
---

参考：<https://askubuntu.com/questions/572913/qemu-connect-physical-disk>

使用选项
```shell
-hdb /dev/sdX
```
即可。进虚拟机之后就可以看到```/dev/sdb```了。然后用```mount```命令挂载即可。
