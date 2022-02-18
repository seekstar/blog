---
title: 解决安装windows后Linux引导被覆盖的问题
date: 2020-10-05 12:46:28
tags:
---

强烈谴责windows的霸道行径！！！

# 安装windows
首先安装windows时提示`检测到EFI分区为NTFS格式，请格式化为FAT32后重试`。但是所有的EFI分区都是FAT32的。然后我尝试着把之前安装Linux时设置的EFI分区删了，使用windows安装程序自己生成的EFI分区，然后就安装成功了，但是Linux就进不去了。

# 修复Linux引导
首先尝试了EasyBCD，选择免费版安装即可。但是添加新条目中Linux/BSD没法选驱动器（灰色的）。
![在这里插入图片描述](解决安装windows后Linux引导被覆盖的问题/20201005124415504.png)

然后烧了个ubuntu启动盘，在试用模式下使用`boot-repair`，虽然提示修复成功了，但是开机后直接进入了grub命令行。
最后只好再弄出一片空闲空间，安装ubuntu，安装的时候新建一个EFI分区。装完之后所有系统都可以进去了。

强烈谴责windows的霸道行径！！！
