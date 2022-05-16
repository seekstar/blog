---
title: mount qemu image
date: 2022-05-16 18:03:50
tags:
---

有时配置错误导致虚拟机无法开机。此时就可以将虚拟机镜像挂载到宿主机，然后`chroot`进去修复。

可以使用NBD实现：

```shell
modprobe nbd max_part=8
qemu-nbd --connect=/dev/nbd0 镜像路径
```

然后`/dev/nbd0`就变成了虚拟机的磁盘了。可以查看分区信息，并且mount相应的分区：

```shell
fdisk -l /dev/nbd0
mount /dev/nbd0p分区号 /mnt/somepoint/
```

来源：<https://gist.github.com/shamil/62935d9b456a6f9877b5>

但是如果是LVM的话，就不能直接mount。比如CentOS通常只有一个boot分区和一个LVM分区：

```text
设备        启动    起点      末尾      扇区  大小 Id 类型
/dev/nbd0p1 *       2048   2099199   2097152    1G 83 Linux
/dev/nbd0p2      2099200 536870911 534771712  255G 8e Linux LVM
```

LVM的基本概念：[LVM概述及管理命令](https://blog.csdn.net/jiaoshu__/article/details/116570990)

物理卷：PV, Physical Volume
卷组：Volume Group
逻辑卷：Logical Volume

查看物理卷：

```shell
pvscan
```

```text
  WARNING: VG name cl is used by VGs KqFlss-8OHi-dVNs-3cAi-Qc8w-e3Uv-21vlfH and Yr4Miq-SItn-WI9O-fA3t-pBB1-Jusy-0qUURg.
  Fix duplicate VG names with vgrename uuid, a device filter, or system IDs.
  PV /dev/sde3     VG cl              lvm2 [<1.73 TiB / 4.00 MiB free]
  PV /dev/nbd0p2   VG cl              lvm2 [<255.00 GiB / 0    free]
  Total: 2 [1.97 TiB] / in use: 2 [1.97 TiB] / in no VG: 0 [0   ]
```

`/dev/nbd0p2`就是我的虚拟机上的LVM分区。我的宿主机的卷组也叫cl，跟虚拟机的卷组名字冲突了。改一个名字：

```shell
# 查看逻辑卷的UUID
vgdisplay
vgrename Yr4Miq-SItn-WI9O-fA3t-pBB1-Jusy-0qUURg vm-centos8
```

```text
Volume group "Yr4Miq-SItn-WI9O-fA3t-pBB1-Jusy-0qUURg" successfully renamed to "vm-centos8"
```

再`pvscan`就可以看到WARNING消失了：

```text
  PV /dev/sde3     VG cl              lvm2 [<1.73 TiB / 4.00 MiB free]
  PV /dev/nbd0p2   VG vm-centos8      lvm2 [<255.00 GiB / 0    free]
  Total: 2 [1.97 TiB] / in use: 2 [1.97 TiB] / in no VG: 0 [0   ]
```

查看逻辑卷：

```shell
lvscan
```

```text
  ACTIVE            '/dev/cl/root' [1.60 TiB] inherit
  ACTIVE            '/dev/cl/swap' [128.00 GiB] inherit
  inactive          '/dev/vm-centos8/swap' [3.96 GiB] inherit
  inactive          '/dev/vm-centos8/home' [181.03 GiB] inherit
  inactive          '/dev/vm-centos8/root' [70.00 GiB] inherit
```

可以看到虚拟机的根目录分区被映射到了`/dev/vm-centos8/root`。我们将根目录挂载到host。首先激活这个逻辑卷：

```shell
lvchange -a y /dev/vm-centos8/root
lvscan
```

```text
  ACTIVE            '/dev/cl/root' [1.60 TiB] inherit
  ACTIVE            '/dev/cl/swap' [128.00 GiB] inherit
  inactive          '/dev/vm-centos8/swap' [3.96 GiB] inherit
  inactive          '/dev/vm-centos8/home' [181.03 GiB] inherit
  ACTIVE            '/dev/vm-centos8/root' [70.00 GiB] inherit
```

也可以一次性把整个卷组里的所有逻辑卷激活：

```shell
vgchange -a y vm-centos8
lvscan
```

```text
  ACTIVE            '/dev/cl/root' [1.60 TiB] inherit
  ACTIVE            '/dev/cl/swap' [128.00 GiB] inherit
  ACTIVE            '/dev/vm-centos8/swap' [3.96 GiB] inherit
  ACTIVE            '/dev/vm-centos8/home' [181.03 GiB] inherit
  ACTIVE            '/dev/vm-centos8/root' [70.00 GiB] inherit
```

然后就可以mount了：

```shell
mount /dev/vm-centos8/root 挂载点
```

但是由于之前改变了卷组名，所以虚拟机会无法启动。修复方式如下。

```shell
# boot分区通过fdisk -l /dev/nbd0查看
mount /dev/nbd0p1 挂载点/boot
```

然后把dev、proc、sys都挂上：{% post_link Linux/'在chroot环境中挂载dev-proc-sys' %}

```shell
chroot 挂载点
```

在chroot里修改`/etc/fstab`，把里面的`/dev/mapper/cl-root`、`/dev/mapper/cl-home`、`/dev/mapper/cl-swap`分别修改为`/dev/mapper/vm--centos8-root`、`/dev/mapper/vm--centos8-home`、`/dev/mapper/vm--centos8-swap`。

```shell
grub2-mkconfig -o /boot/grub2/grub.cfg
dracut -f --regenerate-all
```

然后`exit`退出chroot。然后把dev、proc、sys都`umount`：{% post_link Linux/'在chroot环境中挂载dev-proc-sys' %}

然后：

```shell
umount 挂载点
vgchange -a n vm-centos8
## 一定要确保卷组的所有逻辑卷都是inactive才能disconnect。
lvscan
qemu-nbd --disconnect /dev/nbd0
```

参考：

<https://www.thegeekdiary.com/how-to-mount-guest-qcow2-virtual-disk-image-containing-lvm-on-kvm-host-machine/>

[can't boot after volume name change](https://forums.centos.org/viewtopic.php?t=73033)

相关问题：

<https://www.thegeekdiary.com/logical-volume-vg-lv-contains-a-filesystem-in-use-while-removing-lvm-filesystem/>
<https://blog.csdn.net/weixin_34375054/article/details/94754700>
但是没有用。
