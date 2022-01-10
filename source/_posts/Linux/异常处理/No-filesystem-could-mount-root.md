---
title: No filesystem could mount root
date: 2022-01-10 11:45:59
tags:
---

装完Arch之后，重启，结果kernel panic，报这个错：

```
No filesystem could mount root
```

检查了```/etc/fstab```和生成的```/boot/grub/grub.cfg```，都是对的。

但是在grub的GUI界面在archlinux的项按```e```，进入grub编辑器之后，却发现```initrd```那行只有这个：

```
initrd /boot/intel-ucode.img
```

但是```/boot/grub/grub.cfg```里这行是这个：

```
initrd	/boot/intel-ucode.img /boot/initramfs-linux-lts.img
```

在grub编辑器里手动加上```/boot/initramfs-linux-lts.img```之后，就能进系统了。

所以问题的原因是GRUB GUI的界面是debian 11提供的，但是debian 11的GRUB有BUG，在读取arch的```/boot/grub/grub.cfg```时在```initrd```这行少读了一项，生成了错误的GRUB菜单。

解决方法有如下几个：

- 卸载intel-ucode

这样initrd里就只有一项了：

```
initrd	/boot/initramfs-linux-lts.img
```

- 手动修改GRUB menu

教程：<https://arcolinux.com/fix-for-kernel-panic-when-dualbooting-with-intel-ucode-or-amd-ucode/>

但是这个更改不是永久的，下次```update-grub```的时候更改就会被覆盖掉。

- 手动给GRUB打补丁

教程：<https://askubuntu.com/questions/628206/how-can-i-boot-into-arch-linux-using-initramfs-in-ubuntus-grub>

这个要编辑系统库。感觉风险挺大的，而且可能会对后续系统库升级产生影响？

## 致谢

感谢```#archlinux:archlinux.org```里的各位大佬的帮助。
