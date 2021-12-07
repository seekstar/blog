---
title: qemu gdb lx-symbols Python Exception ＜class ‘gdb.MemoryError‘＞ Cannot access memory at address 0xfff
date: 2021-01-22 13:58:30
---

在```/etc/default/grub```里的```GRUB_CMDLINE_LINUX```里加上```nokaslr```，然后更新一下```grub.cfg```：
centos上用
```shell
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```
debian系好像是
```shell
sudo update-grub
```
然后重启一下就好了。

参考文献：<https://blog.csdn.net/lonely_geek/article/details/89215513>
