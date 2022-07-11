---
title: Linux生成initramfs
date: 2022-06-29 13:48:37
tags:
---

## dracut

各发行版通用。

```text
dracut [OPTION...] [<image> [<kernel version>]]
```

例子：

```shell
cd /boot
# 给/boot/vmlinuz-5.1.0-amd64-desktop+生成initramfs
dracut initramfs-5.1.0-amd64-desktop+.img 5.1.0-amd64-desktop+
```

### chroot

如果是在chroot里生成的话，需要先挂载proc，不然会出现这个问题：

```text
error: could not open file: /etc/mtab: No such file or directory
```

```shell
stat /etc/mtab
```

输出：

```text
File: /etc/mtab -> ../proc/self/mounts
```

### 内核版本号的获取

有些发行版的内核文件名中不带内核版本号，如果内核版本号指定错误的话，会报错，比如：

```shell
dracut initramfs-linux.img vmlinuz-linux
```

```text
dracut: Cannot find module directory /lib/modules/vmlinuz-linux/
dracut: and --no-kernel was not specified
```

所以通过`/lib/modules`找到内核版本号：

```shell
ls /lib/modules
```

```text
5.15.52-1-lts  5.18.9-arch1-1
```

然后这样就可以了：

```shell
dracut initramfs-linux.img 5.18.9-arch1-1 --force
dracut initramfs-linux-lts.img 5.15.52-1-lts --force
```

### dracut: dracut module 'xxx' will not be installed, because command 'xxx' could not be found!

这些报错貌似不用管也行。要消除这些报错，按照提示把对应的命令装上就行了：

```shell
sudo pacman -S dash dbus-broker rng-tools dhclient multipath-tools tpm2-tools open-iscsi nbd nfs-utils nvme-cli procps-ng squashfs-tools
```

不过这些命令pacman的源里好像没有：

```text
mksh wicked biosdevname memstrack
```

所以这些报错仍然存在：

```text
dracut: dracut module 'mksh' will not be installed, because command 'mksh' could not be found!
dracut: dracut module 'network-wicked' will not be installed, because command 'wicked' could not be found!
dracut: dracut module 'fcoe' will not be installed, because command 'dcbtool' could not be found!
dracut: dracut module 'fcoe' will not be installed, because command 'fipvlan' could not be found!
dracut: dracut module 'fcoe' will not be installed, because command 'lldpad' could not be found!
dracut: dracut module 'fcoe' will not be installed, because command 'fcoemon' could not be found!
dracut: dracut module 'fcoe' will not be installed, because command 'fcoeadm' could not be found!
dracut: dracut module 'fcoe-uefi' will not be installed, because command 'dcbtool' could not be found!
dracut: dracut module 'fcoe-uefi' will not be installed, because command 'fipvlan' could not be found!
dracut: dracut module 'fcoe-uefi' will not be installed, because command 'lldpad' could not be found!
dracut: dracut module 'biosdevname' will not be installed, because command 'biosdevname' could not be found!
dracut: dracut module 'memstrack' will not be installed, because command 'memstrack' could not be found!
dracut: memstrack is not available
dracut: If you need to use rd.memdebug>=4, please install memstrack and procps-ng
```

但是不影响启动。

### A start is running for loading kernel modules

ArchLinux stable内核(5.18.9-arch1-1)在开机时会卡在这里一段时间：

```text
A start is running for loading kernel modules.
```

dmesg:

```text
[   95.852562] kauditd_printk_skb: 49 callbacks suppressed
[   95.852567] audit: type=1130 audit(1657375436.266:110): pid=1 uid=0 auid=4294967295 ses
=4294967295 msg='unit=systemd-modules-load comm="systemd" exe="/usr/lib/systemd/systemd" h
ostname=? addr=? terminal=? res=failed'
[   95.867354] audit: type=1130 audit(1657375436.283:111): pid=1 uid=0 auid=4294967295 ses
=4294967295 msg='unit=systemd-sysctl comm="systemd" exe="/usr/lib/systemd/systemd" hostnam
e=? addr=? terminal=? res=success'
[   95.926847] audit: type=1130 audit(1657375436.343:112): pid=1 uid=0 auid=4294967295 ses=4294967295 msg='unit=nix-daemon comm="systemd" exe="/usr/lib/systemd/systemd" hostname=? addr=? terminal=? res=success'
[   95.936318] audit: type=1334 audit(1657375436.353:113): prog-id=27 op=LOAD
[   95.940063] audit: type=1334 audit(1657375436.353:114): prog-id=28 op=LOAD
[   95.943095] audit: type=1334 audit(1657375436.353:115): prog-id=29 op=LOAD
```

不清楚是哪里出问题了。不过等一小段时间仍然能进入系统。

此外，ArchLinux LTS内核(5.15.52-1-lts)没有这个问题。

## update-initramfs

Debian系可用。

```shell
sudo update-initramfs -ck 要生成initramfs的内核版本
```
