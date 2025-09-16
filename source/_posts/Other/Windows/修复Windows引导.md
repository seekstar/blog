---
title: 修复Windows引导
date: 2022-04-24 00:39:12
tags:
---

背景：EFI分区由于意外被清空了。首先修复了Linux的引导，现在需要修复Windows引导。

首先烧一个windows启动盘，进去之后不安装，而是选择`修复这台计算机`，选择`疑难解答`，选择`命令提示符`。

然后首先`C:`切换到C盘，然后`bootrec /FixBoot`。如果提示拒绝访问，就`bootsect /nt60 sys`，然后再`bootrec /FixBoot`，应该就好了。方法来源：[bootrec /fixboot拒绝访问真正的修复，好多文章都是假的不起作用](https://blog.csdn.net/xw988tom/article/details/118788664)

然后重建BCD：`bootrec /RebuildBcd`，会提示`是否要将安装添加到启动列表`，输入`Y`。这时EFI分区下面有`Microsoft/Boot/BCD`了，但是没有`bootmgfw.efi`，所以在Linux上`update-grub`还是识别不出windows。

P.S. 不知道直接重建BCD，不做上面的`FixBoot`可不可以。

然后`exit`，`疑难解答`，`启动修复`，会进入windows系统。重启可能会直接进windows。这时得在BIOS里更改启动优先级，把linux排在Windows Boot Manager前面，甚至可以直接把Windows Boot Manager禁用掉，反正我们只从grub进windows。进Linux之后`update-grub`，再重启就可以在grub界面看到windows boot manager了。
