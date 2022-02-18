---
title: qemu-system-x86_64 nographic
date: 2021-07-26 14:12:03
---

即使把图形界面删掉了，仍然是默认输出到显示器上的，这样nographic选项就没啥用。为了使其产生作用，在虚拟机中将`/etc/default/grub`里的
```
GRUB_CMDLINE_LINUX=""
```
改成
```
GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0"
```
然后
```shell
# debian系
sudo update-grub
# Centos 8
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

这样输出就会被重定向到终端了。然后
```shell
sudo qemu-system-x86_64 -m 4096 -enable-kvm deepin.img -nographic
```
就起作用了。

参考文献：
<https://serverfault.com/questions/471719/how-to-start-qemu-directly-in-the-console-not-in-curses-or-sdl>
