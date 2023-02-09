---
title: Linux开机自动mount
date: 2023-02-09 16:04:47
tags:
---

## `/etc/fstab`

以挂载fat32文件系统为例，在`/etc/fstab`中添加：

```text
UUID=xxxx	/mnt/sdcard	vfat	defaults	0 0
```

其中UUID可以通过`sudo blkid /dev/xxxx`查看。

### 选项

`defaults`这栏可以改成其他选项，或者在`defaults`后面加上其他选项（用逗号隔开）。

#### nofail

防止设备不存在时启动失败。来源：<https://unix.stackexchange.com/questions/53377/do-not-halt-the-boot-if-an-fstab-mounting-fails>

#### noatime

访问文件时不写入access time。这可以增加访问文件的速度。

来源：<https://wiki.archlinux.org/title/Fstab>

#### user

FAT文件系统不保存用户的信息，因此挂载FAT文件系统时必须指定一个用户。默认的用户是root。将其更改成指定用户：`uid=xxx,gid=xxx,user`，其中`uid`和`gid`可以通过`id`命令查看。

## Systemd mount unit

例如要在开机时`mount /dev/mmcblk0 /mnt/sdcard`，其为`FAT32`类型，则添加文件`/etc/systemd/system/mnt-sdcard.mount`:

```ini
[Unit]
Description = Mount sdcard at boot

[Mount]
What = /dev/mmcblk0
Where = /mnt/sdcard
Type = vfat
Options = defaults

[Install]
WantedBy = multi-user.target
```

注意其中的`vfat`不能写成`fat32`，不然会报错。

然后启动服务：

```shell
sudo systemctl daemon-reload
sudo systemctl enable --now mnt-sdcard.mount
```

然后就挂载上了：

```shell
df -h
```

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/mmcblk0     30G   16K   30G   1% /mnt/sdcard
```

来源：<https://superuser.com/questions/826997/mount-partition-on-boot-without-fstab>
