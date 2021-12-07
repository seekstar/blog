---
title: Linux挂载ext4 ramdisk
date: 2020-08-23 20:13:44
tags:
---

# 划分一块DRAM作为ramdisk
在/etc/default/grub改：
```
GRUB_CMDLINE_LINUX="memmap=4G!4G"
```
然后重启就可以看到/dev/pmem0，这就是划分出来的ramdisk了。

# 格式化
```shell
mkfs -t ext4 /dev/pmem0
```
# 挂载
这里的挂载点设置为了```/mnt/pmem```。
```shell
mkdir -p /mnt/pmem
mount -t ext4 /dev/pmem0 /mnt/pmem -o dax
```
如果原先终端的当前目录就在```/mnt/pmem```，一定要
```shell
cd ..
cd pmem
```
这样才能进入新的dentry。

# chown
挂载后挂载点默认是```root:root```的。如果想要让普通用户也能进去改，只需要chown成那个用户就好了。
```shell
chown -R 用户名:组名 /mnt/pmem
```
