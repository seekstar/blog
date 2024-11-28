---
title: Linux查看固态盘总写入量等信息
date: 2020-08-23 13:23:35
tags:
---

## 安装`smartctl`

```shell
sudo apt install smartmontools
```

## 找到固态盘的设备名

在终端中输入`ls /dev/nvm*`

![在这里插入图片描述](Linux查看固态盘总写入量等信息/20200823131359540.png)

第一个就是固态盘的设备名。

## 查看读写量等信息

```shell
sudo smartctl -a /dev/nvme0
```

![在这里插入图片描述](Linux查看固态盘总写入量等信息/20200823131509782.png)

![在这里插入图片描述](Linux查看固态盘总写入量等信息/2020082313173218.png)

这个就是写入量（为什么写入量比读出量高这么多）

也有可能会看到`Total_LBAs_Written`和`Total_LBAs_Read`（好像SATA协议的SSD都是这样）。`man smartctl`里对`LBA`的描述：`The LBA is a linear address, which counts 512-byte sectors on the disk, starting from zero.`。因此把`Total_LBAs_Written`和`Total_LBAs_Read`的值都乘上`512`，就是以字节为单位的写入量和读取量了。
